#!/bin/bash

# ==========================================
# MODULE: DEPENDENCIAS Y MOTOR DE REPORTES
# ==========================================

function check_dependencies() {
    local deps=("curl" "openssl" "netstat" "awk" "ssh-keygen" "nslookup")
    local missing=0
    
    clear
    print_centered "${CYAN}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
    print_centered "${CYAN}║${LIGHT_GREEN}            INICIALIZANDO SUBSISTEMA DE DEPENDENCIAS (CHECKSUM)           ${CYAN}║${NC}"
    print_centered "${CYAN}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    for cmd in "${deps[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            echo -e "  ${LIGHT_GREEN}[ OK ]${NC} Módulo binario detectado:\t$cmd"
        else
            echo -e "  ${RED}[WARN]${NC} Módulo binario ausente:\t$cmd"
            ((missing++))
        fi
        sleep 0.1
    done
    
    if [[ $missing -gt 0 ]]; then
        echo -e "\n${YELLOW}[!] Reporte: Se detectaron $missing dependencias faltantes.${NC}"
        echo -e "${YELLOW}    Algunos protocolos de ataque o escaneo estarán inoperativos en este SO.${NC}"
        sleep 3
    else
        echo -e "\n${GREEN}[+] Inspección limpia. 100% de capacidades operativas.${NC}"
        sleep 1
    fi
}

function setup_logger() {
    echo ""
    print_centered "${CYAN}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
    print_centered "${CYAN}║${YELLOW}  ¿Deseas activar el Motor de Reportes Forenses para esta sesión? (s/n)   ${CYAN}║${NC}"
    print_centered "${CYAN}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    read -n 1 -r -p "  > " resp
    if [[ "$resp" == "s" || "$resp" == "S" ]]; then
        mkdir -p logs
        SESSION_REPORT="logs/NEXUS_REPORT_$(date +%Y%m%d_%H%M%S).log"
        echo -e "\n\n${GREEN}[+] Logger Global ENGAGED. Guardando hallazgos automáticos en: $SESSION_REPORT${NC}"
        echo "=========================================" > "$SESSION_REPORT"
        echo "   SAO NEXUS AUDIT EXPORT - $(date)" >> "$SESSION_REPORT"
        echo "=========================================" >> "$SESSION_REPORT"
        export SESSION_REPORT
    else
        export SESSION_REPORT=""
        echo -e "\n\n${PURPLE}[-] Logger Auxiliar DESACTIVADO. Operando en modo fantasma.${NC}"
    fi
    sleep 2
}

# Wrapper para registrar eventos ignorando el color ASCII invisible (sed)
function log_event() {
    if [[ -n "$SESSION_REPORT" ]]; then
        local text="$1"
        local clean_text="$text"
        
        # Eliminar las variables globales de color si están expandidas
        clean_text=${clean_text//${GREEN}/}
        clean_text=${clean_text//${LIGHT_GREEN}/}
        clean_text=${clean_text//${RED}/}
        clean_text=${clean_text//${CYAN}/}
        clean_text=${clean_text//${YELLOW}/}
        clean_text=${clean_text//${PURPLE}/}
        clean_text=${clean_text//${NC}/}
        
        # Limpiar secuencias ANSI persistentes via expresión regular POSIX genérica
        clean_text=$(echo -e "$clean_text" | sed 's/\x1B\[[0-9;]*[a-zA-Z]//g' 2>/dev/null || echo -e "$clean_text")
        
        echo "[$(date +'%H:%M:%S')] $clean_text" >> "$SESSION_REPORT"
    fi
}
