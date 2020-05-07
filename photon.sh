# install nano
tdnf update
tdnf install nano

# enable ssh root login
nano /etc/ssh/sshd_config
# enable root login here
systemctl restart sshd

# open up some ports we will need later
# primarily for plex and pihole
iptables --list
iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
iptables -A INPUT -p tcp --dport 32400 -j ACCEPT
iptables -A INPUT -p tcp --dport 3005 -j ACCEPT
iptables -A INPUT -p udp --dport 5353 -j ACCEPT
iptables -A INPUT -p tcp --dport 8324 -j ACCEPT
iptables -A INPUT -p tcp --dport 32410 -j ACCEPT
iptables -A INPUT -p tcp --dport 32412 -j ACCEPT
iptables -A INPUT -p tcp --dport 32413 -j ACCEPT
iptables -A INPUT -p tcp --dport 32414 -j ACCEPT
iptables -A INPUT -p udp --dport 1900 -j ACCEPT
iptables -A INPUT -p tcp --dport 32469 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --dport 67 -j ACCEPT
iptables -A INPUT -p tcp --dport 4711 -j ACCEPT
iptables -A INPUT -p tcp --dport 4712 -j ACCEPT
iptables -A INPUT -p tcp --dport 4713 -j ACCEPT
iptables -A INPUT -p tcp --dport 4714 -j ACCEPT
iptables -A INPUT -p tcp --dport 4715 -j ACCEPT
iptables -A INPUT -p tcp --dport 4716 -j ACCEPT
iptables -A INPUT -p tcp --dport 4717 -j ACCEPT
iptables -A INPUT -p tcp --dport 4718 -j ACCEPT
iptables -A INPUT -p tcp --dport 4719 -j ACCEPT
iptables -A INPUT -p tcp --dport 4720 -j ACCEPT
iptables-save
iptables-save > /etc/systemd/scripts/ip4save
# test if iptables saved correctly
#shutdown now -r
#iptables --list

# set iwatch number to higher value (for crashplan)
cat /proc/sys/fs/inotify/max_user_watches
nano /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
cat /proc/sys/fs/inotify/max_user_watches

# set up shared drives
tdnf install cifs-utils
mkdir /backups
mkdir /shared
mkdir /dropbox
mkdir /photos
mkdir /movies
mkdir /shows
nano /etc/fstab
# copy fstab file here
mount -a

# enable docker
systemctl start docker
systemctl enable docker

# create portainer
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer

# set timezone
timedatectl set-timezone US/Central
timedatectl set-ntp true
systemctl daemon-reload
date

# set up tailscale
nano /etc/yum.repos.d/tailscale.repo
# copy tailscale.repo file
tdnf update
tdnf install tailscale
systemctl enable --now tailscaled
tailscale up
