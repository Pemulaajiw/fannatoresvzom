#!/bin/bash
# the domain you want to ping test
url="nhentai.net"
# do a ping check against the url and cut only the ping text
ping=$(ping_result=$(ping -c 1 $url | grep -oP 'time=\K\d+\.\d+')
if (( $(echo "$ping_result < 100" | bc -l) )); then
    echo -e "\e[32m$ping_result ms\e[0m"
elif (( $(echo "$ping_result < 200" | bc -l) )); then
    echo -e "\e[33m$ping_result ms\e[0m"
else
    echo -e "\e[31m$ping_result ms\e[0m"
fi)
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
export ORANGE='\033[0;91m'
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
            client="${fields[1]}"  # Kolom 2
            exprd="${fields[2]}"     # Kolom 3

            # Bersihkan tanggal dari karakter khusus
            exprd=$(echo "$exprd" | sed 's/[^0-9-]//g' | xargs)

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
    if ! [[ "$exprd" =~ ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$ ]]; then
        echo -e "${RED}❌ Format tanggal invalid: '$exprd' (harus YYYY-MM-DD)${NC}"
        exit 1
    fi

    # Validasi tanggal menggunakan date
    if ! date -d "$exprd" "+%s" &>/dev/null; then
        echo -e "${RED}❌ Tanggal tidak valid secara kalender: $exprd${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ IP tidak terdaftar!${NC}"
    echo -e "➥ Hubungi admin ${CYAN}「 ✦ @HokageLegend ✦ 」${NC}"
    exit 1
fi

# =============================================
#          [ Hitung Hari Tersisa ]
# =============================================
current_epoch=$(date +%s)
exp_epoch=$(date -d "$exprd" +%s)

if (( exp_epoch < current_epoch )); then
    echo -e "${RED}❌ Masa aktif telah habis!${NC}"
    exit 1
fi

days_remaining=$(( (exp_epoch - current_epoch) / 86400 ))

# =============================================
#          [ Pengecekan Dependency ]
# =============================================
if ! command -v jq &>/dev/null; then
    echo -e "${YELLOW}⚠️ Installing jq...${NC}"
    sudo apt-get install jq -y
fi

# IP Information Setup
IPINFO_TOKEN="Abc12345"  # Ganti dengan token Anda

