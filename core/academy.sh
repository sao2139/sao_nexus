#!/bin/bash

# --- MÓDULO EDUCATIVO: ACADEMIA DE HACKERS ---
# Autor: sao2139

source core/visuals.sh 2>/dev/null

function tutor_card() {
    local title="$1"
    local concept="$2"
    local mechanic="$3"
    local offensive="$4"
    local defensive="$5"
    
    echo -e "\n${CYAN}======================================================================${NC}"
    echo -e "${GREEN}🔥 TÍTULO: ${LIGHT_GREEN}$title${NC}"
    echo -e "${CYAN}----------------------------------------------------------------------${NC}"
    
    [[ -n "$concept" ]] && {
        echo -e "${YELLOW}📖 Concepto (Teoría Base):${NC}"
        echo -e "$concept" | fold -w 68 -s | sed 's/^/   /'
        echo ""
    }
    
    [[ -n "$mechanic" ]] && {
        echo -e "${PURPLE}⚙️ Mecanismo de Acción (El 'Cómo'):${NC}"
        echo -e "$mechanic" | fold -w 68 -s | sed 's/^/   /'
        echo ""
    }
    
    [[ -n "$offensive" ]] && {
        echo -e "${RED}🎯 Aplicación Ofensiva (Red Team):${NC}"
        echo -e "$offensive" | fold -w 68 -s | sed 's/^/   /'
        echo ""
    }
    
    [[ -n "$defensive" ]] && {
        echo -e "${LIGHT_GREEN}🛡️ Contramedida (Blue Team):${NC}"
        echo -e "$defensive" | fold -w 68 -s | sed 's/^/   /'
    }
    echo -e "${CYAN}======================================================================${NC}"
}

function edu_menu_sys() {
    clear
    echo -e "\n${PURPLE}--- MANUAL: SISTEMAS Y PERSISTENCIA ---${NC}"
    
    tutor_card "1. Escalamiento de Privilegios Local (PrivEsc)" \
    "Es la fase post-infiltración principal. Ocurre cuando un atacante entra al sistema con un usuario restringido (ej. 'www-data') y abusa de errores locales para convertirse en Administrador/Root supremo." \
    "El atacante enumera configuraciones débiles: Archivos sudo sin contraseña (NOPASSWD), versiones de Kernel desactualizadas con fallos de asignación de memoria, o tareas repetitivas (Cronjobs) que son leídas por root pero modificables por todos." \
    "Se busca el Root para tomar control total: instalar Rootkits indetectables a la vista, robar el archivo /etc/shadow (Hashes de base de datos) o crear backdoors perennes en los servicios." \
    "Aplicar el Principio de Mínimo Privilegio (PoLP). No uses cuentas Root para tareas de red. Mantén el kernel actualizado y audita los scripts que cargan en el arranque."
    
    tutor_card "2. Peligro Crítico: SUID y Bit 777" \
    "El SUID (Set owner User ID up on execution) es un bit de archivo especial. Permite a CUALQUIER usuario de la calle ejecutar un programa, obligando al programa a trabajar con los privilegios reales del 'creador' de dicho programa. El bit 777 regala atributos plenos de Lectura/Escritura/Ejecución incondicional universalmente." \
    "Si un binario precompilado como 'cp' (copy), 'find', o 'nmap' tiene la bandera SUID encendida por root, el hacker invoca el comando inyectándole parámetros bash permitiéndole ejecutar consolas (/bin/sh) arrastradas directamente hacia la jaula Root (Escape de entorno)." \
    "Encontrar estos errores permite saltar del usuario más débil al más fuerte con un solo comando o inyección en la terminal interactiva (Ej. find . -exec /bin/sh \\;)." \
    "Corre regularmente: 'find / -perm -4000 2>/dev/null' localizando archivos con este bit y apágalo usando chmod u-s [ruta] si no es un framework dependiente como sudo."
    
    tutor_card "3. Evasión de Rastro: File Shredding (Wiping)" \
    "Cuando un SO o Papelera 'elimina' un dato, solo destruye el hilo puntero lógico; físicamente los rastros magnéticos siguen escritos crudos en el hardware, a merced de software de recuperación para reensamblarlos (Forensics)." \
    "El algoritmo de Shredding intercepta y sobrescribe violentamente los clusters exactos del disco con secuencias de ceros informáticos, y luego con aleatoriedad masiva múltiples veces, difuminando la firma iNode por completo." \
    "Al terminar de hackear, el profesional del Red Team destruirá las herramientas de escaneo, archivos subidos (exploits) o la bitácora de terminal donde escribió localmente para no dejar material judicial en su contra." \
    "Monitorización en memoria RAM y respaldos instantáneos (Snapshots SIEM) a servidores off-site paralelos para retener copias read-only de toda modificación inyectada en el servidor central."

    echo ""
    read -p "Presiona Enter para regresar a los libros..."
}

