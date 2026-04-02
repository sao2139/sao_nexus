#!/bin/bash

# Capturar señales (Ctrl+C)
trap "tput cnorm; echo -e '\n\033[0;31m[!] Interrupción detectada. Cortando protocolos...\033[0m'; exit 0" SIGINT SIGTERM

# IMPORTAR LIBRERÍAS DE NEXUS
source core/visuals.sh
source core/logic.sh
source core/osint.sh
source core/web_auditor.sh
source core/crypto.sh
source core/deps.sh
source core/vectors.sh
source core/academy.sh

mkdir -p logs

check_dependencies
setup_logger
animar

opciones=(
    "${PURPLE}[SYS]${NC} Sistema y Privilegios (OS / PrivEsc / Wipe)"
    "${CYAN}[NET]${NC} Redes y Evasión (TCP / MAC Spoofer / Sweep)"
    "${RED}[ATK]${NC} Auditoría Web y Forense (XSS / LFI / CORS)"
    "${LIGHT_GREEN}[OSI]${NC} Inteligencia y OSINT (Breach / Wayback)"
    "${RED}[EXP]${NC} Armería y Vectores (Payloads & Listeners)"
    "${YELLOW}[SEC]${NC} Criptografía y Estenografía (JWT / B64)"
    "${LIGHT_GREEN}[EDU]${NC} Academia y Manuales del Hacker"
    "${NC}[EXIT] Desconexión de Nexus"
)