# System Information
get_sys_info() {
    # OS Info
    OS=$(lsb_release -ds | sed 's/"//g' 2>/dev/null || cat /etc/*release | head -n1)
    SERONLINE=$(uptime -p | cut -d " " -f 2-10000)

    # Memory Info
    RAM=$(free -m | awk '/Mem:/ {printf "%.0fM", $2}')
    SWAP=$(free -m | awk '/Swap:/ {printf "%.0fM", $2}')

    # CPU Info
    CORE=$(nproc)
    CPU_USAGE=$(top -bn1 | awk '/Cpu/ {printf "%.1f%%", 100 - $8}')
}

# Network Information
get_net_info() {
    # IP Address
    IPVPS=$(curl -s4 --connect-timeout 3 ifconfig.me || echo "Unknown")
    ISP=$(curl -s --connect-timeout 3 ip-api.com/json/${IPVPS} | grep -Po '"isp":\s*"\K[^"]*' || echo "Unknown")
    CITY=$(curl -s --connect-timeout 3 ip-api.com/json/${IPVPS} | grep -Po '"city":\s*"\K[^"]*' || echo "Unknown")

    if [ -z "$ISP" ]; then
        ISP=$(curl -s ipapi.co/org)
    fi
    if [ -z "$CITY" ]; then
        CITY=$(curl -s ipapi.co/city)
    fi

    # Domain Info
    DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "Not Set")
}

# Uptime Calculation
get_uptime() {
    uptime="$(uptime -p | cut -d " " -f 2-10)"
    uptime_sec=$(awk '{print $1}' /proc/uptime | cut -d. -f1)
    days=$((uptime_sec/86400))
    hours=$(( (uptime_sec%86400)/3600 ))
    minutes=$(( (uptime_sec%3600)/60 ))

    if [ $days -gt 0 ]; then
        echo "${days}d ${hours}h ${minutes}m"
    else
        echo "${hours}h ${minutes}m"
    fi
}

#######################################
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
MYIP=$(curl -sS ipv4.icanhazip.com)
#######################################
colornow=$(cat /etc/rmbl/theme/color.conf)
colorfont=$(cat /etc/rmbl/warnafont/warnaf.conf)
export COLOR1="$(cat /etc/rmbl/theme/$colornow | grep -w "TEXT" | cut -d: -f2|sed 's/ //g')"
export COLBG1="$(cat /etc/rmbl/theme/$colornow | grep -w "BG" | cut -d: -f2|sed 's/ //g')"
export WH="$(cat /etc/rmbl/warnafont/$colorfont | grep -w "WARNAF" | cut -d: -f2|sed 's/ //g')"
export NC="\e[0m"
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export yl='\033[0;33m';
export RED="\033[0;31m"
WH='\033[1;37m'
#######################################
# Server Information
date_server=$(date -u +"%Y-%m-%d")
wkt_server=$(timedatectl | grep "Time zone" | awk '{print $3}' | tr -d '()')

# RAM Information
tram=$(free -h | awk '/Mem:/ {print $2}')
uram=$(free -h | awk '/Mem:/ {print $3}')
#######################################
# Network Information
ipsaya=$(curl -s4 ifconfig.me)
IPVPS=$(curl -s4 ifconfig.me)
ISP=$(curl -s ipinfo.io/org | cut -d ' ' -f 2-10)
CITY=$(curl -s ipinfo.io/city)
#######################################

mai="datediff "$Exp" "$DATE""

# CERTIFICATE STATUS
d1=$(date -d "$Exp2" +%s)
d2=$(date -d "$today" +%s)
certificate=$(( (d1 - d2) / 86400 ))

WKT=$(curl -s ipinfo.io/timezone?token=$ipn )
DAY=$(date +%A)
DATE=$(date +%m/%d/%Y)
DATE2=$(date -R | cut -d " " -f -5)
MYIP=$(curl -sS ipv4.icanhazip.com)

cd
if [ ! -e /etc/per/id ]; then
  mkdir -p /etc/per
  echo "" > /etc/per/id
  echo "" > /etc/per/token
elif [ ! -e /etc/perlogin/id ]; then
  mkdir -p /etc/perlogin
  echo "" > /etc/perlogin/id
  echo "" > /etc/perlogin/token
elif [ ! -e /usr/bin/id ]; then
  echo "" > /usr/bin/idchat
  echo "" > /usr/bin/token
fi

if [ ! -e /etc/xray/ssh ]; then
  echo "" > /etc/xray/ssh
elif [ ! -e /etc/xray/sshx ]; then
  mkdir -p /etc/xray/sshx
elif [ ! -e /etc/xray/sshx/listlock ]; then
  echo "" > /etc/xray/sshx/listlock
elif [ ! -e /etc/vmess ]; then
  mkdir -p /etc/vmess
elif [ ! -e /etc/vmess/listlock ]; then
  echo "" > /etc/vmess/listlock
elif [ ! -e /etc/vless ]; then
  mkdir -p /etc/vless
elif [ ! -e /etc/vless/listlock ]; then
  echo "" > /etc/vless/listlock
elif [ ! -e /etc/trojan ]; then
  mkdir -p /etc/trojan
elif [ ! -e /etc/trojan/listlock ]; then
  echo "" > /etc/trojan/listlock
fi
clear
MODEL2=$(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')
LOADCPU=$(printf '%-0.00001s' "$(top -bn1 | awk '/Cpu/ { cpu = "" 100 - $8 "%" }; END { print cpu }')")
CORE=$(printf '%-1s' "$(grep -c cpu[0-9] /proc/stat)")
cpu_usage1="$(ps aux | awk 'BEGIN {sum=0} {sum+=$3}; END {print sum}')"
cpu_usage="$((${cpu_usage1/\.*} / ${corediilik:-1}))"
cpu_usage+=" %"
author=$(cat /etc/profil)
function speed(){
cd
if [[ -e /etc/speedi ]]; then
speedtest
else
sudo apt-get install curl
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
sudo apt-get install speedtest
touch /etc/speedi
speedtest
fi
}
# usage
vnstat_profile=$(vnstat | sed -n '3p' | awk '{print $1}' | grep -o '[^:]*')
vnstat -i ${vnstat_profile} >/etc/t1
bulan=$(date +%b)
tahun=$(date +%y)
ba=$(curl -s https://pastebin.com/raw/0gWiX6hE)
today=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $8}')
todayd=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $8}')
today_v=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $9}')
today_rx=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $2}')
today_rxv=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $3}')
today_tx=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $5}')
today_txv=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $6}')
if [ "$(grep -wc ${bulan} /etc/t1)" != '0' ]; then
    bulan=$(date +%b)
    month=$(vnstat -i ${vnstat_profile} | grep "$bulan $ba$tahun" | awk '{print $9}')
    month_v=$(vnstat -i ${vnstat_profile} | grep "$bulan $ba$tahun" | awk '{print $10}')
    month_rx=$(vnstat -i ${vnstat_profile} | grep "$bulan $ba$tahun" | awk '{print $3}')
    month_rxv=$(vnstat -i ${vnstat_profile} | grep "$bulan $ba$tahun" | awk '{print $4}')
    month_tx=$(vnstat -i ${vnstat_profile} | grep "$bulan $ba$tahun" | awk '{print $6}')
    month_txv=$(vnstat -i ${vnstat_profile} | grep "$bulan $ba$tahun" | awk '{print $7}')
else
    bulan2=$(date +%Y-%m)
    month=$(vnstat -i ${vnstat_profile} | grep "$bulan2 " | awk '{print $8}')
    month_v=$(vnstat -i ${vnstat_profile} | grep "$bulan2 " | awk '{print $9}')
    month_rx=$(vnstat -i ${vnstat_profile} | grep "$bulan2 " | awk '{print $2}')
    month_rxv=$(vnstat -i ${vnstat_profile} | grep "$bulan2 " | awk '{print $3}')
    month_tx=$(vnstat -i ${vnstat_profile} | grep "$bulan2 " | awk '{print $5}')
    month_txv=$(vnstat -i ${vnstat_profile} | grep "$bulan2 " | awk '{print $6}')
fi
if [ "$(grep -wc yesterday /etc/t1)" != '0' ]; then
    yesterday=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $8}')
    yesterday_v=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $9}')
    yesterday_rx=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $2}')
    yesterday_rxv=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $3}')
    yesterday_tx=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $5}')
    yesterday_txv=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $6}')
else
    yesterday=NULL
    yesterday_v=NULL
    yesterday_rx=NULL
    yesterday_rxv=NULL
    yesterday_tx=NULL
    yesterday_txv=NULL
fi

# // SSH Websocket Proxy
ssh_ws=$( systemctl status ws-stunnel | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' )
if [[ $ssh_ws == "running" ]]; then
    status_ws="${COLOR1}ON${NC}"
else
    status_ws="${RED}OFF${NC}"
fi

# SSH Websocket Proxy
ssh_ws=$( systemctl status ws | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' )
if [[ $ssh_ws == "running" ]]; then
    status_ws_epro="${GREEN}ON${NC}"
else
    status_ws_epro="${RED}OFF${NC}"
fi

# // nginx
nginx=$( systemctl status nginx | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' )
if [[ $nginx == "running" ]]; then
    status_nginx="${COLOR1}ON${NC}"
else
    status_nginx="${RED}OFF${NC}"
    systemctl start nginx
fi

# // Dropbear
dropbear_status=$(/etc/init.d/dropbear status | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
if [[ $dropbear_status == "running" ]]; then
   status_beruangjatuh="${COLOR1}ON${NC}"
else
   status_beruangjatuh="${RED}OFF${NC}"
fi

# // SSH Websocket Proxy
xray=$(systemctl status xray | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
if [[ $xray == "running" ]]; then
    status_xray="${COLOR1}ON${NC}"
else
    status_xray="${RED}OFF${NC}"
fi

# STATUS SERVICE NOOBZ
if [[ $stat_noobz == "running" ]]; then
    stat_noobz="${GREEN}ON${NC}"
else
    stat_noobz="${RED}OFF${NC}"
    systemctl start noobzvpns
fi

stat_trgo=$( systemctl status trojan-go | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' )
if [[ $stat_trgo == "running" ]]; then
    stat_trgo="${GREEN}ON${NC}"
else
    stat_trgo="${RED}OFF${NC}"
    systemctl start trojan-go
fi
# STATUS EXPIRED ACTIVE
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[4$below" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}( Registered )${Font_color_suffix}"
Error="${Green_font_prefix}${Font_color_suffix}${Red_font_prefix}[ EXPIRED ]${Font_color_suffix}"

today=$(date -d "0 days" +"%Y-%m-%d")
if [[ $today < $Exp2 ]]; then
    sts="${Info}"
else
    sts="${Error}"
fi
# TOTAL ACC CREATE VMESS WS
vmess=$(grep -c -E "^#vmg " "/etc/xray/config.json")
# TOTAL ACC CREATE  VLESS WS
vless=$(grep -c -E "^#vlg " "/etc/xray/config.json")
# TOTAL ACC CREATE  TROJAN
trtls=$(grep -c -E "^#trg " "/etc/xray/config.json")
# TOTAL ACC CREATE OVPN SSH
total_ssh=$(grep -c -E "^### " "/etc/xray/ssh")
#total_ssh="$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)"
# TOTAL ACC CREATE NOOB & TRGO
jumlah_noobz=$(grep -c -E "^### " "/etc/xray/noob")
jumlah_trgo=$(grep -c -E "^### " "/etc/trojan-go/trgo")

# Main Display
clear
get_sys_info
get_net_info
clear
clear && clear && clear
clear;clear;clear    
echo -e "$COLBG1              $WH☯ MERAUKE PROJECT TUNNELING ☯              $COLBG1"
# Sistem
echo -e "   $COLOR1• $WH SYSTEM    : $(grep -w PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"' | cut -d '.' -f 1-3 2>/dev/null || echo "Unable to detect system")"

# RAM
echo -e "   $COLOR1• $WH RAM       : $(free -m | awk 'NR==2 {print $3 "MB / " $2 "MB"}')"

# Uptime
echo -e "   $COLOR1• $WH UPTIME    : $(uptime -p 2>/dev/null | cut -d ' ' -f 2-10000 || echo "Unable to detect uptime")"

# CPU Core
echo -e "   $COLOR1• $WH CPU CORE  : $(nproc 2>/dev/null || echo "N/A")"

# ISP
echo -e "   $COLOR1• $WH ISP       : $(curl -s ipinfo.io/org 2>/dev/null | cut -d ' ' -f 2-100 || echo "Unable to detect ISP")"

# City
echo -e "   $COLOR1• $WH CITY      : $(curl -s ipinfo.io/city 2>/dev/null || echo "Unable to detect city")"

# IP Publik
echo -e "   $COLOR1• $WH IP        : $(curl -s ipv4.icanhazip.com 2>/dev/null || echo "Unable to detect IP")"

# Domain
echo -e "   $COLOR1• $WH DOMAIN    : $(head -n1 /etc/xray/domain 2>/dev/null || echo "No domain registered")"
# Date & Time
echo -e "   $COLOR1• $WH DATE & TIME   : $(head -n1 /etc/xray/domain 2>/dev/null || echo "No domain registered")"
# Masa Aktif & Ping
echo -e "   $COLOR1• $WH MASA AKTIF    : $(head -n1 /etc/xray/domain 2>/dev/null || echo "No domain registered")"

echo -e "$COLOR1  CLIENT    = $COLBG1$WH$client                           $COLBG1${NC}"
echo -e "$COLOR1  EXPIRED   = $COLBG1$WH$exprd                            $COLBG1${NC}"
echo -e "$COLOR1  AUTHOR    = $COLBG1$WH$author TUNNELING                 $COLBG1${NC}"
echo -e "$COLOR1  VERSION   = $COLBG1$WHSUPER LTS                         $COLBG1${NC}"
echo -e "$COLOR1  CLIENT $WH: $client$NC"
echo -e "$COLOR1  DATE & TIME $WH: $DATE2$NC"
echo -e "$COLOR1  EXPIRED $WH: $exprd$NC"
echo -e "$COLOR1  AUTHOR $WH: $author$NC"
echo -e "$COLOR1  MASA AKTIF $WH: $days_remaining hari$NC"
echo -e "$COLOR1  VERSI $WH: $(cat /opt/.ver) Latest Version$NC"
echo -e "$COLOR1  $ping \e[037;1m [ $url ]$NC"
echo -e "$COLBG1                 $WH[🛠️] STATUS SERVICE                  $COLBG1"
echo -e "$COLOR1 SSH     :$status_ws""  NGINX     :$status_nginx""  XRAY    :$status_xray""  DROPBEAR : $status_beruangjatuh"
echo -e "$COLOR1 SSH       VMESS         VLESS        TROJAN        NOOBZVPN        TROJANGO $NC"
echo -e "$COLOR1  $total_ssh        $vmess            $vless            $trtls            $jumlah_noobz            $jumlah_trgo $NC"
echo -e "$COLBG1                 $WH☯ MENU AUTOSCRIPT ☯                 $COLBG1"
echo -e "$COLOR1[$WH 01 $COLOR1]$WH SSH Menu        $COLOR1[$WH 06 $COLOR1]$WH Bot Menu"
echo -e "$COLOR1[$WH 02 $COLOR1]$WH XRAY Menu       $COLOR1[$WH 07 $COLOR1]$WH Running Menu"
echo -e "$COLOR1[$WH 03 $COLOR1]$WH NoobZ Menu      $COLOR1[$WH 08 $COLOR1]$WH Restart Menu"
echo -e "$COLOR1[$WH 04 $COLOR1]$WH Backup Menu     $COLOR1[$WH 09 $COLOR1]$WH System Menu"
echo -e "$COLOR1[$WH 05 $COLOR1]$WH Theme Menu      $COLOR1[$WH 10 $COLOR1]$WH Update Menu"
echo -e "$COLOR1[        MENU REBOOT SILAHKAN KETIK MENU 11" | lolcat
echo -e " [\e[36m•x\e[0m] Exit Panel"
echo -e "$COLBG1              $WH☯ INFORMASI BANDWIDTH ☯               $COLBG1"
echo -e "${WH}$COLOR1 HARI ini: ${WH}$todayd $today_v ${COLOR1}KEMARIN: ${WH}$yesterday $yesterday_v ${COLOR1}BULAN: ${WH}$month $month_v ${COLOR1}SPEED: ${WH}$speed $NC"
echo -e " "
echo -ne " ${WH}Select menu ${COLOR1}: ${WH}"; read opt
case $opt in
01 | 1) clear ; sshws ;;
02 | 2) clear ; m-xray ;;
03 | 3) clear ; m-noobz ;;
04 | 4) clear ; menu-backup;;
05 | 5) clear ; m-theme ;;
06 | 6) clear ; m-bot ;;
07 | 7) clear ; cekservice ;;
08 | 8) clear ; running ;;
09 | 9) clear ; system ;;
10) clear ; m-update ;;
11) clear ; reboot ;;
00 | 0) clear ; menu ;;
*) clear ; menu ;;
esac
