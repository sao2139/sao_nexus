#!/bin/bash

# --- MÓDULO OSINT & RECONOCIMIENTO (DEFENSIVO) ---

function dns_lookup() {
    echo -e "\n${CYAN}--- Inteligencia de Dominios y DNS ---${NC}"
    read -p "Introduce el dominio (ej. google.com): " dominio
    if [[ -n "$dominio" ]]; then
        echo -e "\n${YELLOW}[*] Buscando registros A y CNAME de $dominio :${NC}"
        if command -v nslookup >/dev/null 2>&1; then
            local dns_res=$(nslookup "$dominio" | grep -A 2 'Name\|Nombre' || nslookup "$dominio")
            echo -e "$dns_res"
            log_event "[OSINT] DNS Lookup ejecutado sobre $dominio. Resultados: \n$dns_res"
        elif command -v ping >/dev/null 2>&1; then
            if [[ "$(uname -o 2>/dev/null || uname -s)" == *"Windows"* || "$(uname -a)" == *"MINGW"* || "$(uname -a)" == *"MSYS"* || "$(uname -a)" == *"CYGWIN"* ]]; then
                local ping_res=$(ping -n 1 "$dominio" 2>&1 | head -n 2 | tail -n 1)
            else
                local ping_res=$(ping -c 1 "$dominio" 2>&1 | head -n 1)
            fi
            echo -e "$ping_res"
            log_event "[OSINT] Ping a $dominio devuelto: \n$ping_res"
        else
            echo -e "${RED}[!] Herramientas de red DNS no encontradas.${NC}"
        fi
    fi
    echo ""
    read -p "Presiona Enter..."
}

function ip_geolocation() {
    echo -e "\n${CYAN}--- IP Geolocation Tracker (OSINT) ---${NC}"
    echo -e "${YELLOW}Obtén datos geográficos desde una base de datos pública de ISPs.${NC}"
    read -p "Introduce la IP pública objetivo (vacío para tu propia IP externa): " ip_obj
    
    echo -e "\n${YELLOW}[*] Triangulando coordenadas lógicas...${NC}"
    if command -v curl >/dev/null 2>&1; then
        local response=$(curl -s "http://ip-api.com/line/$ip_obj")
        if echo "$response" | grep -q "success"; then
            echo -e "${GREEN}[+] Datos IP extraídos con éxito:${NC}"
            local geo_data=$(echo "$response" | awk 'NR==2{print "País:          "$0} NR==5{print "Ciudad:        "$0} NR==6{print "Código Postal: "$0} NR==8{print "Latitud:       "$0} NR==9{print "Longitud:      "$0} NR==11{print "ISP Org:       "$0}')
            echo -e "$geo_data"
            log_event "[OSINT] Geolocalización exitosa de la IP ($ip_obj): \n$geo_data"
        else
            echo -e "${RED}[!] Error: IP inválida, reservada o servicio API caído.${NC}"
        fi
    else
        echo -e "${RED}[!] Curl no disponible.${NC}"
    fi
    echo ""
    read -p "Presiona Enter..."
}

