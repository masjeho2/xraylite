#!/bin/bash

red() { echo -e "\\033[32;1m${*}\\033[0m"; }

# Getting
MYIP=$(wget -qO- ipinfo.io/ip);
echo "Checking VPS"
CEKEXPIRED () {
    today=$(date -d +1day +%Y-%m-%d)
    Exp1=$(curl -sS https://raw.githubusercontent.com/masjeho2/permission/main/ip | grep $MYIP | awk '{print $3}')
    if [[ $today < $Exp1 ]]; then
    echo -e "\e[32mSTATUS SCRIPT AKTIF...\e[0m"
    else
    echo -e "\e[31mSCRIPT ANDA EXPIRED!\e[0m";
    exit 0
fi
}
IZIN=$(curl -sS https://raw.githubusercontent.com/masjeho2/permission/main/ip | awk '{print $4}' | grep $MYIP)
if [ $MYIP = $IZIN ]; then
echo -e "\e[32mPermission Accepted...\e[0m"
CEKEXPIRED
else
echo -e "\e[31mPermission Denied!\e[0m";
exit 0
fi
clear

domain=$(cat /etc/xray/domain)
clear
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
  echo -e "\033[1;93m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  echo -e "\E[0;41;36m             VLESS ACCOUNT           \E[0m"
  echo -e "\033[1;93m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

  read -rp "User: " -e user
  read -rp "Quota: " -e quota
  read -rp "Limit IP: " -e limit
  CLIENT_EXISTS=$(grep -w $user /etc/xray/config.json | wc -l)

  if [[ ${CLIENT_EXISTS} == '1' ]]; then
    clear
    echo -e "\033[1;93m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[0;41;36m             VLESS ACCOUNT           \E[0m"
    echo -e "\033[1;93m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    echo "A client with the specified name was already created, please choose another name."
    echo ""
    echo -e "\033[1;93m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    read -n 1 -s -r -p "Press any key to back on menu"
    menu
  fi
done
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (days): " masaaktif
exp=$(date -d "$masaaktif days" +"%Y-%m-%d")
sed -i '/#vless$/a\#& '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#vlessgrpc$/a\#& '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json

vlesslink1="vless://${uuid}@${domain}:443?path=/vless&security=tls&encryption=none&type=ws#${user}"
vlesslink2="vless://${uuid}@${domain}:80?path=/vless&encryption=none&type=ws#${user}"
vlesslink3="vless://${uuid}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=${domain}#${user}"

cat >/var/www/html/vless-$user.txt <<-END

# Format Vless WS TLS

- name: Vless-$user-WS TLS
  server: ${domain}
  port: 443
  type: vless
  uuid: ${uuid}
  cipher: auto
  tls: true
  skip-cert-verify: true
  servername: ${domain}
  network: ws
  ws-opts:
    path: /vless
    headers:
      Host: ${domain}

# Format Vless WS Non TLS

- name: Vless-$user-WS (CDN) Non TLS
  server: ${domain}
  port: 80
  type: vless
  uuid: ${uuid}
  cipher: auto
  tls: false
  skip-cert-verify: false
  servername: ${domain}
  network: ws
  ws-opts:
    path: /vless
    headers:
      Host: ${domain}
  udp: true

# Format Vless gRPC (SNI)

- name: Vless-$user-gRPC (SNI)
  server: ${domain}
  port: 443
  type: vless
  uuid: ${uuid}
  cipher: auto
  tls: true
  skip-cert-verify: true
  servername: ${domain}
  network: grpc
  grpc-opts:
  grpc-mode: gun
  grpc-service-name: vless-grpc
  udp: true

-------------------------------------------------------
              Link Akun Vless 
-------------------------------------------------------
Link TLS      : ${vlesslink1}
-------------------------------------------------------
Link none TLS : ${vlesslink2}
-------------------------------------------------------
Link GRPC     : ${vlesslink3}
-------------------------------------------------------


END

systemctl restart xray
systemctl restart nginx
mkdir -p etc/vless/ip
echo ${limit} >> /etc/vless/${user}ip/

if [ ! -e /etc/vless ]; then
  mkdir -p /etc/vless
fi

if [ -z ${quota} ]; then
  Quota="0"
fi

c=$(echo "${quota}" | sed 's/[^0-9]*//g')
d=$((${c} * 1024 * 1024 * 1024))

if [[ ${c} != "0" ]]; then
  echo "${d}" >/etc/vless/${user}
fi
DATADB=$(cat /etc/vless/.vless.db | grep "^#&" | grep -w "${user}" | awk '{print $2}')
if [[ "${DATADB}" != '' ]]; then
  sed -i "/\b${user}\b/d" /etc/vless/.vless.db
fi
echo "#& ${user} ${exp} ${uuid} " >>/etc/vless/.vless.db
CHATID="1658354197"
KEY="6581548016:AAGmvN9Dcx24QiOnNIp9DVilqCN2fCzMTas"
WKT="10"
URL="https://api.telegram.org/bot$KEY/sendMessage"
TEXT="
───────────────────────────
    Xray/Vless Account
───────────────────────────
Remarks     : <code>${user}</code>
Domain      : <code>${domain}</code>
Quota       : <code>${quota} GB</code>
Limit iP    : <code>${limit} User</code>
port TLS    : <code>443</code>
Port DNS    : <code>443</code>
Port NTLS   : <code>80</code>
User ID     : <code>${uuid}</code>
Encryption  : <code>none</code>
Path TLS    : <code>/vless </code>
ServiceName : <code>vless-grpc</code>
───────────────────────────
Link TLS    : <code>${vlesslink1}</code>
───────────────────────────
Link NTLS   : <code>${vlesslink2}</code>
───────────────────────────
Link GRPC   : <code>${vlesslink3}</code>
───────────────────────────
Format OpenClash : <code>https://${domain}:81/vless-$user.txt</code>
───────────────────────────
Expired On : <code>$exp</code>
───────────────────────────
"
curl -s --max-time $WKT -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
clear
echo -e "\033[1;93m───────────────────────────\033[0m" | tee -a /root/akun/vless/$user.txt
echo -e "\E[0;41;36m    Xray/Vless Account     \E[0m" | tee -a /root/akun/vless/$user.txt
echo -e "\033[1;93m───────────────────────────\033[0m" | tee -a /root/akun/vless/$user.txt
echo -e "Remarks     : ${user}" | tee -a /root/akun/vless/$user.txt
echo -e "Domain      : ${domain}" | tee -a /root/akun/vless/$user.txt
echo -e "Quota       : ${quota} GB" 
echo -e "Limit iP    : ${limit} User" 
echo -e "port TLS    : 443" | tee -a /root/akun/vless/$user.txt
echo -e "Port DNS    : 443" | tee -a /root/akun/vless/$user.txt
echo -e "Port NTLS   : 80" | tee -a /root/akun/vless/$user.txt
echo -e "User ID     : ${uuid}" | tee -a /root/akun/vless/$user.txt
echo -e "Encryption  : none" | tee -a /root/akun/vless/$user.txt
echo -e "Path TLS    : /vless " | tee -a /root/akun/vless/$user.txt
echo -e "ServiceName : vless-grpc" | tee -a /root/akun/vless/$user.txt
echo -e "\033[1;93m───────────────────────────\033[0m" | tee -a /root/akun/vless/$user.txt
echo -e "Link TLS    : ${vlesslink1}" | tee -a /root/akun/vless/$user.txt
echo -e "\033[1;93m───────────────────────────\033[0m" | tee -a /root/akun/vless/$user.txt
echo -e "Link NTLS   : ${vlesslink2}" | tee -a /root/akun/vless/$user.txt
echo -e "\033[1;93m───────────────────────────\033[0m" | tee -a /root/akun/vless/$user.txt
echo -e "Link GRPC   : ${vlesslink3}" | tee -a /root/akun/vless/$user.txt
echo -e "\033[1;93m───────────────────────────\033[0m" | tee -a /root/akun/vless/$user.txt
echo -e "Format OpenClash : https://${domain}:81/vless-$user.txt" | tee -a /root/akun/vless/$user.txt
echo -e "\033[1;93m───────────────────────────\033[0m" | tee -a /root/akun/vless/$user.txt
echo -e "Expired On : $exp" | tee -a /root/akun/vless/$user.txt
echo -e "\033[1;93m───────────────────────────\033[0m" | tee -a /root/akun/vless/$user.txt
echo -e "" | tee -a /root/akun/vless/$user.txt
read -n 1 -s -r -p "Press any key to back on menu"

menu
