#!/bin/bash

# Función para validar IP
function validate_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then return 0; else return 1; fi
}

function scan_ports() {
    echo -e "\n${CYAN}--- Escáner TCP Sigiloso ---${NC}"
    read -p "IP del objetivo: " target
    
    if ! validate_ip "$target"; then
        echo -e "${RED}[!] Error: Formato de IP inválido. Riesgo de inyección detectado.${NC}"
        sleep 2
        return
    fi
    echo -e "${YELLOW}[+] Inicializando sondeo silencioso en $target...${NC}"
    log_event "[Red] Iniciando escaneo TCP manual sobre objetivo: $target"
    local ports=(21 22 23 25 53 80 110 135 139 143 443 445 993 995 3306 3389 8080)
    for port in "${ports[@]}"; do
        if timeout 1 bash -c "echo >/dev/tcp/$target/$port" 2>/dev/null; then
            echo -e "${GREEN}[+] PUERTO ABIERTO EXPUESTO: $port${NC}"
            log_event "[Red] PUERTO ABIERTO EXPUESTO EN OBJETIVO: tcp/$port"
        fi
    done
    echo -e "${CYAN}[*] Escaneo términado.${NC}"
    read -p "Presiona Enter..."
}

function red_local() {
    echo -e "\n${CYAN}[!] Analizando topología local (Caché ARP)...${NC}"
    echo -e "${YELLOW}Tablas de enrutamiento detectadas:${NC}"
    local arp_data=$(arp -a)
    echo -e "$arp_data"
    log_event "[Red] Tabla de caché ARP volcada al momento de escaneo:\n$arp_data"
    echo ""
    read -p "Presiona Enter..."
}

function monitor_conexiones() {
    echo -e "\n${CYAN}--- Monitor de Conexiones Activas ---${NC}"
    echo -e "${YELLOW}[*] Buscando conexiones IP establecidas con Nexus...${NC}"
    if command -v netstat >/dev/null 2>&1; then
        local netdata=$(netstat -an | grep ESTABLISHED | head -n 15)
        echo -e "$netdata"
        log_event "[Seguridad] Resumen de monitor de conexiones establecidas (15 registros): \n$netdata"
    else
        echo -e "${RED}[!] Comando netstat desactivado en host.${NC}"
    fi
    echo ""
    read -p "Presiona Enter..."
}

function traceroute_tool() {
    echo -e "\n${CYAN}--- Rastreo de Saltos de Red (Traceroute) ---${NC}"
    read -p "Introduce dominio o IP: " objetivo
    if [[ -n "$objetivo" ]]; then
        echo -e "${YELLOW}[*] Desplegando rastreo hacia $objetivo ...${NC}"
        log_event "[Red] Solicitud de Traceroute hacia IP/Dominio: $objetivo"
        if command -v tracert >/dev/null 2>&1; then
            tracert -d -w 500 -h 15 "$objetivo" | tee -a "$SESSION_REPORT"
        elif command -v traceroute >/dev/null 2>&1; then
            traceroute -m 15 -w 1 "$objetivo" | tee -a "$SESSION_REPORT"
        else
            echo -e "${RED}[!] Utils faltantes en kernel.${NC}"
        fi
    fi
    echo ""
    read -p "Presiona Enter..."
}

function subnet_calc() {
    echo -e "\n${CYAN}--- Calculadora Vectorial de Subredes ---${NC}"
    read -p "Introduce IP con máscara CIDR (ej: 192.168.1.0/24): " ip_cidr
    if [[ "$ip_cidr" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$ ]]; then
        local mask="${ip_cidr#*/}"
        if [[ $mask -gt 32 ]]; then
            echo -e "${RED}[!] Error: La máscara no puede superar /32.${NC}"
        else
            echo -e "\n${YELLOW}[*] Computando red:${NC}"
            local hosts=$(( (1 << (32 - mask)) - 2 ))
            [[ $hosts -lt 0 ]] && hosts=0
            echo -e "Bloque Red CIDR: ${GREEN}/$mask${NC}"
            echo -e "Nodos Usables:   ${GREEN}$hosts${NC}"
            log_event "[Red] CIDR $ip_cidr procesado: Bloque /$mask con $hosts host(s) en subred local."
        fi
    else
        echo -e "${RED}[!] CIDR Rechazado.${NC}"
    fi
    echo ""
    read -p "Presiona Enter..."
}