function auditoria_cabeceras() {
    echo -e "\n${CYAN}--- Auditoría de Cabeceras HTTP (Header Audit) ---${NC}"
    echo -e "${YELLOW}Verifica si un servidor web remoto implementa cabeceras de seguridad modernas.${NC}"
    read -p "Introduce URL pública (ej. https://example.com): " url_http
    
    if [[ -z "$url_http" || "$url_http" != http* ]]; then
        echo -e "${RED}[!] URL no válida. Asegúrate de incluir http:// o https://${NC}"
        sleep 2
        return
    fi
    
    echo -e "\n${GREEN}[+] Analizando headers de $url_http ...${NC}"
    if command -v curl >/dev/null 2>&1; then
        local headers=$(curl -s --head --insecure "$url_http")
        if [[ -z "$headers" ]]; then
            echo -e "${RED}[!] El servidor no responde o conexion denegada.${NC}"
        else
            echo "$headers" > /tmp/headers.txt
            
            if grep -qi "Server" /tmp/headers.txt; then
                local srv_name=$(grep -i "Server" /tmp/headers.txt | cut -d ' ' -f2-)
                echo -e "${CYAN}Servidor Base detectado:${NC} $srv_name"
                log_event "[Red] Firma del Servidor Web remoto identificada ($url_http): $srv_name"
            fi
            
            echo -e "\n${YELLOW}Evaluación de Cabeceras (Ausencia = Riesgo Pasivo):${NC}"
            grep -qi "Strict-Transport-Security" /tmp/headers.txt && echo -e "HSTS (Anti-Downgrade): ${GREEN}[OK]${NC}" || { echo -e "HSTS (Anti-Downgrade): ${RED}[VULNERABLE - Null]${NC}"; log_event "[Auditoría] $url_http NO tiene HSTS implementado."; }
            grep -qi "X-Frame-Options" /tmp/headers.txt && echo -e "Anti-Clickjacking:     ${GREEN}[OK]${NC}" || { echo -e "Anti-Clickjacking:     ${RED}[VULNERABLE - Null]${NC}"; log_event "[Auditoría] $url_http NO tiene X-Frame-Options implementado."; }
            grep -qi "Content-Security-Policy" /tmp/headers.txt && echo -e "CSP (Anti-XSS):        ${GREEN}[OK]${NC}" || { echo -e "CSP (Anti-XSS):        ${RED}[VULNERABLE - Null]${NC}"; log_event "[Auditoría] $url_http NO tiene Content-Security-Policy (CSP)."; }
            
            rm /tmp/headers.txt
        fi
    else
        echo -e "${RED}[!] Comando 'curl' necesario.${NC}"
    fi
    echo ""
    read -p "Presiona Enter..."
}

function banner_grabbing() {
    echo -e "\n${CYAN}--- Banner Grabbing Remoto ---${NC}"
    echo -e "${YELLOW}Interacción pasiva con puertos cerrados para descubrir versiones de software vulnerable.${NC}"
    read -p "IP/Dominio objetivo: " obj
    read -p "Puerto de red (ej. 21, 22, 80): " prt
    
    if [[ "$prt" =~ ^[0-9]+$ ]]; then
        echo -e "\n${GREEN}[+] Intentando capturar handshake del puerto $prt ...${NC}"
        # Sigiloso con timeout (no generamos ruido nmap)
        local banner=$(timeout 2 bash -c "echo '' > /dev/tcp/$obj/$prt && cat < /dev/tcp/$obj/$prt" 2>/dev/null | head -n 3)
        
        if [[ -n "$banner" ]]; then
            echo -e "${LIGHT_GREEN}--- BANNER IDENTIFICADO ---${NC}"
            echo -e "$banner"
            echo -e "${LIGHT_GREEN}---------------------------${NC}"
            log_event "[Red] Extracción de Banner exitosa en host $obj (tcp/$prt): \n$banner"
        else
            echo -e "${RED}[!] Sin banner. Sistema fortificado, timeout, o puerto cerrado.${NC}"
        fi
    else
        echo -e "${RED}[!] Puerto inválido.${NC}"
    fi
    echo ""
    read -p "Presiona Enter..."
}

