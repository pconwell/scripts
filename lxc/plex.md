> create privilged container
> enable nfs in options

ln -fs /usr/share/zoneinfo/America/Chicago /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata
apt update && apt upgrade -y && apt autoremove -y
apt install nfs-common beignet-opencl-icd ocl-icd-libopencl1
wget https://downloads.plex.tv/plex-media-server-new/1.21.0.3616-d87012962/debian/plexmediaserver_1.21.0.3616-d87012962_amd64.deb
mkdir /mnt/unraid
mount -t nfs 192.168.1.243:/mnt/user/temp_share /mnt/unraid
dpkg -i plexmediaserver_1.21.0.3616-d87012962_amd64.deb