function edu_menu_net() {
    clear
    echo -e "\n${CYAN}--- MANUAL: REDES FÍSICAS Y EVASIÓN ---${NC}"
    
    tutor_card "1. Escaneo de Puertos TCP Sigiloso (Stealth SYN)" \
    "A diferencia del ping que solo verifica red, el port-scanning toca las 'puertas' digitales asignadas a los protocolos (Puertos 1-65535). Hacerlo 'Stealth/Sigiloso' significa enviar paquetes SYN pero frustrando la conexión de inmediato para evadir registros." \
    "Si mandas un SYN localmente y el sistema receptor responde SYN-ACK (El puerto está oyendo), en vez de confirmar la conexión con otro ACK, Nexus la aborta repentinamente. Cientos de Firewalls y aplicaciones solo registran y alertan la comunicación si se llega al loggin 3-way-handshake total." \
    "Mapear la red silenciosamente revelando por dónde entrar (Si hay un puerto 22, atacaremos credenciales SSH u OpenSSL vulnerables. Si es el puerto 80, hay un servidor Web esperando código)." \
    "Cerrar cualquier puerto en el iptables local que no sea comercialmente mandatorio. Requerir Port-Knocking (Secuencia de golpes) secretos para desencadenar remotamente la apertura del puerto administrativo."
    
    tutor_card "2. MITM Físico: Spoofing Clónico MAC" \
    "La Dirección MAC es el estampado hexadecimal en hardware tallado de fábrica en el silicio de la tarjeta NIC (La tarjeta de red). Alterarla o 'Spoofearla' es un engaño a la capa de Hardware del OS y los switches de la red central." \
    "El script tira abajo el enlace (Link Down) local de tu tarjeta eth0, y le impone al kernel una máscara de software con otra MAC address Unicast inyectada aleatoria o clonada del router, antes de volver a levantar el canal (Link Up)." \
    "Provee un anonimato tremendo contra la Caza IDS Institucional e invisibiliza tu laptop ante baneos del Switch de oficinas. Indispensable como pre-requisito al tratar de derribar a un usuario con desautentificación WiFi para entrar." \
    "Habilitar Switches Administrables con MAC-Binding Port Security o control estricto de acceso a la red (NAC/802.1X)."

    tutor_card "3. Rastreo Topológico: Ping Sweeps" \
    "El 'Barrido de Pings' es el intento hostil/defensivo de emitir señales de protocolo de Control (ICMP Echo) de alta iteración a través de todos los nodos adyacentes de una clase IPv4 (192.168.1.1 hasta la terminal .254)." \
    "Un ciclo While masivo paralelizado despacha paquetes ICMP. Si el host está operativo, interrumpe el Firewall (si no lo filtra de facto) reportándonos Echo Reply. El script descifra e indexa su presencia viva instantáneamente." \
    "Sacar del anonimato periférico a las máquinas silentes: Cámaras locales, bases de datos no expuestas a internet que comparten tú VLAN y terminales ofimáticas vecinas; para expandir un movimiento lateral en la empresa." \
    "El Firewall perimetral debería estar configurado estrictamente para desechar el Drop-All en el entorno ICMP entrante, imposibilitando barridos y dibujando 'agujeros negros' al radar del escáner."

    echo ""
    read -p "Presiona Enter para regresar a los libros..."
}

