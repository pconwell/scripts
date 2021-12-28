#!/usr/bin/env bash
# curl -sSL https://raw.githubusercontent.com/pconwell/scripts/master/wireguard.sh | bash

apt update && apt upgrade -y
apt-get install -y curl ssh iptables wireguard qrencode qemu-guest-agent
mkdir -p /root/.ssh/
touch /root/.ssh/authorized_keys
curl https://github.com/pconwell.keys >> /root/.ssh/authorized_keys

mkdir -p /etc/wireguard/server
mkdir -p /etc/wireguard/clients

wg genkey | tee /etc/wireguard/server/server.key | wg pubkey | tee /etc/wireguard/server/server.key.pub

echo "[Interface]" >> /etc/wireguard/wg0.conf
echo "Address = 10.0.0.1/24" >> /etc/wireguard/wg0.conf
echo "ListenPort = 51820" >> /etc/wireguard/wg0.conf
echo "PrivateKey = $(cat /etc/wireguard/server/server.key)" >> /etc/wireguard/wg0.conf
echo "PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o $(ip -o -4 route show to default | awk '{print $5}') -j MASQUERADE" >> /etc/wireguard/wg0.conf
echo "PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o $(ip -o -4 route show to default | awk '{print $5}') -j MASQUERADE" >> /etc/wireguard/wg0.conf
echo "SaveConfig = true" >> /etc/wireguard/wg0.conf

wg-quick up wg0
systemctl enable wg-quick@wg0

sed -i '/net.ipv4.ip_forward=1/s/^#//g' /etc/sysctl.conf
sysctl -p

wg genkey | tee /etc/wireguard/clients/patrick.key | wg pubkey | tee /etc/wireguard/clients/patrick.key.pub
wg genkey | tee /etc/wireguard/clients/trisha.key | wg pubkey | tee /etc/wireguard/clients/trisha.key.pub

echo "[Interface]" >> /etc/wireguard/clients/patrick.conf
echo "PrivateKey = $(cat /etc/wireguard/clients/patrick.key)" >> /etc/wireguard/clients/patrick.conf
echo "Address = 10.220.0.2/24" >> /etc/wireguard/clients/patrick.conf
echo "DNS = 192.168.1.103" >> /etc/wireguard/clients/patrick.conf
echo "" >> /etc/wireguard/clients/patrick.conf
echo "[Peer]" >> /etc/wireguard/clients/patrick.conf
echo "PublicKey = $(cat /etc/wireguard/server/server.key.pub)" >> /etc/wireguard/clients/patrick.conf
echo "Endpoint = $(curl ip.me):51820" >> /etc/wireguard/clients/patrick.conf
echo "AllowedIPs = 0.0.0.0/0" >> /etc/wireguard/clients/patrick.conf

echo "[Interface]" >> /etc/wireguard/clients/trisha.conf
echo "PrivateKey = $(cat /etc/wireguard/clients/trisha.key)" >> /etc/wireguard/clients/trisha.conf
echo "Address = 10.220.0.3/24" >> /etc/wireguard/clients/trisha.conf
echo "DNS = 192.168.1.103" >> /etc/wireguard/clients/trisha.conf
echo "" >> /etc/wireguard/clients/trisha.conf
echo "[Peer]" >> /etc/wireguard/clients/trisha.conf
echo "PublicKey = $(cat /etc/wireguard/server/server.key.pub)" >> /etc/wireguard/clients/trisha.conf
echo "Endpoint = $(curl ip.me):51820" >> /etc/wireguard/clients/trisha.conf
echo "AllowedIPs = 0.0.0.0/0" >> /etc/wireguard/clients/trisha.conf

wg set wg0 peer $(cat /etc/wireguard/clients/patrick.key.pub) allowed-ips 10.220.0.2
wg set wg0 peer $(cat /etc/wireguard/clients/trisha.key.pub) allowed-ips 10.220.0.3

shutdown now -r

## After reboot:

## Not sure why it's necessary to take wireguard down and back up - the reboot should take care of this:
# wg-quick down wg0
# wg-quick up wg0

## Generate QR Codes for mobile devices:
# qrencode -t ansiutf8 < /etc/wireguard/clients/patrick.conf
# qrencode -t ansiutf8 < /etc/wireguard/clients/trisha.conf


