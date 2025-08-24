#!/bin/bash

# ==================== CONFIGURATION ====================
colornow=$(cat /etc/rmbl/theme/color.conf)
colorfont=$(cat /etc/rmbl/warnafont/warnaf.conf)
NC="\e[0m"
RED="\033[0;31m"
COLOR1="$(cat /etc/rmbl/theme/$colornow | grep -w "TEXT" | cut -d: -f2|sed 's/ //g')"
COLBG1="$(cat /etc/rmbl/theme/$colornow | grep -w "BG" | cut -d: -f2|sed 's/ //g')"
WH="$(cat /etc/rmbl/warnafont/$colorfont | grep -w "WARNAF" | cut -d: -f2|sed 's/ //g')"
author=$(cat /etc/profil)

#===============================================================================#

function theme() {

# ==================== CONFIGURATION ====================
THEME_DIR="/etc/rmbl/theme"
THEME_DIR2="/etc/rmbl/warnafont"
COLOR_CONF="${THEME_DIR}/color.conf"
COLOR_CONFWN="${THEME_DIR2}/warnaf.conf"
AUTHOR_FILE="/etc/profil"

# ==================== COLOR FUNCTIONS ====================
load_colors() {
    colornow=$(cat "$COLOR_CONF" 2>/dev/null)
    NC="\e[0m"
    COLOR1=$(grep -w "TEXT" "${THEME_DIR}/${colornow}" | cut -d: -f2 | sed 's/ //g')
    COLBG1=$(grep -w "BG" "${THEME_DIR}/${colornow}" | cut -d: -f2 | sed 's/ //g')
    WH='\033[1;37m'
}

# ==================== DISPLAY FUNCTIONS ====================
show_header() {
    echo -e " ${COLBG1}                ${WH}• THEMES PANEL MENU •               ${COLBG1}"
}

show_options() {
    echo -e " ${WH}[01]${NC} ${COLOR1}• ${WH}COLOR RED         ${WH}[08]${NC} ${COLOR1}• ${WH}COLOR LIGHT RED      ${NC}"
    echo -e " ${WH}[02]${NC} ${COLOR1}• ${WH}COLOR GREEN       ${WH}[09]${NC} ${COLOR1}• ${WH}COLOR LIGHT GREEN    ${NC}"
    echo -e " ${WH}[03]${NC} ${COLOR1}• ${WH}COLOR YELLOW      ${WH}[10]${NC} ${COLOR1}• ${WH}COLOR LIGHT YELLOW   ${NC}"
    echo -e " ${WH}[04]${NC} ${COLOR1}• ${WH}COLOR BLUE        ${WH}[11]${NC} ${COLOR1}• ${WH}COLOR LIGHT BLUE     ${NC}"
    echo -e " ${WH}[05]${NC} ${COLOR1}• ${WH}COLOR MAGENTA     ${WH}[12]${NC} ${COLOR1}• ${WH}COLOR LIGHT MAGENTA  ${NC}"
    echo -e " ${WH}[06]${NC} ${COLOR1}• ${WH}COLOR CYAN        ${WH}[13]${NC} ${COLOR1}• ${WH}COLOR LIGHT CYAN     ${NC}"
    echo -e " ${WH}[07]${NC} ${COLOR1}• ${WH}COLOR LIGHT GRAY  ${WH}[14]${NC} ${COLOR1}• ${WH}COLOR DARKGRAY       ${NC}"

    echo -e " ${WH}[15]${NC} ${COLOR1}• ${WH}WARNA TEXT GREEN  ${WH}[17]${NC} ${COLOR1}• ${WH}WARNA TEXT LIGHT     ${NC}"
    echo -e " ${WH}[16]${NC} ${COLOR1}• ${WH}WARNA TEXT CYAN   ${WH}[00]${NC} ${COLOR1}• ${WH}EXIT                 ${NC}"
}

show_footer() {
    local author=$(cat "$AUTHOR_FILE" 2>/dev/null || echo "Unknown")
    echo -e "  $COLBG1              ${WH}   • $author •                 $COLBG1"
}

# ==================== THEME FUNCTIONS ====================
clear
change_theme() {
    local color=$1
    echo "${color}" > "${COLOR_CONF}"
    echo -e ""
    echo -e "  ${COLOR1}════════════════════════════════════════════════════${NC}"
    echo -e "          ${WH}SUCCESS: ${COLOR1}Theme changed to BackGround ${WH}${color}${NC}"
}
change_warna() {
    local color=$1
    echo "${color}" > "${COLOR_CONFWN}"
    echo -e ""
    echo -e "  ${COLOR1}════════════════════════════════════════════════════${NC}"
    echo -e "          ${WH}SUCCESS: ${COLOR1}WARNA changed to TEXT ${WH}${color}${NC}"
}

# ==================== MAIN PROGRAM ====================
load_colors
clear

show_header
show_options
show_footer


echo -ne "\n ${WH}Select menu ${COLOR1}: ${WH}"
read -r colormenu

case $colormenu in
    01|1) change_theme "red" ;;
    02|2) change_theme "green" ;;
    03|3) change_theme "yellow" ;;
    04|4) change_theme "blue" ;;
    05|5) change_theme "magenta" ;;
    06|6) change_theme "cyan" ;;
    07|7) change_theme "lightgray" ;;
    08|8) change_theme "lightred" ;;
    09|9) change_theme "lightgreen" ;;
    10) change_theme "lightyellow" ;;
    11) change_theme "lightblue" ;;
    12) change_theme "lightmagenta" ;;
    13) change_theme "lightcyan" ;;
    14) change_theme "darkgray" ;;
    15) change_warna "fontgren" ;;
    16) change_warna "fontcyan" ;;
    17) change_warna "fontlight" ;;
    00|0) clear; menu ;;
    *) clear; m-theme ;;
esac

echo -e "\n${NC}"
read -n 1 -s -r -p "          Press any key to return to menu"
clear
menu