function edu_menu_atk() {
    clear
    echo -e "\n${RED}--- MANUAL: EXPLOTACIÓN SUPERFICIAL WEB ---${NC}"
    
    tutor_card "1. Inyección de Inclusión de Archivos (LFI Prober)" \
    "Local File Inclusion (LFI). Ocurre de forma epidémica en enrutadores dinámicos web carentes de saneamiento en inputs de carpetas hacia el servidor (ej. sitio.com/index.php?file=perfil.txt)." \
    "El atacante intercepta la solicitud y cambia 'perfil.txt' por saltos de directorios raíz con cadenas puras '../../../etc/passwd'. El servidor, ciego instruido a renderizar archivos, asciende hasta el sistema base del disco y le estampa en navegador el archivo hiper-confidencial /etc/passwd al atacante." \
    "Permite escanear código fuente ajeno, ver variables de configuración o leer claves secretas en tokens que yacen instalados adentro del entorno Backend, destruyendo muros pasivos." \
    "Lista Blanca Estricta (Whitelisting). Nunca construyas rutas usando variables de input. Sanitiza los caracteres puntos de salto (..) obligatoriamente y confina carpetas en chroot jails blindados."
    
    tutor_card "2. Cors Misconfiguration" \
    "El Intercambio de Recursos de Origen Cruzado (CORS) es un escudo nativo en navegadores dictándole a quién tiene permitido robar y mostrar en su propia web recursos que viven en tu otra API web. Configuraciones mal hechas matan esta medida." \
    "El escáner envía una petición HTTP usando una cabecera inyectada: 'Origin: web-falsa-del-hacker.com'. Si el servidor evalúa incorrectamente este string confiando en él y regala 'Access-Control-Allow-Origin: web-falsa.com', estamos ante un Bypass inmenso." \
    "Si controlas el Origin, induces a personal corporativo con credenciales ya iniciadas a dar click a un enlace falso tuyo en WhatsApp o Email; y este enlace cargará javascript que, respaldado en el fallo transversal del Target CORS, asimilará remotamente sus sesiones financieras." \
    "NUNCA reflejar directamente la URL solicitada que provenga de la cabecera Origin. Delimita un string constante de dominios socios que únicamente pueden cruzar interfaces de tu API."

    tutor_card "3. Detección de Inyección Base (SQLi Error-Based)" \
    "Ocurre a los motores RDBMS relacionales cuando el analizador sintáctico recibe una 'Asignación Dinámica de Texto Web'. Intencionalmente inyectamos carácteres interpretativos de backend en el parámetro de búsqueda para alterar la máquina." \
    "Al colar un comando especial (una comilla apostrofe ') y no escaparla, el motor de base de datos colisiona y escupe al Frontend de la web un error grotesco descriptivo de sistema tipo: 'You have an error in your SQL syntax near...' con indicios vitales del lenguaje." \
    "Permite volcar metadatamente bases enteras de datos con secuencias en UNION, destripar cuentas, evadir filtros de panel de control o sobreescribir hashes inyectando 'OR 1=1' logueando al atacante sin conocer el correo." \
    "Declaraciones Parametrizadas y Vistas de Procedimiento Preparado (ORM). Los datos enviados no deben ir pegados a los strings directos de la base sino tratados estrictamente como literales textuales desarmados. Web Application Firewall (WAF) activo."

    echo ""
    read -p "Presiona Enter para regresar a los libros..."
}

function edu_menu_osi() {
    clear
    echo -e "\n${LIGHT_GREEN}--- MANUAL: INTELIGENCIA GLOBAL O.S.INT ---${NC}"
    
    tutor_card "1. Inteligencia Informática de Brechas (Breach OSINT)" \
    "Es el aprovechamiento estratégico y el Data Mining sobre colosales volcados de información liberados en la Dark y Deep web, luego de hackeos contra corporativos y foros." \
    "Un Check Breach interactúa localmente con API globales y forenses donde residen terabytes documentados. Interrogas buscando si un elemento crítico (un correo ejecutivo de la empresa objetivo) aparece cruzado con robos antiguos que dejaron sus pasword textuales expuestos." \
    "Los atacantes usan estas listas cruzadas de correos comprometidos aplicando credencial stuffing masivo hacia las aplicaciones actuales asumiendo que el usuario es perezoso y re-usó el password del leak en la nueva red." \
    "Enrutar autenticación Multi-Factorial Estricta en empleados jerárquicos. Obligar la rotación semestral de tokens estáticos con validaciones de contraseñas cruzadas a estas apis antes de asignarlas."
    
    tutor_card "2. Wayback Machine Threat Recon" \
    "Una auditoría retroactiva mediante capturas automáticas perpetuas del 'Internet Archive'. Si una web publicó hace cinco años código y posteriormente se modernizó y sepultó dichos index; quedan latentes públicamente en el archivero global." \
    "El bot de Nexus viaja virtualmente atrás en el tiempo a esta API, rastrea URL crudos viejos en la caché web como 'empresa.com/login_v1_legacy.php', endpoints y API keys extintas publicadas en JavaScript por accidente." \
    "Con suerte letal y extrema, el portal puede haber ocultado el enlace de la vieja API pero jamás retiró el nodo base de su servidor, exponiendo puntos Ciegos en fuego directo y sin ninguna de las protecciones modernas del sitio actual." \
    "La seguridad por Obscuridad oculta todo, lo que implica que el equipo de administradores debe inhabilitar localmente archivos deprecated nativos y mantener rutinas destructivas sobre ramas de control obsoletas."

    echo ""
    read -p "Presiona Enter para regresar a los libros..."
}

