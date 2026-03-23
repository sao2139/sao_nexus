#!/bin/bash

function dir_bruteforce() {
    echo -e "\n${CYAN}--- Escáner Pasivo de Directorios Web ---${NC}"
    echo -e "${YELLOW}Auditoría: Buscando rutas sensibles expuestas en tu servidor web.${NC}"
    read -p "URL base (ej. http://example.com): " base_url
    [[ -z "$base_url" ]] && return
    
    echo -e "\n${GREEN}[+] Probando diccionarios de rutas sensibles...${NC}"
    local rutas=("/admin" "/login" "/backup" "/.git" "/.env" "/config" "/api" "/robots.txt" "/phpmyadmin")
    
    if command -v curl >/dev/null 2>&1; then
        for ruta in "${rutas[@]}"; do
            local target="${base_url}${ruta}"
            local code=$(curl -s -o /dev/null -I -w "%{http_code}" "$target")
            if [[ "$code" == "200" || "$code" == "301" || "$code" == "302" ]]; then
                echo -e "${LIGHT_GREEN}[+] ENCONTRADO (${code}):${NC} $target"
                log_event "[Web] VULNERABILIDAD RUTA EXPUESTA HTTP $code: $target"
            elif [[ "$code" == "403" ]]; then
                echo -e "${PURPLE}[*] PROHIBIDO (403):${NC} $target (Ruta existe)"
                log_event "[Web] Ruta prohibida pero detectada (HTTP 403): $target"
            else
                echo -e "${RED}[-] Oculto/Vacío (${code}):${NC} $target"
            fi
        done
    else
        echo -e "${RED}[!] Comando 'curl' necesario para peticiones HTTP.${NC}"
    fi
    echo ""
    read -p "Presiona Enter..."
}

function xss_scanner() {
    echo -e "\n${CYAN}--- Escáner de Reflejo Básico XSS ---${NC}"
    echo -e "${YELLOW}Auditoría: Comprueba si un parámetro GET se refleja sin sanitizar en el código.${NC}"
    read -p "URL con parámetro (ej. http://sitio.com/buscar?q=): " xss_url
    [[ -z "$xss_url" ]] && return
    
    local payload="<sAoNeXuS_XSS_Check>"
    echo -e "\n${YELLOW}[*] Inyectando payload benigno: $payload${NC}"
    
    if command -v curl >/dev/null 2>&1; then
        local response=$(curl -s "${xss_url}${payload}")
        
        if echo "$response" | grep -q "$payload"; then
            echo -e "${RED}[!] ¡ALERTA VULNERABLE! El payload se reflejó directamente en el HTML sin filtrar.${NC}"
            echo -e "${RED}    El endpoint es vulnerable a Cross-Site Scripting (XSS).${NC}"
            log_event "[Web] RIESGO CRÍTICO: Vulnerabilidad XSS Confirmada en endpoint $xss_url"
        else
            echo -e "${GREEN}[+] SEGURO. El parámetro inyectado fue filtrado, sanitizado o no se reflejó.${NC}"
        fi
    fi
    echo ""
    read -p "Presiona Enter..."
}

function stress_test() {
    echo -e "\n${CYAN}--- HTTP Local Load Tester ---${NC}"
    echo -e "${YELLOW}ADVERTENCIA: Esta herramienta es SOLO para auditar capacidad en servidores propios autorizados.${NC}"
    read -p "URL objetivo (ej. http://localhost:80): " target_url
    [[ -z "$target_url" ]] && return
    
    read -p "Número de peticiones a enviar: " num_reqs
    [[ ! "$num_reqs" =~ ^[0-9]+$ ]] && return
    
    echo -e "${GREEN}[+] Lanzando $num_reqs peticiones continuas a $target_url...${NC}"
    log_event "[Web] Arrancando prueba de esfuerzo: $num_reqs peticiones hacia $target_url"
    
    local success=0; local failed=0
    for ((i=1; i<=num_reqs; i++)); do
        if curl -s -o /dev/null -w "%{http_code}" -m 2 "$target_url" > /dev/null 2>&1; then
            ((success++))
            echo -ne "\r${GREEN}[+] Carga sintética: $i/$num_reqs | Exitosas: $success | Fallidas: $failed${NC}"
        else
            ((failed++))
            echo -ne "\r${RED}[!] Carga sintética: $i/$num_reqs | Exitosas: $success | Fallidas: $failed${NC}"
        fi
    done
    echo -e "\n\n${CYAN}[*] Prueba de carga finalizada.${NC}"
    log_event "[Web] Prueba terminada. Exitosas: $success | Fallidas: $failed"
    read -p "Presiona Enter..."
}

