#!/bin/bash

function password_gen() {
    echo -e "\n${CYAN}--- Generador de Contraseñas Seguras ---${NC}"
    read -p "Longitud de la contraseña (por defecto 16): " len
    [[ -z "$len" ]] && len=16
    if [[ ! "$len" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}[!] Número inválido.${NC}"
        sleep 1; return
    fi
    echo -e "${YELLOW}[*] Generando entropía criptográfica ($len caractéres)...${NC}"
    local pass=$(openssl rand -base64 48 2>/dev/null | tr -dc 'a-zA-Z0-9!@#$%^&*()_+-=' | head -c "$len")
    [[ -z "$pass" ]] && pass=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&*()_+-=' | fold -w 256 | head -n 1 | head -c "$len")
    
    echo -e "${GREEN}[+] Contraseña generada: ${LIGHT_GREEN}$pass${NC}"
    echo ""
    read -p "Presiona Enter..."
}

function hash_calculator() {
    echo -e "\n${CYAN}--- Calculadora de Hashes ---${NC}"
    read -p "Introduce el texto a procesar: " texto
    if [[ -n "$texto" ]]; then
        echo -e "\n${YELLOW}[*] Resultados Criptográficos:${NC}"
        if command -v md5sum >/dev/null 2>&1; then
            echo -e "MD5:    ${GREEN}$(echo -n "$texto" | md5sum | awk '{print $1}')${NC}"
            echo -e "SHA256: ${GREEN}$(echo -n "$texto" | sha256sum | awk '{print $1}')${NC}"
        else
            echo -e "${RED}[!] Utilidad md5sum no disponible en esta shell.${NC}"
        fi
    fi
    echo ""
    read -p "Presiona Enter..."
}

function base64_tool() {
    echo -e "\n${CYAN}--- Cifrado/Descifrado Base64 ---${NC}"
    echo -e "1) Codificar texto"
    echo -e "2) Decodificar texto"
    read -p "> " opcion_b64
    
    read -p "Introduce la cadena: " b64_texto
    if [[ "$opcion_b64" == "1" ]]; then
        echo -e "\n${GREEN}[+] Texto codificado:${NC} $(echo -n "$b64_texto" | base64)"
    elif [[ "$opcion_b64" == "2" ]]; then
        local decoded=$(echo -n "$b64_texto" | base64 -d 2>/dev/null)
        if [[ -n "$decoded" ]]; then
            echo -e "\n${GREEN}[+] Texto decodificado:${NC} $decoded"
        else
            echo -e "\n${RED}[!] Error: La cadena no parece ser Base64 válida.${NC}"
        fi
    fi
    echo ""
    read -p "Presiona Enter..."
}

function ssh_key_generator() {
    echo -e "\n${CYAN}--- Generador de Claves ED25519 (Secure SSH) ---${NC}"
    echo -e "${YELLOW}Criptografía: Forja un par de llaves asimétricas robustas para autenticación.${NC}"
    
    if command -v ssh-keygen >/dev/null 2>&1; then
        read -p "Introduce un perfil/comentario (ej. admin@servidor): " comentario
        [[ -z "$comentario" ]] && comentario="nexus-key"
        
        local key_path="$HOME/.ssh/nexus_${comentario}"
        if [[ -f "$key_path" ]]; then
             echo -e "${RED}[!] Ya existe una llave con ese perfil: $key_path${NC}"
        else
             echo -e "\n${GREEN}[+] Forjando par de llaves criptográficas (Algoritmo: ED25519)...${NC}"
             mkdir -p "$HOME/.ssh"
             ssh-keygen -t ed25519 -C "$comentario" -f "$key_path" -N "" -q 2>/dev/null
             
             if [[ -f "${key_path}.pub" ]]; then
                 echo -e "${LIGHT_GREEN}[+] CLAVE PRIVADA guardada en: ${NC}$key_path"
                 echo -e "${GREEN}[+] CLAVE PÚBLICA (Para exportar al servidor): ${NC}${key_path}.pub"
                 echo -e "\n${CYAN}Huella de firma pública:${NC}"
                 cat "${key_path}.pub"
             else
                 echo -e "${RED}[!] Error durante la generación.${NC}"
             fi
        fi
    else
        echo -e "${RED}[!] SSH-KEYGEN no está nativamente instalado en este host.${NC}"
    fi
    echo ""
    read -p "Presiona Enter..."
}
