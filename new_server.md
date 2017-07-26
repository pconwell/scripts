# Setting up a new headless Ubuntu server

## Install Ubuntu

1. Download Ubuntu server
2. Burn iso to disk
3. Install distro

## Set up Samba

1. Make sure samba is installed if you did not install it during [[Install Ubuntu]]
2. Identify directories that you want to share
3. Assuming samba is sharing with trusted users, add the following to the bottom of `/etc/samba/smb.conf`:

```
[plex]
browseable = yes
path = /videos/
guest ok = yes
force user = pconwell
force group = pconwell
read only = no
create mask = 664
force create mode = 644
directory mask = 755
force directory mode = 755
```
4. Restart Samba: `sudo service smbd restart`

## Automount external USB drive

1. 

## Set up Plex (Docker)

1. Install Docker `$ wget -qO- https://get.docker.com/ | sh`
2. Add user to docker group `$ sudo usermod -aG docker pconwell`
3. Logout and back in
4. Test docker instasll `$ docker run hello-world`

If everything looks good, now we can install the PMS Container. But first, we will need a ['plex claim' token](https://plex.tv/claim). Next: 
1. `$ sudo docker pull plexinc/pms-docker`
2. (Optional) Make a directory for plex config files `$ mkdir ~/.plex`, `$ mkdir ~/.plex/config`, `$ mkdir ~/.plex/transcode`
3. Run the new container:

```
$ sudo docker run \
-d \
--name plex \
-p 32400:32400/tcp \
-p 3005:3005/tcp \
-p 8324:8324/tcp \
-p 32469:32469/tcp \
-p 1900:1900/udp \
-p 32410:32410/udp \
-p 32412:32412/udp \
-p 32413:32413/udp \
-p 32414:32414/udp \
-e TZ="America/Chicago" \
-e PLEX_CLAIM="claim-6dHzapBDb5mtUEpeF5iU" \
-e ADVERTISE_IP="http://192.168.1.11:32400/" \
-h "rick" \
-v ~/.plex/config/:/config \
-v ~/.plex/transcode/:/transcode \
-v /videos/:/data \
plexinc/pms-docker
```

There are a few important things to note. First, you will need to change your `PLEX_CLAIM` because each token is only good for 5 minutes. Second, make sure the IP is the *host* computers IP address and -h is the hostname.

Also, make sure you are paying attention to `-v /videos/:/data` because this is where the media will be 'mounted' when you look for it in the plex web interface. So, if your media physically resides at `/videos/`, you will find it at `/data/` when you look in the plex web interface.

To restart, stop, start: `$ docker start|stop|restart plex`