function process_manager() {
    echo -e "\n${CYAN}--- Gestor de Procesos en Ejecución ---${NC}"
    echo -e "${YELLOW}[*] Análisis de memoria en host nativo:${NC}"
    if command -v ps >/dev/null 2>&1; then
        ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 11
    elif command -v tasklist >/dev/null 2>&1; then
        tasklist | head -n 15
    fi
    
    echo -e "\n${YELLOW}Acciones Tácticas:${NC}"
    echo -e "1) Destruir árbol de procesos (Por PID)"
    echo -e "2) Regresar"
    read -p "> " p_opcion
    if [[ "$p_opcion" == "1" ]]; then
        read -p "Introduce PID: " target_pid
        if [[ "$target_pid" =~ ^[0-9]+$ ]]; then
            log_event "[Sistema] Intentando destruir árbol de procesos crítico... PID: $target_pid"
            kill -9 "$target_pid" 2>/dev/null && echo -e "${GREEN}[+] Process Killed.${NC}" || taskkill //F //PID "$target_pid" 2>/dev/null && echo -e "${GREEN}[+] Terminated.${NC}"
        fi
    fi
    echo ""
    read -p "Presiona Enter..."
}

function analisis_metadatos() {
    echo -e "\n${CYAN}--- Forensics: Extractor de Metadatos ---${NC}"
    read -p "Ruta a archivo objetivo: " archivo
    if [[ -f "$archivo" ]]; then
        echo -e "\n${GREEN}[+] Scraping $archivo ...${NC}"
        log_event "[Forense] Evaluando metadatos estructurados en archivo local ( $archivo )"
        if command -v strings >/dev/null 2>&1; then
            local strdata=$(strings "$archivo" | grep -iE "(software|creator|date|author|c:\\\\|http)" | head -n 15)
            echo -e "$strdata"
            log_event "[Forense] Extracción de Metadatos completada con posibles hits: \n$strdata"
        else
            head -c 200 "$archivo" | tr -cd '\11\12\15\40-\176'
        fi
    else
        echo -e "${RED}[!] Archivo ausente.${NC}"
    fi
    echo ""
    read -p "Presiona Enter..."
}

function escaner_backdoors() {
    echo -e "\n${CYAN}--- Detector Rápido de Troyanos/Rootkits ---${NC}"
    if command -v netstat >/dev/null 2>&1; then
        local net_output=$(netstat -an | grep -iE "LISTEN|ESCUCHAR")
        echo -e "${GREEN}[+] Escaneando puertas traseras comunes a la escucha...${NC}"
        for badport in 1337 31337 4444 666 4156; do
            if echo "$net_output" | grep -q ":$badport "; then
                echo -e "${RED}    [CRÍTICO] Puerto malicioso $badport está EXPUESTO en LISTEN! Posible intruso.${NC}"
                log_event "[Seguridad] ¡ALERTA ROJA! Un puerto típico de Troyano/Malware ($badport) ha sido detectado EN ESCUCHA ABIERTA en localhost!"
            fi
        done
        echo -e "\n${YELLOW}[*] Top 10 Enlaces de Recepción Actuales:${NC}"
        echo "$net_output" | head -n 10
    else
        echo -e "${RED}[!] Permisos o binarios faltantes.${NC}"
    fi
    echo ""
    read -p "Presiona Enter..."
}

function auditoria_permisos() {
    echo -e "\n${CYAN}--- Auditoría de Permisos SUID/777 ---${NC}"
    if command -v find >/dev/null 2>&1 && [[ "$(uname -o 2>/dev/null || uname -s)" != *"Windows"* ]]; then
        echo -e "\n${RED}[!] Archivos modificables globalmente (777 - Riesgo Inyección):${NC}"
        
        local p_777=$(find . -type f -perm 0777 2>/dev/null | head -n 5)
        if [[ -n "$p_777" ]]; then
            echo "$p_777"
            log_event "[Auditoría] VULNERABILIDAD LOCAL: Archivos con permisos de modificación globales (777):\n$p_777"
        else
            echo "  Cero."
        fi
        
        echo -e "\n${RED}[!] Archivos con herencia de permisos escalados (SUID):${NC}"
        local p_suid=$(find . -type f -perm -4000 2>/dev/null | head -n 5)
        if [[ -n "$p_suid" ]]; then
             echo "$p_suid"
             log_event "[Auditoría] RIESGO SUID ESCALABLE DETECTADO:\n$p_suid"
        else
             echo "  Cero."
        fi
    else
        echo -e "${YELLOW}[!] Escaneo bloqueado: el entorno no maneja permisos SUID POSIX.${NC}"
    fi
    echo ""
    read -p "Presiona Enter..."
}

