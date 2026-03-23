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

mkdir -p logs

check_dependencies
setup_logger
animar

opciones=(
    "${PURPLE}[SYS]${NC} Sistema y Gestores (OS / Procesos)"
    "${CYAN}[NET]${NC} Redes y Conectividad (TCP / ARP / Subnet)"
    "${RED}[ATK]${NC} Auditoría Web y Forense (FuerzaB / XSS / Metadatos)"
    "${LIGHT_GREEN}[OSI]${NC} Módulo OSINT e Inteligencia (Scraping / DNS / Geo)"
    "${YELLOW}[SEC]${NC} Criptografía y Seguridad (Hashes / Passwords / B64)"
    "${NC}[EXIT] Desconexión de Nexus"
)

while true; do
    menu_interactivo "${opciones[@]}"
    eleccion_main=$?

    case $eleccion_main in
        0) 
            menu_sys=(
                "${PURPLE}[SYS]${NC} Recolectar Info Básica SO (uname)"
                "${PURPLE}[SYS]${NC} Analizador Avanzado de Hardware (CPU/RAM/Disco)"
                "${PURPLE}[SYS]${NC} Gestor Táctico de Procesos (Top/Kill)"
                "${GREEN}[DEF]${NC} Auditoría de Permisos Inseguros"
                "${GREEN}[DEF]${NC} Detector de Backdoors Locales"
                "${GREEN}[DEF]${NC} Auditor DNS (Archivo Hosts)"
                "${NC}[<--] Regresar al Directorio Raíz"
            )
            while true; do
                menu_interactivo "${menu_sys[@]}"
                sub_sel=$?
                case $sub_sel in
                    0) echo -e "\n${YELLOW}[*] Recolectando metadatos SO...${NC}"; uname -a | tee logs/sysinfo.log; echo -e "${GREEN}[+] Guardado en logs/sysinfo.log${NC}"; sleep 3 ;;
                    1) hw_profiler ;;
                    2) process_manager ;;
                    3) auditoria_permisos ;;
                    4) escaner_backdoors ;;
                    5) hosts_auditor ;;
                    6) break ;;
                esac
            done
            ;;
        1) 
            menu_net=(
                "${CYAN}[NET]${NC} Escáner de Puertos TCP (Stealth)"
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
                    1) red_local ;;
                    2) iface_analyzer ;;
                    3) traceroute_tool ;;
                    4) subnet_calc ;;
                    5) monitor_conexiones ;;
                    6) break ;;
                esac
            done
            ;;
        2) 
            menu_web=(
                "${RED}[ATK]${NC} Auditor de Rutas Web (Dir-Buster Pasivo)"
                "${RED}[ATK]${NC} Escáner de Reflejo Básico XSS"
                "${RED}[ATK]${NC} Escáner de Inyección SQL (Error-Based)"
                "${RED}[ATK]${NC} Enumerador de Métodos HTTP (Verbs)"
                "${RED}[ATK]${NC} Prueba de Estrés HTTP Local (Load Tester)"
                "${PURPLE}[FRN]${NC} Buscador de Metadatos Forense (Strings/EXIF)"
                "${NC}[<--] Regresar al Directorio Raíz"
            )
            while true; do
                menu_interactivo "${menu_web[@]}"
                sub_sel=$?
                case $sub_sel in
                    0) dir_bruteforce ;;
                    1) xss_scanner ;;
                    2) sqli_prober ;;
                    3) http_verbs_scanner ;;
                    4) stress_test ;;
                    5) analisis_metadatos ;;
                    6) break ;;
                esac
            done
            ;;
        3) 
            menu_osi=(
                "${LIGHT_GREEN}[OSI]${NC} Enumeración Pasiva de Subdominios (CRT)"
                "${LIGHT_GREEN}[OSI]${NC} Búsqueda de Dominios (DNS / Ping)"
                "${LIGHT_GREEN}[OSI]${NC} Geolocalización Avanzada de IPs"
                "${LIGHT_GREEN}[OSI]${NC} Auditoría de Cabeceras SSL/HTTP"
                "${LIGHT_GREEN}[OSI]${NC} Banner Grabbing Remoto"
                "${LIGHT_GREEN}[OSI]${NC} Web Scraper Clandestino (Emails & Links)"
                "${NC}[<--] Regresar al Directorio Raíz"
            )
            while true; do
                menu_interactivo "${menu_osi[@]}"
                sub_sel=$?
                case $sub_sel in
                    0) subdomain_enum ;;
                    1) dns_lookup ;;
                    2) ip_geolocation ;;
                    3) auditoria_cabeceras ;;
                    4) banner_grabbing ;;
                    5) spider_osint ;;
                    6) break ;;
                esac
            done
            ;;
        4) 
            menu_sec=(
                "${YELLOW}[SEC]${NC} Generador de Contraseñas (Alta Entropía)"
                "${YELLOW}[SEC]${NC} Calculadora de Integridad (MD5 / SHA256)"
                "${YELLOW}[SEC]${NC} Cifrador / Descifrador (Base64)"
                "${NC}[<--] Regresar al Directorio Raíz"
            )
            while true; do
                menu_interactivo "${menu_sec[@]}"
                sub_sel=$?
                case $sub_sel in
                    0) password_gen ;;
                    1) hash_calculator ;;
                    2) base64_tool ;;
                    3) break ;;
                esac
            done
            ;;
        5) 
            clear
            echo -e "\n${PURPLE}[*] Apagando y destruyendo instancias limpias de memoria...${NC}"
            matrix_rain 2
            clear
            exit 0
            ;;
    esac
done