function sqli_prober() {
    echo -e "\n${CYAN}--- SQL Injection Prober (Error-Based) ---${NC}"
    echo -e "${YELLOW}Auditoría: Envía caracteres especiales (') a la URL para provocar errores en la base de datos.${NC}"
    read -p "Introduce URL con parámetro (ej. sitio.com/item?id=1): " sqli_url
    [[ -z "$sqli_url" ]] && return
    
    echo -e "\n${GREEN}[+] Inyectando saltos lógicos en backend...${NC}"
    if command -v curl >/dev/null 2>&1; then
        # Payloads de provocación básicos
        local payload="%27" # Comilla simple encodeada
        local response=$(curl -sL "${sqli_url}${payload}")
        
        # Lista de errores típicos devueltos por DBs mal configuradas
        local errores=("You have an error in your SQL syntax" "Warning: mysql_fetch" "unclosed quotation mark after the character string" "SQL syntax error" "valid PostgreSQL result" "ORA-01756")
        
        local vulnerable=false
        for error in "${errores[@]}"; do
            if echo "$response" | grep -iq "$error"; then
                echo -e "${RED}[!] ¡ALERTA CRÍTICA! Base de datos reaccionó al payload.${NC}"
                echo -e "${RED}    Vulnerabilidad de SQL Inyection reportada: '$error'.${NC}"
                log_event "[Web] RIESGO CRÍTICO: SQL Injection basada en error confirmada en $sqli_url. Error devuelto: $error"
                vulnerable=true
                break
            fi
        done
        
        if [ "$vulnerable" = false ]; then
            echo -e "${GREEN}[+] SEGURO. No se detectaron volcados de error SQL en pantalla.${NC}"
        fi
    fi
    echo ""
    read -p "Presiona Enter..."
}

function http_verbs_scanner() {
    echo -e "\n${CYAN}--- Escáner de Métodos HTTP (Verbs Enumeration) ---${NC}"
    echo -e "${YELLOW}Auditoría: Detecta si el servidor permite métodos inseguros (PUT, DELETE, TRACE).${NC}"
    read -p "Introduce URL (ej. https://example.com/): " target_verb
    [[ -z "$target_verb" ]] && return
    
    echo -e "\n${GREEN}[+] Pidiendo al servidor OPTIONS y cabeceras...${NC}"
    if command -v curl >/dev/null 2>&1; then
        local response=$(curl -s -X OPTIONS -I "$target_verb" | grep -i "Allow:")
        
        if [[ -n "$response" ]]; then
            echo -e "\n${CYAN}[*] Métodos permitidos por el servidor:${NC}"
            
            # Formatear salida y buscar peligros
            local methods=$(echo "$response" | cut -d':' -f2 | tr -d '\r\n')
            echo -e "${LIGHT_GREEN}$methods${NC}"
            log_event "[Web] Auditoría OPTIONS en $target_verb - Métodos HTTP descubiertos: $methods"
            
            if echo "$methods" | grep -qE "PUT|DELETE|TRACE"; then
                echo -e "\n${RED}[!] RIESGO DE CONFIGURACIÓN DETECTADO:${NC}"
                log_event "[Web] ALERTA: Servidor expone métodos críticos (PUT/DELETE/TRACE)."
                echo "$methods" | grep -q "PUT"    && echo -e "    -> ${PURPLE}PUT habilitado (Posible subida de archivos arbitraria).${NC}"
                echo "$methods" | grep -q "DELETE" && echo -e "    -> ${PURPLE}DELETE habilitado (Posible borrado remoto de recursos).${NC}"
                echo "$methods" | grep -q "TRACE"  && echo -e "    -> ${PURPLE}TRACE habilitado (Riesgo de Cross-Site Tracing).${NC}"
            else
                echo -e "\n${GREEN}[+] Correcto. Sin métodos peligrosos visibles.${NC}"
            fi
        else
            echo -e "${RED}[!] El servidor no responde a peticiones HTTP OPTIONS.${NC}"
        fi
    fi
    echo ""
    read -p "Presiona Enter..."
}
