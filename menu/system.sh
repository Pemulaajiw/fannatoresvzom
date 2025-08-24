
#!/bin/bash
clear

# =============================================
#           [ Konfigurasi Warna ]
# =============================================
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export NC='\033[0m'

# =============================================
#          [ Fungsi Pengecekan IP ]
check_ip_and_get_info() {
    local ip=$1
    while IFS= read -r line; do
        # Hapus karakter khusus dan spasi berlebih
        line=$(echo "$line" | tr -d '\r' | sed 's/[^[:print:]]//g' | xargs)
        
        # Split baris menjadi array
        read -ra fields <<< "$line"
        
        
        # Kolom 4 = IP Address (index 3)
        if [[ "${fields[3]}" == "$ip" ]]; then
            client_name="${fields[1]}"  # Kolom 2
            exp_date="${fields[2]}"     # Kolom 3
            
            # Bersihkan tanggal dari karakter khusus
            exp_date=$(echo "$exp_date" | sed 's/[^0-9-]//g' | xargs)
            
            return 0
        fi
    done <<< "$permission_file"
    return 1
}

# =============================================
#          [ Main Script ]
# =============================================

# Ambil data dari GitHub dengan timeout
permission_file=$(curl -s --connect-timeout 10 https://raw.githubusercontent.com/Pemulaajiw/fannatoresvzom/refs/heads/main/ijin)

# Validasi file permission
if [ -z "$permission_file" ]; then
    echo -e "${RED}❌ Gagal mengambil data lisensi!${NC}"
    exit 1
fi

# Ambil IP VPS dengan metode alternatif
IP_VPS=$(curl -s ipv4.icanhazip.com)
# =============================================
#          [ Pengecekan IP ]
# =============================================
echo -e "${GREEN}⌛ Memeriksa lisensi...${NC}"
if check_ip_and_get_info "$IP_VPS"; then
    
    # Validasi format tanggal ISO 8601
    if ! [[ "$exp_date" =~ ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$ ]]; then
        echo -e "${RED}❌ Format tanggal invalid: '$exp_date' (harus YYYY-MM-DD)${NC}"
        exit 1
    fi

    # Validasi tanggal menggunakan date
    if ! date -d "$exp_date" "+%s" &>/dev/null; then
        echo -e "${RED}❌ Tanggal tidak valid secara kalender: $exp_date${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ IP tidak terdaftar!${NC}"
    echo -e "➥ Hubungi admin ${CYAN}「 ✦ 087898083051 ✦ 」${NC}"
    exit 1
fi

# =============================================
#          [ Hitung Hari Tersisa ]
# =============================================
current_epoch=$(date +%s)
exp_epoch=$(date -d "$exp_date" +%s)

if (( exp_epoch < current_epoch )); then
    echo -e "${RED}❌ Masa aktif telah habis!${NC}"
    exit 1
fi

days_remaining=$(( (exp_epoch - current_epoch) / 86400 ))

biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
colornow=$(cat /etc/rmbl/theme/color.conf)
colorfont=$(cat /etc/rmbl/warnafont/warnaf.conf)
NC="\e[0m"
RED="\033[0;31m"
COLOR1="$(cat /etc/rmbl/theme/$colornow | grep -w "TEXT" | cut -d: -f2|sed 's/ //g')"
COLBG1="$(cat /etc/rmbl/theme/$colornow | grep -w "BG" | cut -d: -f2|sed 's/ //g')"
WH="$(cat /etc/rmbl/warnafont/$colorfont | grep -w "WARNAF" | cut -d: -f2|sed 's/ //g')"

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
}

#===============================================================================#

