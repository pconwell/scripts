#!/usr/bin/env bash
# curl -sSL https://raw.githubusercontent.com/pconwell/scripts/master/wireguard.sh | bash

apt update && apt upgrade -y && apt autoremove -y
apt-get install -y curl wireguard qrencode

mkdir -p /etc/wireguard/server
mkdir -p /etc/wireguard/clients

wg genkey | tee /etc/wireguard/server/server.key | wg pubkey | tee /etc/wireguard/server/server.key.pub

echo "[Interface]" >> /etc/wireguard/wg0.conf
echo "Address = 172.16.0.0/30" >> /etc/wireguard/wg0.conf
echo "ListenPort = 51820" >> /etc/wireguard/wg0.conf
echo "PrivateKey = $(cat /etc/wireguard/server/server.key)" >> /etc/wireguard/wg0.conf
echo "SaveConfig = true" >> /etc/wireguard/wg0.conf

wg-quick up wg0
systemctl enable wg-quick@wg0

sed -i '/net.ipv4.ip_forward=1/s/^#//g' /etc/sysctl.conf
sysctl -p

wg genkey | tee /etc/wireguard/clients/patrick.key | wg pubkey | tee /etc/wireguard/clients/patrick.key.pub
wg genkey | tee /etc/wireguard/clients/trisha.key | wg pubkey | tee /etc/wireguard/clients/trisha.key.pub

echo "[Interface]" >> /etc/wireguard/clients/patrick.conf
echo "PrivateKey = $(cat /etc/wireguard/clients/patrick.key)" >> /etc/wireguard/clients/patrick.conf
echo "Address = 172.16.0.1/30" >> /etc/wireguard/clients/patrick.conf
echo "DNS = 192.168.1.16" >> /etc/wireguard/clients/patrick.conf
echo "" >> /etc/wireguard/clients/patrick.conf
echo "[Peer]" >> /etc/wireguard/clients/patrick.conf
echo "PublicKey = $(cat /etc/wireguard/server/server.key.pub)" >> /etc/wireguard/clients/patrick.conf
echo "Endpoint = $(curl ip.me):51820" >> /etc/wireguard/clients/patrick.conf
echo "AllowedIPs = 0.0.0.0/0" >> /etc/wireguard/clients/patrick.conf

echo "[Interface]" >> /etc/wireguard/clients/trisha.conf
echo "PrivateKey = $(cat /etc/wireguard/clients/trisha.key)" >> /etc/wireguard/clients/trisha.conf
echo "Address = 172.16.0.2/24" >> /etc/wireguard/clients/trisha.conf
echo "DNS = 192.168.1.16" >> /etc/wireguard/clients/trisha.conf
echo "" >> /etc/wireguard/clients/trisha.conf
echo "[Peer]" >> /etc/wireguard/clients/trisha.conf
echo "PublicKey = $(cat /etc/wireguard/server/server.key.pub)" >> /etc/wireguard/clients/trisha.conf
echo "Endpoint = $(curl ip.me):51820" >> /etc/wireguard/clients/trisha.conf
echo "AllowedIPs = 0.0.0.0/0" >> /etc/wireguard/clients/trisha.conf

wg set wg0 peer $(cat /etc/wireguard/clients/patrick.key.pub) allowed-ips 172.16.0.1
wg set wg0 peer $(cat /etc/wireguard/clients/trisha.key.pub) allowed-ips 172.16.0.2

qrencode -t ansiutf8 -r "/etc/wireguard/clients/patrick.conf"
qrencode -t ansiutf8 -r "/etc/wireguard/clients/trisha.conf"

# shutdown now -r

## After reboot:
## Not sure why this is necessary - the script is probably messing something up...

# wg set wg0 peer $(cat /etc/wireguard/clients/patrick.key.pub) allowed-ips 10.220.0.2
# wg-quick down wg0
# wg-quick up wg0

# wg set wg0 peer $(cat /etc/wireguard/clients/trisha.key.pub) allowed-ips 10.220.0.3
# wg-quick down wg0
# wg-quick up wg0
