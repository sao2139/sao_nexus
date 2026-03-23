# Definición de colores
GREEN='\033[0;32m'
LIGHT_GREEN='\033[1;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Utilidad para imprimir centrado con borrado de cola, SUPER rápida sin subshells
function print_centered() {
    local text="$1"
    local cols="${2:-80}"
    local clean_text="$text"
    clean_text=${clean_text//${GREEN}/}
    clean_text=${clean_text//${LIGHT_GREEN}/}
    clean_text=${clean_text//${RED}/}
    clean_text=${clean_text//${CYAN}/}
    clean_text=${clean_text//${YELLOW}/}
    clean_text=${clean_text//${PURPLE}/}
    clean_text=${clean_text//${NC}/}
    
    local padding=$(( (cols - ${#clean_text}) / 2 ))
    [[ $padding -lt 0 ]] && padding=0
    # Imprime espacios, luego el texto parseando ANSI con %b, borra resto de línea y salta
    printf "%${padding}s%b\033[K\n" "" "$text"
}

# Utilidad de máquina de escribir
function type_text() {
    local text="$1"
    local delay="${2:-0.03}"
    for (( i=0; i<${#text}; i++ )); do
        echo -n "${text:$i:1}"
        sleep $delay
    done
    echo ""
}

# Animación de secuencia Hacker Avanzada (Boot, Login, Matrix Loader, Glitch)
function animar() {
    tput civis
    clear
    
    local cols=$(tput cols 2>/dev/null || echo 80)
    cols=${cols//[^0-9]/}
    [[ -z "$cols" ]] && cols=80
    
    local lines=$(tput lines 2>/dev/null || echo 24)
    lines=${lines//[^0-9]/}
    [[ -z "$lines" ]] && lines=24
    
    # === FASE 1: Boteo de Kernel Simulado ===
    echo -e "${PURPLE}[kernel]${NC} Memoria mapeada. Iniciando ACPI..."
    sleep 0.1
    for ((i=1; i<=14; i++)); do
        local random_hex=$(cat /dev/urandom | tr -dc 'A-F0-9' | fold -w 8 | head -n 1 2>/dev/null || echo "1A2B3D4F")
        local ms=$(( i * 115 + RANDOM % 40 ))
        printf "${PURPLE}[ %d.%03d ]${NC} kernel: eth0: link up, 1000Mbps, lpa 0x%s\n" $((ms/1000)) $((ms%1000)) "$random_hex"
        sleep 0.03
    done
    sleep 0.2
    clear
    
    # === FASE 2: Simulación de Login ===
    echo -e "${LIGHT_GREEN}NEXUS OS TERMINAL v3.1.0${NC}"
    echo -e "Copyright (c) 2026 SAO Security Division.\n"
    sleep 0.3
    
    echo -n "login as: "
    sleep 0.3
    type_text "root" 0.08
    echo -n "root@nexus password: "
    sleep 0.4
    type_text "**********" 0.06
    sleep 0.2
    echo -e "${LIGHT_GREEN}[+] ACCESS GRANTED.${NC}\n"
    sleep 0.5
    clear
    
    # === FASE 3: Subsistemas ===
    local v_pad=$(( (lines - 10) / 2 ))
    [[ $v_pad -lt 0 ]] && v_pad=0
    for ((k=0; k<v_pad; k++)); do echo ""; done
    
    print_centered "${CYAN}[*] S.A.O. NEXUS INITIALIZATION SEQUENCE${NC}" "$cols"
    echo ""
    sleep 0.2
    
    local boot_msgs=(
        "Mounting virtual encryption keys...  [ OK ]"
        "Starting Nexus root subsystem...     [ OK ]"
        "Loading stealth network modules...   [ OK ]"
        "Bypassing mainframe firewalls...     [ OK ]"
        "Establishing secure connection...    [ OK ]"
    )
    for msg in "${boot_msgs[@]}"; do
        print_centered "${LIGHT_GREEN}$msg${NC}" "$cols"
        # Delay variable aleatorio simple sin comandos externos
        local delay=$((RANDOM % 3 + 1))
        sleep "0.${delay}"
    done
    sleep 0.4
    clear
    
    # === FASE 4: Barra Matrix Fluctuante Mágica ===
    local width=50
    local term_pad=$(( (cols - (width + 36)) / 2 )) 
    [[ $term_pad -lt 0 ]] && term_pad=0

    local v_pad_loader=$((lines / 2))
    for ((k=0; k<v_pad_loader; k++)); do echo ""; done

    local matrix=(0 1)
    local i=0
    while [ $i -le $width ]; do
        local percent=$(( (i * 100) / width ))
        local progress=""
        for ((j=0; j<i; j++)); do progress+="█"; done
        for ((j=i; j<width; j++)); do progress+="${matrix[$((RANDOM%2))]}"; done
        
        local fake_hash=$(cat /dev/urandom | tr -dc 'A-F0-9' | fold -w 8 | head -n 1 2>/dev/null || echo "DEADBEEF")
        printf "\r%${term_pad}s${LIGHT_GREEN}Decrypt Core \033[0;35m[%s]\033[0m : ${CYAN}[%s] %3d%%${NC}" "" "$fake_hash" "$progress" "$percent"
        
        # Saltar a veces para simular ráfagas rápidas de proceso (efecto CPU real)
        local salto=$((RANDOM % 3 + 1))
        ((i += salto))
        
        # Fluctuar sleep
        local slp=$((RANDOM % 6))
        sleep "0.0${slp}"
    done
    
    # 100% final forzado visual
    local full_prog=""
    for ((j=0; j<width; j++)); do full_prog+="█"; done
    printf "\r%${term_pad}s${LIGHT_GREEN}Decrypt Core \033[0;35m[COMPLETE]\033[0m : ${CYAN}[%s] 100%%${NC}" "" "$full_prog"
    echo -e "\n"
    sleep 0.6
    
    # === FASE 5: Glitch Ultra Agresivo ===
    local noise="!@#$%^&*()_+~}{][';:/?><.,=-0987654321qwERTYUiopasDFGHjklzxCVBNmQWErtyUIOPaSdfghJKLzXCVbnM!@#$%^&*()_+~}{][';:/?><"
    for i in {1..5}; do
        local color_arr=("$GREEN" "$CYAN" "$PURPLE" "$RED" "$YELLOW" "$LIGHT_GREEN")
        local rc=${color_arr[$((RANDOM%6))]}
        clear
        for ((k=0; k<lines; k++)); do
            # Solo pinta algunas lineas corruptas, 20% posiblidad por linea
            if [[ $((RANDOM%5)) -eq 0 ]]; then
                local start=$((RANDOM % 30))
                echo -e "${rc}${noise:$start:$cols}${NC}"
            else
                echo ""
            fi
        done
        sleep "0.0$((RANDOM%4+2))"
        clear
        sleep "0.0$((RANDOM%3+1))"
    done
    
    clear
    for ((k=0; k<v_pad_loader; k++)); do echo ""; done
    print_centered "${RED}S I S T E M A   C O M P R O M E T I D O${NC}" "$cols"
    sleep 0.7
    clear
    
    tput cnorm
}

# Banner principal (Centrado y Estático con Bordes Cyber)
function mostrar_banner() {
    local cols="$1"
    local lines="$2"
    
    local v_pad=$(( (lines - 28) / 2 )) 
    [[ $v_pad -lt 0 ]] && v_pad=0
    for ((i=0; i<v_pad; i++)); do echo -e "\033[K"; done

    print_centered "${CYAN}╔══════════════════════════════════════════════════════════════════════════╗${NC}" "$cols"
    print_centered "${CYAN}║${LIGHT_GREEN}  ██████  █████   ██████      ███    ██ ███████ ██   ██ ██    ██ ███████  ${CYAN}║${NC}" "$cols"
    print_centered "${CYAN}║${LIGHT_GREEN} ██      ██   ██ ██    ██     ████   ██ ██       ██ ██  ██    ██ ██       ${CYAN}║${NC}" "$cols"
    print_centered "${CYAN}║${LIGHT_GREEN}  █████  ███████ ██    ██     ██ ██  ██ █████     ███   ██    ██ ███████  ${CYAN}║${NC}" "$cols"
    print_centered "${CYAN}║${LIGHT_GREEN}      ██ ██   ██ ██    ██     ██  ██ ██ ██       ██ ██  ██    ██      ██  ${CYAN}║${NC}" "$cols"
    print_centered "${CYAN}║${LIGHT_GREEN} ██████  ██   ██  ██████      ██   ████ ███████ ██   ██  ██████  ███████  ${CYAN}║${NC}" "$cols"
    print_centered "${CYAN}╠══════════════════════════════════════════════════════════════════════════╣${NC}" "$cols"
    print_centered "${CYAN}║       ${PURPLE}[■] SYSTEM: ONLINE        [■] MODULES: 14        [■] OS: NATIVE    ${CYAN}║${NC}" "$cols"
    print_centered "${CYAN}╚══════════════════════════════════════════════════════════════════════════╝${NC}" "$cols"
    echo -e "\033[K"
}

# Menú interactivo ultrarápido (Sin lag)
function menu_interactivo() {
    local options=("$@")
    local selected=0
    local num_options=${#options[@]}
    local key

    # CACHEAR tput
    local cached_cols=$(tput cols 2>/dev/null || echo 80)
    cached_cols=${cached_cols//[^0-9]/}
    [[ -z "$cached_cols" ]] && cached_cols=80

    local cached_lines=$(tput lines 2>/dev/null || echo 24)
    cached_lines=${cached_lines//[^0-9]/}
    [[ -z "$cached_lines" ]] && cached_lines=24

    tput civis
    clear      

    while true; do
        printf "\033[H" 

        mostrar_banner "$cached_cols" "$cached_lines"
        print_centered "${CYAN}root@nexus:~$ Select active target module...${NC}" "$cached_cols"
        echo -e "\033[K"

        for i in "${!options[@]}"; do
            local raw="${options[$i]}"
            local clean_opt="$raw"
            clean_opt=${clean_opt//${GREEN}/}
            clean_opt=${clean_opt//${LIGHT_GREEN}/}
            clean_opt=${clean_opt//${RED}/}
            clean_opt=${clean_opt//${CYAN}/}
            clean_opt=${clean_opt//${YELLOW}/}
            clean_opt=${clean_opt//${PURPLE}/}
            clean_opt=${clean_opt//${NC}/}
            
            local opt_len=${#clean_opt}
            local padding=$(( (cached_cols - opt_len - 8) / 2 )) 
            [[ $padding -lt 0 ]] && padding=0
            
            if [[ $i -eq $selected ]]; then
                printf "%${padding}s${LIGHT_GREEN}  ➔  %b  ${NC}\033[K\n" "" "$raw"
            else
                printf "%${padding}s     %b  \033[K\n" "" "$raw"
            fi
        done

        # Vaciar la basura extra
        echo -e "\033[K\n\033[K\n\033[K"

        read -s -n 1 key
        if [[ $key == $'\e' ]]; then
            read -s -n 2 key
            if [[ $key == "[A" || $key == "OA" ]]; then # Arriba
                ((selected--))
                if [[ $selected -lt 0 ]]; then selected=$((num_options - 1)); fi
            elif [[ $key == "[B" || $key == "OB" ]]; then # Abajo
                ((selected++))
                if [[ $selected -ge $num_options ]]; then selected=0; fi
            fi
        elif [[ -z "$key" || "$key" == $'\n' || "$key" == $'\r' ]]; then 
            
            # ANIMACIÓN DE SELECCIÓN DE TEXTO (FLASH)
            for b in {1..3}; do
                printf "\033[%dA\r" $(( num_options + 3 - selected ))
                
                local raw="${options[$selected]}"
                local clean_opt="$raw"
                clean_opt=${clean_opt//${GREEN}/}
                clean_opt=${clean_opt//${LIGHT_GREEN}/}
                clean_opt=${clean_opt//${RED}/}
                clean_opt=${clean_opt//${CYAN}/}
                clean_opt=${clean_opt//${YELLOW}/}
                clean_opt=${clean_opt//${PURPLE}/}
                clean_opt=${clean_opt//${NC}/}
                
                local pad=$(( (cached_cols - ${#clean_opt} - 8) / 2 ))
                [[ $pad -lt 0 ]] && pad=0
                
                if [[ $((b % 2)) -eq 0 ]]; then
                    printf "%${pad}s${LIGHT_GREEN}  ➔  %b  ${NC}\033[K\n" "" "$raw"
                else
                    printf "%${pad}s${CYAN}  ➔  %b  ${NC}\033[K\n" "" "$raw"
                fi
                
                printf "\033[%dB" $(( num_options + 2 - selected ))
                sleep 0.1
            done

            tput cnorm
            clear 
            return $selected
        fi
    done
}

# Animación Matrix Rain (Lluvia Digital)
function matrix_rain() {
    local duracion=$1
    local cols=$(tput cols 2>/dev/null || echo 80)
    cols=${cols//[^0-9]/}
    [[ -z "$cols" ]] && cols=80
    
    local chars=(a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9 @ # $ % ^ & *)
    
    tput civis
    clear
    local end_time=$(( SECONDS + duracion ))
    
    while [ $SECONDS -lt $end_time ]; do
        local random_col=$((RANDOM % cols))
        local random_char=${chars[$((RANDOM % ${#chars[@]}))]}
        
        if [[ $((RANDOM % 5)) -eq 0 ]]; then
            echo ""
        fi
        
        printf "\033[0;32m%${random_col}s%s\033[0m\r" "" "$random_char"
        sleep 0.01
    done
    tput cnorm
}