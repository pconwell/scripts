Install Debian 11 LXC (privliged & options -> NFS)  
Set static IP  

```
apt update && apt upgrade -y && apt autoremove -y

wget https://acrosync.com/duplicacy-web/duplicacy_web_linux_x64_1.6.3
chmod +x /root/duplicacy_web_linux_x64_1.6.3

mkdir /root/.duplicacy-web/
nano /root/.duplicacy-web/settings.json

    {
        "listening_address": "0.0.0.0:3875"
    }

nano /etc/systemd/system/duplicacy.service

    [Unit]
    Description=Duplicacy backup
    
    Wants=network.target
    After=syslog.target network-online.target
    
    [Service]
    Type=simple
    User=root
    WorkingDirectory=/root/
    ExecStart=/root/duplicacy_web_linux_x64_1.6.3
    Restart=on-failure
    RestartSec=10
    KillMode=process
     
    [Install]
    WantedBy=multi-user.target

systemctl daemon-reload
systemctl start duplicacy.service 
systemctl status duplicacy.service
systemctl enable duplicacy.service

apt install nfs-common
mkdir /mnt/appdata
mkdir /mnt/backups
mkdir /mnt/photos
mkdir /mnt/shared

nano /etc/fstab

    # UNCONFIGURED FSTAB FOR BASE SYSTEM
    192.168.1.23:/mnt/user/backups/   /mnt/backups   nfs     defaults     0     0
    192.168.1.23:/mnt/user/proxmox/   /mnt/proxmox   nfs     defaults     0     0
    192.168.1.23:/mnt/user/photos/    /mnt/photos    nfs     defaults     0     0
    192.168.1.23:/mnt/user/shared/    /mnt/shared    nfs     defaults     0     0
```
