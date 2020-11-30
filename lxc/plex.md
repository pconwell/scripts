> create privilged container
> enable nfs in options

```
ln -fs /usr/share/zoneinfo/America/Chicago /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata
apt update && apt upgrade -y && apt autoremove -y
apt install curl gnupg2 nfs-common beignet-opencl-icd ocl-icd-libopencl1

echo deb https://downloads.plex.tv/repo/deb public main | tee /etc/apt/sources.list.d/plexmediaserver.list
curl https://downloads.plex.tv/plex-keys/PlexSign.key | apt-key add -
apt install plexmediaserver

mkdir /mnt/unraid
mount -t nfs 192.168.1.243:/mnt/user/temp_share /mnt/unraid
dpkg -i plexmediaserver_1.21.0.3616-d87012962_amd64.deb
```