function spider_osint() {
    echo -e "\n${CYAN}--- Web Scraper Forense (Email & Link Hunter) ---${NC}"
    echo -e "${YELLOW}Extrae dominios ocultos y correos filtrados de un sitio en vivo de forma anónima.${NC}"
    read -p "URL objetivo: " site
    [[ -z "$site" ]] && return
    
    if command -v curl >/dev/null 2>&1; then
        echo -e "\n${GREEN}[+] Interceptando código fuente DOM...${NC}"
        local content=$(curl -sL --insecure "$site")
        log_event "[OSINT] Scraping finalizado en URL objetivo: $site"
        
        echo -e "\n${YELLOW}[*] Bases de correos identificadas en HTML:${NC}"
        # Aislados strings de texto nativo y limitado
        local emails=$(echo "$content" | grep -a -E -o "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}" | sort -u | head -n 30)
        if [[ -n "$emails" ]]; then
            echo "$emails"
            log_event "[OSINT] Correos extraídos (Filtración):\n$emails"
        else
            echo "  Ninguno listado."
        fi
        
        echo -e "\n${YELLOW}[*] Puntos de inyección / Links Externos (Top 10):${NC}"
        local links=$(echo "$content" | grep -a -o 'href="[^"]*"' | cut -d'"' -f2 | grep -E "^http" | head -n 10)
        if [[ -n "$links" ]]; then
            echo "$links"
            log_event "[OSINT] Top 10 Enlaces encontrados:\n$links"
        else
            echo "  Ninguno listado."
        fi
    else
         echo -e "${RED}[!] Necesitas CURL instalado en el sistema.${NC}"
    fi
    echo ""
    read -p "Presiona Enter..."
}

function subdomain_enum() {
    echo -e "\n${CYAN}--- OSINT: Enumeración Pasiva de Subdominios ---${NC}"
    echo -e "${YELLOW}Consulta servidores CTR públicos para rastrear infraestructura del objetivo sin tocarlo.${NC}"
    read -p "Introduce el dominio principal (ej. microsoft.com): " dom_obj
    [[ -z "$dom_obj" ]] && return
    
    echo -e "\n${GREEN}[+] Interrogando bases de datos de certificados digitales (crt.sh)...${NC}"
    if command -v curl >/dev/null 2>&1; then
        local response=$(curl -s "https://crt.sh/?q=%25.$dom_obj&output=json" | grep -Po '(?<="name_value":")[^"]*' | sort -u)
        
        if [[ -n "$response" ]]; then
            echo -e "\n${LIGHT_GREEN}--- SUBDOMINIOS ENCONTRADOS ---${NC}"
            # Mostrar los primeros 20 subdominios para no colapsar la pantalla
            echo "$response" | head -n 20
            
            local total=$(echo "$response" | wc -l)
            if [[ $total -gt 20 ]]; then
                echo -e "${CYAN} ... y $(( total - 20 )) más.${NC}"
                echo "$response" > "/tmp/${dom_obj}_subs.txt"
                echo -e "${GREEN}[+] Guardado completo en /tmp/${dom_obj}_subs.txt${NC}"
                log_event "[OSINT] Explotación pasiva completada: $total subdominios encontrados para $dom_obj. Fueron escritos al disco o reporte."
            else
                log_event "[OSINT] Subdominios descubiertos para $dom_obj:\n$response"
            fi
            echo -e "${LIGHT_GREEN}-------------------------------${NC}"
        else
            echo -e "${RED}[!] No hay subdominios indexados en los registros de transparencia para este dominio.${NC}"
        fi
    else
         echo -e "${RED}[!] Necesitas CURL instalado en el sistema.${NC}"
    fi
    echo ""
    read -p "Presiona Enter..."
}

function whois_lookup() {
    echo -e "\n${CYAN}--- Consulta WHOIS de Dominio (OSINT) ---${NC}"
    echo -e "${YELLOW}Inteligencia: Extrae datos del registrador y fechas críticas del dominio.${NC}"
    read -p "Introduce el dominio (ej. example.com): " dominio
    [[ -z "$dominio" ]] && return
    
    if command -v whois >/dev/null 2>&1; then
        echo -e "\n${GREEN}[+] Extrayendo registros WHOIS de la base de datos global...${NC}"
        local whois_data=$(whois "$dominio" | grep -iE "^(Domain Name|Registrar|Creation Date|Updated Date|Registry Expiry Date|Name Server)" | sort -u)
        
        if [[ -n "$whois_data" ]]; then
            echo -e "${LIGHT_GREEN}$whois_data${NC}"
            log_event "[OSINT] WHOIS ejecutado sobre $dominio:\n$whois_data"
        else
            echo -e "${RED}[!] No se encontraron registros o el TLD no es soportado.${NC}"
        fi
    else
        echo -e "${RED}[!] El binario 'whois' no está instalado en este entorno.${NC}"
    fi
    echo ""
    read -p "Presiona Enter..."
}

