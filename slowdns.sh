#!/bin/bash
# Script  By nstaller slowdns
# 2025 SLOWDNS
# ===============================================


#setting IPtables
iptables -I INPUT -p udp --dport 5300 -j ACCEPT
iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300
netfilter-persistent save
netfilter-persistent reload

cd
#delete directory
rm -rf /etc/nsdomain
rm nsdomain

#input nameserver manual to cloudflare
## read -rp "Masukkan domain: " -e domain

## read -rp "Masukkan Subdomain: " -e sub
## SUB_DOMAIN=${sub}.${domain}
## NS_DOMAIN=slowdns-${SUB_DOMAIN}
## echo $NS_DOMAIN > /root/nsdomain

nameserver=$(cat /etc/nsdomain)
apt update -y
apt install -y python3 python3-dnslib net-tools
apt install ncurses-utils -y
apt install dnsutils -y
#apt install golang -y
apt install git -y
apt install curl -y
apt install wget -y
apt install ncurses-utils -y
apt install screen -y
apt install cron -y
apt install iptables -y
apt install -y git screen whois dropbear wget
#apt install -y pwgen python php jq curl
apt install -y sudo gnutls-bin
#apt install -y mlocate dh-make libaudit-dev build-essential
apt install -y dos2unix debconf-utils
service cron reload
service cron restart

#tambahan port openssh
cd
echo "Port 2222" >> /etc/ssh/sshd_config
echo "Port 2269" >> /etc/ssh/sshd_config
sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding yes/g' /etc/ssh/sshd_config
service ssh restart
service sshd restart

#konfigurasi slowdns
rm -rf /etc/slowdns
mkdir -m 777 /etc/slowdns
wget -q -O /etc/slowdns/server.key "https://raw.githubusercontent.com/Pemulaajiw/script/refs/heads/main/slowdns/client"
wget -q -O /etc/slowdns/server.pub "https://raw.githubusercontent.com/Pemulaajiw/script/refs/heads/main/slowdns/server.pub"
wget -q -O /etc/slowdns/sldns-server "https://raw.githubusercontent.com/Pemulaajiw/script/refs/heads/main/slowdns/dnstt-server"
wget -q -O /etc/slowdns/sldns-client "https://raw.githubusercontent.com/Pemulaajiw/script/refs/heads/main/slowdns/dnstt-client"
cd
chmod +x /etc/slowdns/client
chmod +x /etc/slowdns/server.pub
chmod +x /etc/slowdns/dnstt-server
chmod +x /etc/slowdns/dnstt-client

cd
#install client-sldns.service
cat > /etc/systemd/system/client-dnstt.service << END
[Unit]
Description=Client SlowDNS By FANSTORE
Documentation=https://t.me/AJW29
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/etc/slowdns/dnstt-client -udp 8.8.8.8:53 --pubkey-file /etc/slowdns/server.pub $nameserver 127.0.0.1:2222
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

cd
#install server-dnstt.service
cat > /etc/systemd/system/server-dnstt.service << END
[Unit]
Description=Server SlowDNS By FAN STORE
Documentation=https://t.me/AJW29
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/etc/slowdns/dnstt-server -udp :5300 -privkey-file /etc/slowdns/client $nameserver 127.0.0.1:2269
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

#permission service slowdns
cd
chmod +x /etc/systemd/system/client-dnstt.service

chmod +x /etc/systemd/system/server-dnstt.service
pkill dnstt-server
pkill dnstt-client

systemctl daemon-reload
systemctl stop client-dnstt
systemctl stop server-dnstt

systemctl enable client-dnstt
systemctl enable server-dnstt

systemctl start client-dnstt
systemctl start server-dnstt

systemctl restart client-dnstt
systemctl restart server-dnstt