function hw_profiler() {
    echo -e "\n${CYAN}--- Analizador Avanzado de Hardware ---${NC}"
    echo -e "${YELLOW}[*] Extrayendo metadatos físicos de la terminal local...${NC}\n"

    # CPU
    echo -e "${LIGHT_GREEN}>> PROCESADOR (CPU):${NC}"
    if command -v lscpu >/dev/null 2>&1; then
        lscpu | grep -iE "(Model name|Architecture|CPU MHz|CPU\(s\))" | sed 's/^/   /'
    elif command -v wmic >/dev/null 2>&1; then
        wmic cpu get name,NumberOfCores,NumberOfLogicalProcessors /format:list 2>/dev/null | grep "=" | sed 's/^/   /'
    elif [[ -f /proc/cpuinfo ]]; then
        grep -i "model name" /proc/cpuinfo | head -n 1 | sed 's/^/   /'
        echo "   Cores: $(grep -c processor /proc/cpuinfo)"
    else
        echo "   [!] Datos de CPU no disponibles."
    fi

    # RAM
    echo -e "\n${LIGHT_GREEN}>> MEMORIA RAM (${NC}Libre / Total${LIGHT_GREEN}):${NC}"
    if command -v free >/dev/null 2>&1; then
        free -h | grep -iE "^(Mem|Swap):" | sed 's/^/   /'
    elif command -v wmic >/dev/null 2>&1; then
        local total_ram=$(wmic computersystem get TotalPhysicalMemory /Value 2>/dev/null | grep -o "[0-9]\+")
        if [[ -n "$total_ram" ]]; then
            echo "   Capacidad Física Total: $(($total_ram / 1024 / 1024)) MB"
        else
            echo "   [!] Datos de RAM no disponibles."
        fi
    else
        echo "   [!] Datos de RAM no disponibles."
    fi

    # DISK
    echo -e "\n${LIGHT_GREEN}>> ALMACENAMIENTO LÓGICO:${NC}"
    if command -v df >/dev/null 2>&1; then
        df -h | grep -vE "^(tmp|dev|run)" | head -n 6 | awk '{print "   Montaje: "$6" | Tamaño: "$2" | Usado: "$5}'
    else
        echo "   [!] Datos de Disco no disponibles."
    fi

    echo ""
    read -p "Presiona Enter..."
}

function hosts_auditor() {
    echo -e "\n${CYAN}--- Auditor DNS del Archivo Hosts ---${NC}"
    echo -e "${YELLOW}Auditoría: Buscando redirecciones estáticas anómalas (Posible DNS Hijacking).${NC}\n"

    local hosts_file="/etc/hosts"
    [[ "$(uname -o 2>/dev/null || uname -s)" == *"Windows"* || "$(uname -a)" == *"MINGW"* || "$(uname -a)" == *"CYGWIN"* || "$(uname -a)" == *"MSYS"* ]] && hosts_file="C:\\Windows\\System32\\drivers\\etc\\hosts"
    
    # WSL usually maps C: to /mnt/c
    [[ -d "/mnt/c/Windows/System32/drivers/etc" ]] && hosts_file="/mnt/c/Windows/System32/drivers/etc/hosts"

    if [[ -f "$hosts_file" ]]; then
        echo -e "${GREEN}[+] Archivo localizado: $hosts_file${NC}"
        echo -e "${YELLOW}[*] Reglas personalizadas detectadas:${NC}"
        # Leer e imprimir lineas que no sean comentarios o vacias, ni sean localhost generico
        grep -vE "^#|^$" "$hosts_file" | grep -vE "127.0.0.1[[:space:]]+localhost|::1[[:space:]]+localhost" > /tmp/mal_hosts.txt
        
        if [[ -s /tmp/mal_hosts.txt ]]; then
            echo -e "${RED}[!] PRECAUCIÓN: Se encontraron mapeos forzados de red. Verifica si son legítimos:${NC}"
            cat /tmp/mal_hosts.txt | sed 's/^/   /'
        else
            echo -e "${LIGHT_GREEN}[+] Archivo limpio. Solo configuraciones nativas estándar detectadas.${NC}"
        fi
        rm -f /tmp/mal_hosts.txt
    else
        echo -e "${RED}[!] No se pudo localizar o leer el archivo hosts del sistema (Se requiere Admin/Root).${NC}"
    fi

    echo ""
    read -p "Presiona Enter..."
}