function tech_detector() {
    echo -e "\n${CYAN}--- Detector de Tecnologías y WAF (Fingerprinting) ---${NC}"
    echo -e "${YELLOW}Reconocimiento: Identifica CMS, lenguajes backend y Firewalls (WAF).${NC}"
    read -p "URL objetivo (ej. https://example.com): " tech_url
    [[ -z "$tech_url" ]] && return
    
    echo -e "\n${GREEN}[+] Analizando firmas digitales y cabeceras en $tech_url...${NC}"
    if command -v curl >/dev/null 2>&1; then
        local header_resp=$(curl -s -I --insecure "$tech_url")
        local body_resp=$(curl -s -L --insecure "$tech_url")
        
        echo -e "${CYAN}Resultados del Fingerprinting:${NC}"
        
        # Detección de Firewalls (WAF)
        if echo "$header_resp" | grep -qi "cloudflare"; then echo -e "  ${RED}[!] WAF/CDN Detectado:${NC} Cloudflare"; log_event "[OSINT] WAF Cloudflare detectado en $tech_url"; fi
        if echo "$header_resp" | grep -qi "x-sucuri"; then echo -e "  ${RED}[!] WAF Detectado:${NC} Sucuri"; fi
        
        # Detección de Backend
        if echo "$header_resp" | grep -qi "x-powered-by: PHP"; then echo -e "  ${LIGHT_GREEN}[+] Backend:${NC} PHP"; fi
        if echo "$header_resp" | grep -qi "x-powered-by: Express"; then echo -e "  ${LIGHT_GREEN}[+] Backend:${NC} Node.js (Express)"; fi
        if echo "$header_resp" | grep -qi "x-aspnet-version"; then echo -e "  ${LIGHT_GREEN}[+] Backend:${NC} ASP.NET"; fi
        
        # Detección de CMS
        if echo "$body_resp" | grep -qi "wp-content"; then 
            echo -e "  ${LIGHT_GREEN}[+] CMS:${NC} WordPress"
            log_event "[OSINT] CMS WordPress detectado en $tech_url"
        fi
        if echo "$header_resp" | grep -qi "x-generator: Drupal" || echo "$body_resp" | grep -qi "sites/default"; then echo -e "  ${LIGHT_GREEN}[+] CMS:${NC} Drupal"; fi
    else
        echo -e "${RED}[!] Comando 'curl' necesario.${NC}"
    fi
    echo ""
    read -p "Presiona Enter..."
}

function whois_lookup() {
    echo -e "\n${CYAN}--- WHOIS Remoto (Información Registral) ---${NC}"
    read -p "Dominio o IP: " obj_whois
    [[ -z "$obj_whois" ]] && return
    
    echo -e "\n${GREEN}[+] Interrogando bases de datos WHOIS globales...${NC}"
    if command -v whois >/dev/null 2>&1; then
        local raw=$(whois "$obj_whois" | grep -iE "Registrar:|Creation Date:|Registrant Organization:|Name Server:|Status:" | sort -u | head -n 10)
        if [[ -n "$raw" ]]; then
            echo -e "$raw"
            log_event "[OSINT] Whois a $obj_whois completado."
        else
            echo -e "${RED}[-] No hubo respuesta útil del servidor whois local.${NC}"
        fi
    elif command -v curl >/dev/null 2>&1; then
        echo -e "${YELLOW}[*] Usando fallback a API pública (RDAP/HackerTarget)...${NC}"
        local ht_whois=$(curl -s "https://api.hackertarget.com/whois/?q=$obj_whois" | grep -iE "registrar|creation|organization" | head -n 12)
        if [[ -n "$ht_whois" && "$ht_whois" != *"error"* ]]; then
            echo -e "$ht_whois"
        else
            echo -e "${RED}[!] Límite de API excedido o datos inaccesibles.${NC}"
        fi
    else
        echo -e "${RED}[!] Whois o Curl no están instalados.${NC}"
    fi
    echo ""
    read -p "Presiona Enter..."
}