while true; do
    menu_interactivo "${opciones[@]}"
    eleccion_main=$?

    case $eleccion_main in
        0) 
            menu_sys=(
                "${PURPLE}[SYS]${NC} Recolectar Info Básica SO (uname)"
                "${PURPLE}[SYS]${NC} Analizador Avanzado de Hardware"
                "${PURPLE}[SYS]${NC} Gestor Táctico de Procesos (Kill)"
                "${GREEN}[DEF]${NC} Auditoría de Permisos Inseguros"
                "${RED}[ATK]${NC} Escáner de Escalamiento de Privilegios"
                "${GREEN}[DEF]${NC} Detector de Backdoors Locales"
                "${GREEN}[DEF]${NC} Auditor DNS (Archivo Hosts)"
                "${PURPLE}[SYS]${NC} Auditor de Tareas Programadas (Cronjobs)"
                "${RED}[ATK]${NC} File Shredder (Borrado Seguro)"
                "${NC}[<--] Regresar al Directorio Raíz"
            )
            while true; do
                menu_interactivo "${menu_sys[@]}"
                sub_sel=$?
                case $sub_sel in
                    0) echo -e "\n${YELLOW}[*] Recolectando metadatos SO...${NC}"; uname -a | tee logs/sysinfo.log; sleep 3 ;;
                    1) hw_profiler ;;
                    2) process_manager ;;
                    3) auditoria_permisos ;;
                    4) privesc_check ;;
                    5) escaner_backdoors ;;
                    6) hosts_auditor ;;
                    7) cron_auditor ;;
                    8) file_shredder ;;
                    9) break ;;
                esac
            done
            ;;
        1) 
            menu_net=(
                "${CYAN}[NET]${NC} Escáner de Puertos TCP (Stealth)"
                "${PURPLE}[EVT]${NC} Evasión: MAC Address Spoofer"
                "${CYAN}[NET]${NC} Ping Sweeper (Descubrimiento Activo)"
                "${CYAN}[NET]${NC} Ver Topología de Red Local (ARP)"
                "${CYAN}[NET]${NC} Analizador de Interfaces Físicas"
                "${CYAN}[NET]${NC} Rastreo de Saltos de Red (Traceroute)"
                "${CYAN}[NET]${NC} Calculadora de Subredes Vectorial"
                "${GREEN}[DEF]${NC} Monitor de Conexiones Activas"
                "${NC}[<--] Regresar al Directorio Raíz"
            )
            while true; do
                menu_interactivo "${menu_net[@]}"
                sub_sel=$?
                case $sub_sel in
                    0) scan_ports ;;
                    1) mac_spoofer ;;
                    2) ping_sweeper ;;
                    3) red_local ;;
                    4) iface_analyzer ;;
                    5) traceroute_tool ;;
                    6) subnet_calc ;;
                    7) monitor_conexiones ;;
                    8) break ;;
                esac
            done
            ;;
        2) 
            menu_web=(
                "${RED}[ATK]${NC} Auditor de Rutas Web (Dir-Buster)"
                "${RED}[ATK]${NC} Buscador de Paneles de Administración"
                "${RED}[ATK]${NC} Escáner de Reflejo Básico XSS"
                "${RED}[ATK]${NC} Escáner de LFI (Local File Inclusion)"
                "${RED}[ATK]${NC} Escáner de Inyección SQL (Error)"
                "${RED}[ATK]${NC} Enumerador de Métodos HTTP (Verbs)"
                "${RED}[ATK]${NC} Prueba de Estrés HTTP Local"
                "${RED}[ATK]${NC} Auditor de Configuraciones CORS"
                "${RED}[ATK]${NC} Detector Rápido de Instancias WordPress"
                "${PURPLE}[FRN]${NC} Buscador de Metadatos Forense"
                "${NC}[<--] Regresar al Directorio Raíz"
            )
            while true; do
                menu_interactivo "${menu_web[@]}"
                sub_sel=$?
                case $sub_sel in
                    0) dir_bruteforce ;;
                    1) admin_panel_finder ;;
                    2) xss_scanner ;;
                    3) lfi_scanner ;;
                    4) sqli_prober ;;
                    5) http_verbs_scanner ;;
                    6) stress_test ;;
                    7) cors_misconfig ;;
                    8) wordpress_enum ;;
                    9) analisis_metadatos ;;
                    10) break ;;
                esac
            done
            ;;
        3) 
            menu_osi=(
                "${LIGHT_GREEN}[OSI]${NC} Enumerador Pasivo de Subdominios (CRT)"
                "${LIGHT_GREEN}[OSI]${NC} Búsqueda de Dominios (DNS / Ping)"
                "${LIGHT_GREEN}[OSI]${NC} Inteligencia WHOIS Remota"
                "${LIGHT_GREEN}[OSI]${NC} Geolocalización Avanzada de IPs"
                "${LIGHT_GREEN}[OSI]${NC} Escáner Reverse IP (Dominios Virtuales)"
                "${LIGHT_GREEN}[OSI]${NC} Caza-URLs Fantasma (Wayback Machine)"
                "${LIGHT_GREEN}[OSI]${NC} Auditoría de Brechas (XposedOrNot)"
                "${LIGHT_GREEN}[OSI]${NC} Detector de Tecnologías y WAF"
                "${LIGHT_GREEN}[OSI]${NC} Auditoría de Cabeceras SSL/HTTP"
                "${LIGHT_GREEN}[OSI]${NC} Banner Grabbing Remoto"
                "${LIGHT_GREEN}[OSI]${NC} Web Scraper Clandestino (Correos)"
                "${NC}[<--] Regresar al Directorio Raíz"
            )
            while true; do
                menu_interactivo "${menu_osi[@]}"
                sub_sel=$?
                case $sub_sel in
                    0) subdomain_enum ;;
                    1) dns_lookup ;;
                    2) whois_lookup ;;
                    3) ip_geolocation ;;
                    4) reverse_ip_lookup ;;
                    5) wayback_hunter ;;
                    6) email_breach_check ;;
                    7) tech_detector ;;
                    8) auditoria_cabeceras ;;
                    9) banner_grabbing ;;
                    10) spider_osint ;;
                    11) break ;;
                esac
            done
            ;;
        4)
            menu_exp=(
                "${PURPLE}[EXP]${NC} Generador de Reverse Shells (Bash/Python/PS)"
                "${PURPLE}[EXP]${NC} Creador de Vectores Evasivos SQLi"
                "${PURPLE}[EXP]${NC} Handler TCP Múltiplo (Netcat Listener)"
                "${NC}[<--] Regresar al Directorio Raíz"
            )
            while true; do
                menu_interactivo "${menu_exp[@]}"
                sub_sel=$?
                case $sub_sel in
                    0) reverse_shell_gen ;;
                    1) sql_payload_gen ;;
                    2) listener_wizard ;;
                    3) break ;;
                esac
            done
            ;;
        5) 
            menu_sec=(
                "${YELLOW}[SEC]${NC} Generador de Contraseñas Seguras"
                "${YELLOW}[SEC]${NC} Forjador de Llaves SSH-ED25519"
                "${YELLOW}[SEC]${NC} Calculadora de Integridad (Hashes)"
                "${YELLOW}[SEC]${NC} Cifrador / Descifrador Base64"
                "${YELLOW}[SEC]${NC} Decodificador de Sesiones JWT"
                "${PURPLE}[SEC]${NC} Esteganografía (EOF Append Image)"
                "${NC}[<--] Regresar al Directorio Raíz"
            )
            while true; do
                menu_interactivo "${menu_sec[@]}"
                sub_sel=$?
                case $sub_sel in
                    0) password_gen ;;
                    1) ssh_keypair_gen ;;
                    2) hash_calculator ;;
                    3) base64_tool ;;
                    4) jwt_decoder ;;
                    5) stego_tool ;;
                    6) break ;;
                esac
            done
            ;;
        6) 
            nexus_academy
            ;;
        7) 
            clear
            echo -e "\n${PURPLE}[*] Apagando y destruyendo instancias limpias de memoria...${NC}"
            matrix_rain 2
            clear
            exit 0
            ;;
    esac
done