function domain() {
    # Konfigurasi warna
    COLOR1='\033[0;36m'
    NC='\033[0m'
    WH='\033[1;37m'
    RED='\033[0;31m'

    # Fungsi progress bar
    fun_bar() {
        local cmd=("$@")
        (
            eval "${cmd[@]}" >/dev/null 2>&1
            touch /tmp/fim
        ) &
        
        echo -ne "  ${COLOR1}Memproses... ["
        while [ ! -f /tmp/fim ]; do
            echo -ne "#"
            sleep 0.2
        done
        rm -f /tmp/fim
        echo -e "]${NC} Selesai!"
    }

    # Fungsi instalasi slowdns
    install_slowdns() {
        local script_url="https://raw.githubusercontent.com/hokagelegend9999/genom/refs/heads/main/SLOWDNS/installsl.sh"
        local output_file="installsl.sh"
        
        echo -e "${COLOR1}Mengunduh SlowDNS...${NC}"
        wget --no-check-certificate -q "$script_url" -O "$output_file" || {
            echo -e "${RED}Gagal mengunduh script!${NC}"
            return 1
        }
        
        chmod +x "$output_file"
        echo -e "${COLOR1}Memulai instalasi...${NC}"
        ./"$output_file"
        
        # Pembersihan
        rm -f "$output_file"
        echo -e "${COLOR1}Instalasi selesai!${NC}"
    }
    # Fungsi validasi domain
    validate_domain() {
        local domain=$1
        [[ $domain =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]] && return 0 || return 1
    }

    # Fungsi setup domain utama
    setup_main_domain() {
        clear
        echo -e "${COLOR1}┌──────────────────────────────────────────┐${NC}"
        echo -e "${COLOR1}│ ${WH}       PEMBUATAN DOMAIN CUSTOM        ${NC}"
        echo -e "${COLOR1}└──────────────────────────────────────────┘${NC}"

until [[ $dn1 =~ ^[a-zA-Z0-9_.-]+$ ]]; do
read -rp "Masukan subdomain kamu Disini tanpa spasi : " -e dn1
done
echo "$dn1" > /etc/xray/domain
echo "$dn1" > /root/subdomainx
cd
sleep 1
fun_bar 'res1'
clear
rm -rf /root/subdomainx
read -n 1 -s -r -p "  Press any key to Renew Cert or Ctrl + C to Exit"
certv2ray
clear
    }

    # Menu utama
    show_menu() {
        clear
        echo -e "${COLOR1}┌──────────────────────────────────────────┐${NC}"
        echo -e "${COLOR1}│ ${WH}        PILIHAN KONFIGURASI DOMAIN      ${NC}"
        echo -e "${COLOR1}├──────────────────────────────────────────┤${NC}"
        echo -e "${COLOR1}│ [1] Domain Custom                        ${NC}"
        echo -e "${COLOR1}│ [2] Instal SlowDNS                       ${NC}"
        echo -e "${COLOR1}│ [0] Kembali ke Menu Utama                ${NC}"
        echo -e "${COLOR1}└──────────────────────────────────────────┘${NC}"
    }

    # Handler menu
    while true; do
        show_menu
        read -p " Pilih opsi [0-2] : " choice
        
        case $choice in
            1)
                setup_main_domain
                read -n 1 -s -r -p " Tekan sembarang tombol untuk melanjutkan..."
                ;;
            2)
                install_slowdns
                read -n 1 -s -r -p " Instalasi selesai! Tekan tombol untuk melanjutkan..."
                ;;
            0)
                menu
                break
                ;;
            *)
                echo -e "${RED}Pilihan tidak valid!${NC}"
                sleep 1
                ;;
        esac
    done
}

