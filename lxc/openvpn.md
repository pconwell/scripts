1. create priviliged container
2. nesting=1
3. mknod=1

```
apt install openvpn
wget -P ~/ https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.6/EasyRSA-unix-v3.0.6.tgz
tar xvf EasyRSA-unix-v3.0.6.tgz 
cd EasyRSA-v3.0.6/
cp vars.example vars
nano vars

  # uncomment:
  set_var EASYRSA_REQ_COUNTRY     "US"
  set_var EASYRSA_REQ_PROVINCE    "STATE"
  set_var EASYRSA_REQ_CITY        "CIT"
  set_var EASYRSA_REQ_ORG         "ORG"
  set_var EASYRSA_REQ_EMAIL       "EMAIL"
  set_var EASYRSA_REQ_OU          "VPN"


./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa gen-req server nopass
cp ./pki/private/server.key /etc/openvpn/

./easyrsa sign-req server server
cp ./pki/issued/server.crt /etc/openvpn/
cp ./pki/ca.crt /etc/openvpn/

./easyrsa gen-dh

openvpn --genkey --secret ta.key
cp ta.key /etc/openvpn
cp ./pki/dh.pem /etc/openvpn

mkdir -p ~/client-configs/keys

./easyrsa gen-req patrick nopass
cp pki/private/patrick.key ~/client-configs/keys/

./easyrsa sign-req client patrick
cp ./pki/issued/patrick.crt ~/client-configs/keys/

cp ta.key ~/client-configs/keys/
cp /etc/openvpn/ca.crt ~/client-configs/keys/

cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/
gzip -d /etc/openvpn/server.conf.gz 
nano /etc/openvpn/server.conf 

  # make sure the following lines look like this
  dh dh.pem #change from dh2048.pem
  push "redirect-gateway def1 bypass-dhcp" #uncomment
  push "dhcp-option DNS 208.67.222.222" #uncomment
  push "dhcp-option DNS 208.67.220.220" #uncomment
  tls-auth ta.key 0 # This file is secret
  cipher AES-256-CBC
  auth SHA256 # add this after cipher
  user nobody #uncomment
  group nogroup #uncomment


nano /etc/sysctl.conf

  #uncommment the following line
  net.ipv4.ip_forward=1


sysctl -p

cd /dev
mkdir net
mknod net/tun c 10 200

systemctl start openvpn@server
systemctl status openvpn@server

systemctl enable openvpn@server

mkdir -p ~/client-configs/files
cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf ~/client-configs/base.conf
nano ~/client-configs/base.conf

  # change the following
  remote 192.168.1.96 1194
  user nobody
  group nogroup
  #ca ca.crt #comment out
  #cert client.crt #comment out
  #key client.key #comment out
  #tls-auth ta.key 1 #comment out
  cipher AES-256-CBC
  auth SHA256 # add after cipher
  key-direction 1 # add
  # script-security 2 # add as commented out
  # up /etc/openvpn/update-resolv-conf # add as commented out
  # down /etc/openvpn/update-resolv-conf # add as commented out
  
  
nano ~/client-configs/make_config.sh

  # copy/paste:
  #!/bin/bash

  # First argument: Client identifier

  KEY_DIR=/root/client-configs/keys
  OUTPUT_DIR=/root/client-configs/files
  BASE_CONFIG=/root/client-configs/base.conf

  cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    ${KEY_DIR}/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    ${KEY_DIR}/${1}.crt \
    <(echo -e '</cert>\n<key>') \
    ${KEY_DIR}/${1}.key \
    <(echo -e '</key>\n<tls-auth>') \
    ${KEY_DIR}/ta.key \
    <(echo -e '</tls-auth>') \
    > ${OUTPUT_DIR}/${1}.ovpn


chmod +x ~/client-configs/make_config.sh
./make_config.sh patrick



```

https://www.reddit.com/r/Proxmox/comments/cx36p8/proxmox_606_lxc_and_openvpn/

https://www.digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-debian-10