function edu_menu_exp() {
    clear
    echo -e "\n${PURPLE}--- MANUAL: ESTRUCTURAS EXTRANET & LISTENERS ---${NC}"
    
    tutor_card "1. Reverse Shell vs Bind Shell de Penetración" \
    "El dilema principal para mantener una conexión remota después de penetrar un sistema radica en cómo establecer la tetería base contra los Firewall del perímetro corporativo local. Un Firewall está hecho para rechazar a extraños, pero obedecer ciegamente a empleados salientes." \
    "Un BIND SHELL le inyecta un ejecutable a la víctima y hace que 'Abra su cuarto y espere pasivamente que tú toques la puerta localmente a ella para entregarte una consola', lo cual es repelido por los routers el 99% de las veces en Internet moderno. El REVERSE SHELL engaña el paradigma y es introducido por el hacker para que la Máquina OBLIGUE internamente OTRA conexión pero de Salida TCP conectándose de forma directa hacia tu PC maliciosa y cruzando el muro de fuego del Firewall de regreso a ti." \
    "Al implementar Reverse Shellers encriptados al puerto 443 del objetivo (El puerto Web estándar HTTPS), se le disfraza al monitor corporativo haciéndole creer que solo es navegación ordinaria a internet cuando en realidad es un passthrough completo del kernel C2 volcado interactivo." \
    "Bloqueo estricto del vector saliente 'Egress Firewall Filtering'. Una computadora no debe conectarse en reversa a internet a puertos dudosos. Empleo masivo de monitoreo comportamental y Deep Packet Inspection (DPI) contra tramas TCP."
    
    echo ""
    read -p "Presiona Enter para regresar a los libros..."
}

function edu_menu_sec() {
    clear
    echo -e "\n${YELLOW}--- MANUAL: CRIPTOGRAFÍA Y ESTEGANOGRAFÍA ---${NC}"
    
    tutor_card "1. Desempaquetado e Inseguridad JWT (JSON Web Token)" \
    "Son los estándares globales utilizados hoy en día para entregar pases temporales de acreditación y sesión digital a un cliente sin almacenar nada del lado del server (Stateless). Está dividido en Header, Payload y Signature engullidos en codificación limpia de Base64URL." \
    "La manipulación ocurre comúnmente cuando el programador olvida o ignora validar correctamente de regreso la Firma (Signature verificador del secreto backend). El Hacker recolecta sus tickets, lo desencripta usando Nexus (para evidenciar sus permisos de 'Role': 'user'), lo altera a 'Role':'admin' y manipula la codificación incrustándola forzosamente como sesión válida y asimilando el perfil sin restricciones." \
    "Alteración de cuentas bancarias y robo de identidades web por subida y evasión de firmas simétricas vulneradas o nulas 'None alg', abusando y suplantando los engramas de las Cookies Session o Tokens locales Bearer." \
    "Asegurar en Backend que siempre exista la comprobación fuerte de HMAC (RS256 obligatorios) en la llave cifrada pública y firmar contra algoritmos validados de alta entropía por la estructura central de la API impidiendo manipulaciones en Payload."
    
    echo ""
    read -p "Presiona Enter para regresar a los libros..."
}

function nexus_academy() {
    local opc_edu=(
        "${PURPLE}[SYS]${NC} Conceptos de Escalada y Persistencia Local"
        "${CYAN}[NET]${NC} Cibernética de Switch Spoofers e Inundación"
        "${RED}[ATK]${NC} Explotación LFI, XSS y Web SQL Erroring"
        "${LIGHT_GREEN}[OSI]${NC} Doctrina OSINT Pasivo e Inteligencia Masiva"
        "${PURPLE}[EXP]${NC} Tácticas Shell, Bypass y Manejo de Handlers"
        "${YELLOW}[SEC]${NC} Manipulación de Firmas, JWT y Estigado Oculto"
        "${NC}[<--] Regresar al Menú Principal"
    )
    
    while true; do
        clear
        echo -e "\n${CYAN}======================================================================${NC}"
        echo -e "${YELLOW}               📚 ACADEMIA NEXUS Y CIBERAUDITORÍA                     ${NC}"
        echo -e "${YELLOW}    \"Primero comprende el engranaje, después quiebra el reloj\"     ${NC}"
        echo -e "${CYAN}======================================================================${NC}"
        menu_interactivo "${opc_edu[@]}"
        local edu_sel=$?
        
        case $edu_sel in
            0) edu_menu_sys ;;
            1) edu_menu_net ;;
            2) edu_menu_atk ;;
            3) edu_menu_osi ;;
            4) edu_menu_exp ;;
            5) edu_menu_sec ;;
            6) break ;;
        esac
    done
}
