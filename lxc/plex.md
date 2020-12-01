
## plex

> create privilged container
> enable nfs in options

```
ln -fs /usr/share/zoneinfo/America/Chicago /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata

echo deb https://downloads.plex.tv/repo/deb public main | tee /etc/apt/sources.list.d/plexmediaserver.list
curl https://downloads.plex.tv/plex-keys/PlexSign.key | apt-key add -

apt update && apt upgrade -y && apt autoremove -y
apt install curl gnupg2 nfs-common beignet-opencl-icd ocl-icd-libopencl1 plexmediaserver

mkdir /mnt/unraid
mount -t nfs 192.168.1.243:/mnt/user/temp_share /mnt/unraid
```

## tautulli

```
apt install python3-setuptools unzip
cd /opt
wget https://github.com/Tautulli/Tautulli/archive/master.zip
unzip master.zip
mv Tautulli-master/ Tautulli/
cp /opt/Tautulli/init-scripts/init.systemd /lib/systemd/system/tautulli.service
nano /lib/systemd/system/tautulli.service
    Change User & group to root
systemctl daemon-reload && systemctl enable tautulli.service
systemctl start tautulli.service
```
