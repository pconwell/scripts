## Plex

> NOTE: The server and local device used during install/config MUST be on the same subnet during installation.

Create priviliged container (to mount NFS shares)
Provision as appropriate (ajust as needed):
- 16 cores
- 16 GB RAM
- 128 GB HD space

Options -> Features -> NFS  
Boot CT  

```
apt update && apt upgrade -y && apt autoremove -y
apt install -y curl gpg
curl -fsSL https://downloads.plex.tv/plex-keys/PlexSign.key | gpg --dearmor -o /usr/share/keyrings/plex-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/plex-archive-keyring.gpg] https://downloads.plex.tv/repo/deb public main" | tee /etc/apt/sources.list.d/plexmediaserver.list
apt update && apt install -y plexmediaserver nfs-common
mkdir -p /mnt/unraid/MEDIA
```
nano /etc/fstab  
add: `NAS_IP:/mnt/user/MEDIA/    /mnt/unraid/MEDIA    nfs     ro,defaults,rsize=65536,timeo=14,intr    0    0`

mount -a

http://IP_ADDRESS:32400/web

## UFW (Ubunut Firewall) - Optional
> If you want to restrict your server to certain TVs/Devices on your local network
> (this assumes you do NOT want to allow remote access as well)

nano /var/lib/plexmediaserver/Library/Application\ Support/Plex\ Media\ Server/Preferences.xml  
add: `allowedNetworks="SUBNET/24"` (eg `<Preferences allowedNetworks="172.24.0.0/24" OldestPreviousVersion=...`  
set: `AcceptedEULA` = 1

> Note: You may be able to bypass the above manual config depending on the version of plex
> You can try to go to the web url of the server then click "what's this?" at the bottom.

apt install ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow from [LOCAL_IP]
ufw enable
ufw status