function auto-reboot(){
clear
if [ ! -e /etc/cron.d/re_otm ]; then
rm -rf /etc/cron.d/re_otm
fi
if [ ! -e /usr/local/bin/reboot_otomatis ]; then
echo '#!/bin/bash' > /usr/local/bin/reboot_otomatis
echo 'tanggal=$(date +"%m-%d-%Y")' >> /usr/local/bin/reboot_otomatis
echo 'waktu=$(date +"%T")' >> /usr/local/bin/reboot_otomatis
echo 'echo "Server successfully rebooted on the date of $tanggal hit $waktu." >> /etc/log-reboot.txt' >> /usr/local/bin/reboot_otomatis
echo '/sbin/shutdown -r now' >> /usr/local/bin/reboot_otomatis
chmod +x /usr/local/bin/reboot_otomatis
fi
clear
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\e[0;100;33m       • AUTO-REBOOT MENU •        \e[0m"
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""
echo -e "[\e[36m•1\e[0m] Set Auto-Reboot Setiap 1 Jam"
echo -e "[\e[36m•2\e[0m] Set Auto-Reboot Setiap 6 Jam"
echo -e "[\e[36m•3\e[0m] Set Auto-Reboot Setiap 12 Jam"
echo -e "[\e[36m•4\e[0m] Set Auto-Reboot Setiap 1 Hari"
echo -e "[\e[36m•5\e[0m] Set Auto-Reboot Setiap 1 Minggu"
echo -e "[\e[36m•6\e[0m] Set Auto-Reboot Setiap 1 Bulan"
echo -e "[\e[36m•7\e[0m] Set Auto-Rebooot CPU 100%"
echo -e "[\e[36m•8\e[0m] Matikan Auto-Reboot & Auto-Reboot CPU 100%"
echo -e "[\e[36m•9\e[0m] View reboot log"
echo -e "[\e[36m•10\e[0m] Remove reboot log"
echo -e ""
echo -e " [\e[31m•0\e[0m] \e[31mBACK TO MENU\033[0m"
echo -e ""
echo -e "Press x or [ Ctrl+C ] • To-Exit"
echo -e ""
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""
read -p " Select menu : " x
if test $x -eq 1; then
echo "10 * * * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
echo "Auto-Reboot has been set every an hour."
sleep 2
menu
elif test $x -eq 2; then
echo "10 */6 * * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
echo "Auto-Reboot has been successfully set every 6 hours."
sleep 2
menu
elif test $x -eq 3; then
echo "10 */12 * * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
echo "Auto-Reboot has been successfully set every 12 hours."
sleep 2
menu
elif test $x -eq 4; then
echo -e " CONTOH FORMAT Tiap jam 5 Subuh Tulis 5 "
read -p " Waktu Restart : " wkt
echo "0 $wkt * * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
echo "Auto-Reboot has been successfully set once a day."
sleep 2
menu
elif test $x -eq 5; then
echo -e " CONTOH FORMAT Tiap jam 8 Malam Tulis 20 "
read -p " Waktu Restart : " wkt2
echo "10 $wkt2 */7 * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
echo "Auto-Reboot has been successfully set once a week."
sleep 2
menu
elif test $x -eq 6; then
echo -e " CONTOH FORMAT Tiap jam 10 Malam Tulis 20 "
read -p " Waktu Restart : " wkt3
echo "10 $wkt3 1 * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
echo "Auto-Reboot has been successfully set once a month."
sleep 2
menu
elif test $x -eq 7; then
cat> /etc/cron.d/autocpu << END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/7 * * * * root /usr/bin/autocpu
END
echo "Auto-Reboot CPU 100% TURN ON."
sleep 2
menu
elif test $x -eq 8; then
rm -f /etc/cron.d/reboot_otomatis
rm -f /etc/cron.d/autocpu
echo "Auto-Reboot successfully TURNED OFF."
sleep 2
menu
elif test $x -eq 9; then
if [ ! -e /etc/log-reboot.txt ]; then
clear
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "$COLOR1 ${NC} ${COLBG1}       ${WH} • AUTO-REBOOT •        ${NC} $COLOR1 $NC"
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
echo "No reboot activity found"
echo -e ""
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
auto-reboot
else
clear
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "$COLOR1 ${NC} ${COLBG1}        ${WH}• AUTO-REBOOT •        ${NC} $COLOR1 $NC"
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
echo 'LOG REBOOT'
cat /etc/log-reboot.txt
echo -e ""
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
auto-reboot
fi
elif test $x -eq 10; then
clear
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "$COLOR1 ${NC} ${COLBG1}        ${WH}• AUTO-REBOOT •        ${NC} $COLOR1 $NC"
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
echo "" > /etc/log-reboot.txt
echo "Auto Reboot Log successfully deleted!"
echo -e ""
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
auto-reboot
elif test $x -eq 0; then
clear
menu
else
clear
echo ""
echo "Options Not Found In Menu"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
auto-reboot
fi
}

#===============================================================================#

function certv2ray(){
echo -e ""
echo start
sleep 0.5
source /var/lib/ipvps.conf
domain=$(cat /etc/xray/domain)
STOPWEBSERVER=$(lsof -i:89 | cut -d' ' -f1 | awk 'NR==2 {print $1}')
rm -rf /root/.acme.sh
mkdir /root/.acme.sh
systemctl stop $STOPWEBSERVER
systemctl stop nginx
curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --register-account -m hokage.cfd
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc
chmod 777 /etc/xray/xray.key  
systemctl restart nginx
systemctl restart xray
menu
}

#===============================================================================#

function clearcache(){
clear
echo ""
echo ""
echo -e "[ \033[32mInfo\033[0m ] Clear RAM Cache"
echo 1 > /proc/sys/vm/drop_caches
sleep 3
echo -e "[ \033[32mok\033[0m ] Cache cleared"
echo ""
echo "Back to menu in 3 second "
sleep 3
menu
}

#===============================================================================#

function bot2(){
clear
echo -e "$COLOR1┌──────────────────────────────────────────┐${NC}"
echo -e "$COLOR1     ${WH}Please select a Bot type below              ${NC}"
echo -e "$COLOR1└──────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌──────────────────────────────────────────┐${NC}"
echo -e "$COLOR1  [ 1 ] ${WH}Create BOT INFO Create User & Lain Lain    ${NC}"
echo -e ""
echo -e "$COLOR1  [ 2 ] ${WH}Create BOT INFO Backup Telegram    ${NC}"
echo -e "$COLOR1└──────────────────────────────────────────┘${NC}"
read -p "  Pilih opsi [0-2] : " bot
echo ""
if [[ $bot == "1" ]]; then
clear
rm -rf /etc/per
mkdir -p /etc/per
cd /etc/per
touch token
touch id
echo -e ""
echo -e "$COLOR1 [ INFO ] ${WH}Create for database Akun Dan Lain Lain"
read -rp "Enter Token (Creat on @BotFather) : " -e token3
echo "$token3" > token
read -rp "Enter Your Id (Creat on @userinfobot)  : " -e idat2
echo "$idat2" > id
sleep 1
bot2
fi
if [[ $bot == "2" ]]; then
clear
rm -rf /usr/bin/token
rm -rf /usr/bin/idchat
echo -e ""
echo -e "$COLOR1 [ INFO ] ${WH}Create for database Backup Telegram"
read -rp "Enter Token (Creat on @BotFather) : " -e token23
echo "$token23" > /usr/bin/token
read -rp "Enter Your Id (Creat on @userinfobot)  : " -e idchat
echo "$idchat" > /usr/bin/idchat
sleep 1
bot2
fi
menu
}

#===============================================================================#

function gotopp(){
cd
if [[ -e /usr/bin/gotop ]]; then
gotop
else
git clone --depth 1 https://github.com/cjbassi/gotop /tmp/gotop &> /dev/null
/tmp/gotop/scripts/download.sh &> /dev/null
chmod +x /root/gotop
mv /root/gotop /usr/bin
gotop
fi
}

#===============================================================================#

function coremenu(){
cd
if [[ -e /usr/local/bin/modxray ]]; then
echo -ne
else
wget -O /usr/local/bin/modxray https://github.com/dharak36/Xray-core/releases/download/v1.0.0/xray.linux.64bit &> /dev/null
fi
cd
if [[ -e /usr/local/bin/offixray ]]; then
echo -ne
else
cp -r /usr/local/bin/xray /usr/local/bin/offixray &> /dev/null
fi
clear
echo -e " "
echo -e "$COLOR1┌─────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1│ ${WH}Please select a your Choice to Set CORE MENU           ${NC}"
echo -e "$COLOR1└─────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1│  [ 1 ]  ${WH}XRAY CORE OFFICIAL       ${NC}"
echo -e "$COLOR1│"
echo -e "$COLOR1│  [ 2 ]  ${WH}XRAY CORE MOD    ${NC}"
echo -e "$COLOR1└─────────────────────────────────────────────┘${NC}"
until [[ $core =~ ^[0-9]+$ ]]; do
read -p "   Pilih opsi [0-2] : " core
done
if [[ $core == "1" ]]; then
clear
echo -e " "
cp -r /usr/local/bin/offixray /usr/local/bin/xray &> /dev/null
chmod 755 /usr/local/bin/xray
systemctl restart xray
echo -e "$COLOR1 [ INFO ] ${WH}Succes Change Xray Core Official"
fi
if [[ $core == "2" ]]; then
clear
echo -e " "
cp -r /usr/local/bin/modxray /usr/local/bin/xray &> /dev/null
chmod 755 /usr/local/bin/xray
systemctl restart xray
echo -e  "$COLOR1 [ INFO ] ${WH}Succes Change Xray Core Mod "
fi
read -n 1 -s -r -p "Press any key to back on menu"
menu
}

#===============================================================================#

clear
echo -e " ${COLBG1}                   ${WH}• SYSTEM MENU •                    ${COLBG1}"

echo -e " ${WH}[${COLOR1}01${WH}]${NC} ${COLOR1}• ${WH}CHANGE DOMAIN       ${WH}${WH}[${COLOR1}06${WH}]${NC} ${COLOR1}• ${WH}SETUP BOT INFO     $NC"
echo -e " ${WH}[${COLOR1}02${WH}]${NC} ${COLOR1}• ${WH}CHANGE BANNER       ${WH}${WH}[${COLOR1}07${WH}]${NC} ${COLOR1}• ${WH}FIX NGINX OFF      $NC"
echo -e " ${WH}[${COLOR1}03${WH}]${NC} ${COLOR1}• ${WH}CHANGE CORE MENU    ${WH}${WH}[${COLOR1}08${WH}]${NC} ${COLOR1}• ${WH}CHECK CPU VPS      $NC"
echo -e " ${WH}[${COLOR1}04${WH}]${NC} ${COLOR1}• ${WH}CLEAR RAM CACHE     ${WH}${WH}[${COLOR1}09${WH}]${NC} ${COLOR1}• ${WH}CHECK PORT VPS     $NC"
echo -e " ${WH}[${COLOR1}05${WH}]${NC} ${COLOR1}• ${WH}AUTO REBOOT         ${WH}${WH}[${COLOR1}10${WH}]${NC} ${COLOR1}• ${WH}AUTO REBUILD VM    $NC"
echo -e ""
echo -ne " ${WH}Select menu ${COLOR1}: ${WH}"; read opt
case $opt in
01 |1) clear ; domain ;; 
02 |2) clear ; nano /etc/issue.net && chmod +x /etc/issue.net ;; 
03 |3) clear ; coremenu ;; 
04 |4) clear ; clearcache ;; 
05 |5) clear ; auto-reboot ;; 
06 |6) clear ; bot2 ;; 
06 |7) clear ; certv2ray ;; 
07 |8) clear ; gotopp ;; 
09 |9) clear ; check-port ;; 
10 |10) clear ; wget -q https://github.com/hokagelegend9999/genom/raw/refs/heads/main/rebuildpepesmenu && bash rebuildpepesmenu ;; 
00 |0) clear ; menu ;; 
*) echo -e "" ; echo "Anda salah tekan" ; sleep 1 ; system ;;
esac