function wayback_hunter() {
    echo -e "\n${CYAN}--- Caza-URLs Fantasma (Wayback Machine) ---${NC}"
    echo -e "${YELLOW}Scrapea subdirectorios viejos y ocultos del archivo de internet histórico.${NC}"
    read -p "Dominio (ej. sitio.com): " wb_dom
    [[ -z "$wb_dom" ]] && return
    echo -e "\n${GREEN}[+] Interrogando los archivos de Web Archive...${NC}"
    if command -v curl >/dev/null 2>&1; then
        local w_data=$(curl -s "http://web.archive.org/cdx/search/cdx?url=*.${wb_dom}/*&output=text&fl=original&collapse=urlkey" | head -n 25)
        if [[ -n "$w_data" ]]; then
            echo -e "${LIGHT_GREEN}Historial de Endpoints descubiertos (Primeros 25):${NC}"
            echo "$w_data"
            log_event "[OSINT] Wayback Hunter extrajo posibles endpoints críticos u olvidados para $wb_dom"
        else
            echo -e "${RED}[!] El dominio no tiene capturas públicas indexadas o timeout de conexión.${NC}"
        fi
    fi
    echo ""
    read -p "Presiona Enter..."
}

function email_breach_check() {
    echo -e "\n${CYAN}--- Comprobador de Brechas (XposedOrNot API) ---${NC}"
    read -p "Correo electrónico a auditar: " mail_check
    [[ -z "$mail_check" ]] && return
    echo -e "\n${YELLOW}[*] Validando metadatos de filtración del correo...${NC}"
    if command -v curl >/dev/null 2>&1; then
         local breach_data=$(curl -s -H "Accept: application/json" "https://api.xposedornot.com/v1/check-email/$mail_check")
         if echo "$breach_data" | grep -q 'Error'; then
             echo -e "${GREEN}[+] Seguro. No se encontraron registros públicos masivos de pwn para este correo.${NC}"
         elif echo "$breach_data" | grep -q "breaches"; then
             echo -e "${RED}[!] ALERTA CRÍTICA: El correo aparece en fugas de bases de datos.${NC}"
             local fuentes=$(echo "$breach_data" | grep -oP '"breaches":\[[^]]*\]' 2>/dev/null || echo "$breach_data" | grep -o '"breaches":\[.*\]' | cut -d']' -f1)
             echo -e "${CYAN}Fuentes comprometidas estimadas:${NC} $fuentes"
             log_event "[OSINT] ALERTA DE BRECHA: $mail_check ha sido filtrado en data breaches."
         else
             echo -e "${RED}[!] Error con el servicio API de vulneración.${NC}"
         fi
    fi
    echo ""
    read -p "Presiona Enter..."
}

function reverse_ip_lookup() {
    echo -e "\n${CYAN}--- Escáner de Múltiples Dominios (Reverse IP) ---${NC}"
    echo -e "${YELLOW}Identifica todos los sitios web alojados en un mismo servidor IP de forma pasiva.${NC}"
    read -p "IP del servidor web objetivo: " rev_ip
    [[ -z "$rev_ip" ]] && return
    echo -e "\n${GREEN}[+] Interrogando bases pasivas de resoluciones...${NC}"
    if command -v curl >/dev/null 2>&1; then
        local dominios=$(curl -s "https://api.hackertarget.com/reverseiplookup/?q=$rev_ip" | head -n 15)
        if [[ "$dominios" == *"error"* || "$dominios" == *"API count"* || "$dominios" == *"No DNS"* ]]; then
             echo -e "${RED}[!] Búsqueda sin frutos o límite de API gratuito alcanzado.${NC}"
        else
             echo -e "${CYAN}Dominios virtuales alojados identificados:${NC}"
             echo "$dominios"
             log_event "[OSINT] Reverse IP devuelto para $rev_ip:\n$dominios"
        fi
    fi
    echo ""
    read -p "Presiona Enter..."
}