function iface_analyzer() {
    echo -e "\n${CYAN}--- Analizador de Interfaces Físicas de Red ---${NC}"
    echo -e "${YELLOW}Hardware: Listado rápido de tarjetas de red, MACs y estados de enlace.${NC}\n"

    if command -v ip >/dev/null 2>&1; then
        ip -br link show | awk '{print "   [+] Interfaz: "$1" | MAC: "$3" | Estado: "$2}'
        echo -e "\n${CYAN}[*] Direccionamiento IP Local:${NC}"
        ip -br addr show | awk '{print "   [-] "$1" -> "$3}'
    elif command -v ifconfig >/dev/null 2>&1; then
        ifconfig | grep -E "^[a-zA-Z0-9]+:|inet |ether " | sed 's/^/   /'
    elif command -v ipconfig >/dev/null 2>&1; then
        ipconfig /all | grep -iE "(Adapter|Física|IPv4|Subnet|Puerta)" | sed 's/^/   /'
    else
         echo -e "${RED}[!] Comandos de lectura de enlaces inhabilitados en el Kernel actual.${NC}"
    fi
    echo ""
    function mac_changer() {
    echo -e "\n${CYAN}--- Evasión: MAC Address Spoofer ---${NC}"
    echo -e "${YELLOW}Anonimato: Cambia la dirección física de tu tarjeta de red.${NC}"
    if command -v macchanger >/dev/null 2>&1; then
        read -p "Introduce tu interfaz de red (ej. eth0, wlan0): " interfaz
        [[ -z "$interfaz" ]] && return
        
        echo -e "\n${GREEN}[+] Apagando la interfaz $interfaz...${NC}"
        sudo ip link set dev "$interfaz" down
        
        echo -e "${GREEN}[+] Falsificando dirección MAC a una aleatoria...${NC}"
        sudo macchanger -r "$interfaz" | grep -i "New MAC"
        
        echo -e "${GREEN}[+] Levantando la interfaz...${NC}"
        sudo ip link set dev "$interfaz" up
        log_event "[Red] Spoofing de MAC ejecutado en la interfaz $interfaz."
    else
        echo -e "${RED}[!] La herramienta 'macchanger' no está instalada. Ejecuta: sudo apt install macchanger${NC}"
    fi
    echo ""
    read -p "Presiona Enter..."
}

function privesc_check() {
    echo -e "\n${CYAN}--- Escáner Rápido de Escalamiento de Privilegios ---${NC}"
    echo -e "${YELLOW}Auditoría: Buscando vectores para escalar a ROOT...${NC}\n"
    
    echo -e "${LIGHT_GREEN}[*] Verificando permisos SUDO sin contraseña:${NC}"
    sudo -l 2>/dev/null | grep "NOPASSWD" || echo "  Ninguno o requiere contraseña."
    
    echo -e "\n${LIGHT_GREEN}[*] Verificando acceso al archivo /etc/shadow (Hashes):${NC}"
    if [ -r /etc/shadow ]; then
        echo -e "  ${RED}[CRÍTICO] ¡El archivo /etc/shadow es legible por tu usuario!${NC}"
        log_event "[Sistema] VULNERABILIDAD: /etc/shadow es legible sin root."
    else
        echo "  Protegido (Seguro)."
    fi

    echo -e "\n${LIGHT_GREEN}[*] Verificando Tareas Cron globales expuestas:${NC}"
    cat /etc/crontab 2>/dev/null | grep -v "^#" | grep -v "^$" | head -n 5 || echo "  Sin acceso o vacío."
    
    echo ""
    read -p "Presiona Enter..."
}

function cron_auditor() {
    echo -e "\n${CYAN}--- Auditor de Tareas Programadas (Cronjobs) ---${NC}"
    echo -e "${YELLOW}Auditoría: Buscando persistencia silenciosa o binarios sospechosos.${NC}"
    
    if command -v crontab >/dev/null 2>&1; then
        echo -e "\n${LIGHT_GREEN}[*] Crontab del usuario actual:${NC}"
        crontab -l 2>/dev/null | grep -v "^#" || echo "  No hay tareas programadas."
    elif command -v schtasks >/dev/null 2>&1; then
        echo -e "\n${LIGHT_GREEN}[*] Tareas programadas ejecutándose localmente (Windows):${NC}"
        schtasks /query /fo LIST 2>/dev/null | grep -iE "TaskName|Ejecutar|RunTime" | head -n 30
    else
        echo -e "${RED}[!] Comandos no detectados o permisos denegados.${NC}"
    fi
    echo ""
    read -p "Presiona Enter..."
}

function file_shredder() {
    echo -e "\n${CYAN}--- File Shredder Destructor (Anti-Forense) ---${NC}"
    echo -e "${YELLOW}Advertencia: Esto borrará un archivo irremediablemente sobreescribiendo sus bloques 3 veces.${NC}"
    read -p "Ruta absoluta del archivo a destruir: " file_path
    if [[ -f "$file_path" ]]; then
        local size=$(wc -c < "$file_path" 2>/dev/null || echo "1024")
        echo -e "${RED}[!] Iniciando sobrescritura de nivel bélico sobre $file_path (Múltiples pasadas)...${NC}"
        
        for p in {1..3}; do
            echo -e "${YELLOW}    -> Pasada $p/3 en progreso...${NC}"
            if command -v shred >/dev/null 2>&1; then
                shred -n 1 "$file_path" 2>/dev/null
            else
                cat /dev/urandom | head -c "$size" > "$file_path" 2>/dev/null || echo "1" > "$file_path"
            fi
            sleep 0.5
        done
        rm -f "$file_path" 2>/dev/null
        log_event "[Seguridad] Archivo $file_path DESTRUIDO satisfactoriamente vía Wiping extremo."
        echo -e "${GREEN}[+] Archivo desintegrado y eliminado del índice con éxito.${NC}"
    else
        echo -e "${RED}[!] El archivo no existe o no se puede acceder a la ruta apuntada.${NC}"
    fi
    echo ""
    read -p "Presiona Enter..."
}

function ping_sweeper() {
    echo -e "\n${CYAN}--- Ping Sweeper (Descubrimiento Activo) ---${NC}"
    echo -e "${YELLOW}Envía ráfagas ICMP a toda una clase C para ver quién está vivo.${NC}"
    read -p "Introduce el prefijo de tu red (ej. 192.168.1): " network
    [[ -z "$network" ]] && return
    
    echo -e "\n${GREEN}[+] Sondeando red $network.1 - 254 ...${NC}"
    log_event "[Red] Empezando Sweep de Ping interactivo hacia la red $network.*"
    local count=0
    
    # Check OS env for correct ping loop timeout
    local is_win=false
    if [[ "$(uname -o 2>/dev/null || uname -s)" == *"Windows"* || "$(uname -a)" == *"MINGW"* || "$(uname -a)" == *"CYGWIN"* || "$(uname -a)" == *"MSYS"* ]]; then
        is_win=true
    fi

    # Lógica pseudo-paralela en bash nativo
    for ip in {1..254}; do
        local target="${network}.${ip}"
        if [ "$is_win" = true ]; then
            ping -n 1 -w 200 "$target" >/dev/null 2>&1 && { echo -e "${LIGHT_GREEN}[+] HOST VIVO DETECTADO:${NC} $target"; } &
        else
            ping -c 1 -W 1 "$target" >/dev/null 2>&1 && { echo -e "${LIGHT_GREEN}[+] HOST VIVO DETECTADO:${NC} $target"; } &
        fi
    done
    wait # Hold until all background pings exit
    
    echo -e "\n${CYAN}[*] Escaneo términado.${NC}"
    read -p "Presiona Enter..."
}

function mac_spoofer() {
    echo -e "\n${CYAN}--- Cambiador de MAC (Spoofing Físico) ---${NC}"
    echo -e "${YELLOW}Esta herramienta requiere modificar enlaces a nivel ROOT (Linux/macOS).${NC}"
    read -p "Nombre de la interfaz (ej. eth0, wlan0): " iface
    [[ -z "$iface" ]] && return
    
    # Genera MAC aleatoria válida local Unicast
    local hexchars=(0 1 2 3 4 5 6 7 8 9 a b c d e f)
    local m1=${hexchars[$((RANDOM%16))]}; local m2="2" # X2, X6, XA, XE is locally administered 
    local new_mac="${m1}${m2}:$(printf '%02x:%02x:%02x:%02x:%02x\n' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))"
    
    echo -e "${GREEN}[+] Solicitando cambio a MAC aleatoria: ${LIGHT_GREEN}$new_mac${NC}"
    if command -v macchanger >/dev/null 2>&1; then
        macchanger -m "$new_mac" "$iface" 2>/dev/null && echo -e "${GREEN}[+] MAC Modificada con éxito.${NC}" || echo -e "${RED}[!] Permiso denegado.${NC}"
    elif command -v ip >/dev/null 2>&1; then
        ip link set dev "$iface" down 2>/dev/null
        ip link set dev "$iface" address "$new_mac" 2>/dev/null
        ip link set dev "$iface" up 2>/dev/null
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}[+] Nueva MAC enlazada estáticamente en $iface.${NC}"
            log_event "[Red] Spoofer MAC ejecutado. Nueva identidad hardware: $new_mac"
        else
            echo -e "${RED}[!] Falló el cambio de identidad (¿Interfaz ocupada o permisos insuficientes?).${NC}"
        fi
    else
        echo -e "${RED}[!] Herramienta no disponible en este SO.${NC}"
    fi
    echo ""
    read -p "Presiona Enter..."
}