#!/usr/bin/env bash
# curl -sSL https://raw.githubusercontent.com/pconwell/scripts/master/wireguard.sh | bash

# Stop wg-quick@wg0 if it is running
if systemctl is-active --quiet wg-quick@wg0; then
    wg-quick down wg0
    systemctl stop wg-quick@wg0
fi

# Delete any existing keys and configurations
rm -rf /etc/wireguard/server
rm -rf /etc/wireguard/clients
rm -f /etc/wireguard/wg0.conf

# Install necessary packages
apt-get update && apt-get upgrade -y && apt-get autoremove -y
apt-get install -y curl iptables wireguard qrencode

# Make necessary directories
mkdir -p /etc/wireguard/server
mkdir -p /etc/wireguard/clients

# Ensure necessary commands are available
for cmd in wg wg-quick qrencode; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is not installed. Please install it and rerun the script."
        exit 1
    fi
done

# Check if /etc/wireguard directory exists
if [ ! -d /etc/wireguard ]; then
    echo "Error: /etc/wireguard directory does not exist. Please create it and rerun the script."
    exit 1
fi

# Check internet connectivity
if ! ping -c 1 google.com &> /dev/null; then
    echo "Error: No internet connectivity. Please check your network and rerun the script."
    exit 1
fi

# Generate server keys
wg genkey | tee /etc/wireguard/server/server.key | wg pubkey | tee /etc/wireguard/server/server.key.pub

# Server configuration
cat <<EOL > /etc/wireguard/wg0.conf
[Interface]
Address = 172.16.1.0/24
ListenPort = 51820
PrivateKey = $(cat /etc/wireguard/server/server.key)
SaveConfig = true
PostUp = iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
PreDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
EOL

# Start WireGuard
wg-quick up wg0
systemctl enable wg-quick@wg0

# Enable IP forwarding
sed -i '/net.ipv4.ip_forward=1/s/^#//g' /etc/sysctl.conf
sysctl -p

# Generate client keys
wg genkey | tee /etc/wireguard/clients/patrick.key | wg pubkey | tee /etc/wireguard/clients/patrick.key.pub
wg genkey | tee /etc/wireguard/clients/trisha.key | wg pubkey | tee /etc/wireguard/clients/trisha.key.pub

# Patrick client configuration
cat <<EOL > /etc/wireguard/clients/patrick.conf
[Interface]
PrivateKey = $(cat /etc/wireguard/clients/patrick.key)
Address = 172.16.1.1/32
DNS = 172.24.0.2

[Peer]
PublicKey = $(cat /etc/wireguard/server/server.key.pub)
Endpoint = $(curl -s ip.me):51820
AllowedIPs = 0.0.0.0/0
EOL

# Trisha client configuration
cat <<EOL > /etc/wireguard/clients/trisha.conf
[Interface]
PrivateKey = $(cat /etc/wireguard/clients/trisha.key)
Address = 172.16.1.2/32
DNS = 172.24.0.2

[Peer]
PublicKey = $(cat /etc/wireguard/server/server.key.pub)
Endpoint = $(curl -s ip.me):51820
AllowedIPs = 0.0.0.0/0
EOL

# Add peers to the server
wg set wg0 peer $(cat /etc/wireguard/clients/patrick.key.pub) allowed-ips 172.16.1.1
wg set wg0 peer $(cat /etc/wireguard/clients/trisha.key.pub) allowed-ips 172.16.1.2

# Generate QR codes
echo "Patrick:"
qrencode -t ansiutf8 -s 2 -r "/etc/wireguard/clients/patrick.conf"
echo "Trisha:"
qrencode -t ansiutf8 -s 1 -r "/etc/wireguard/clients/trisha.conf"

echo "Setup complete. QR codes have been generated."
