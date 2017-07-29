# morty

- [x] Install RAM
- [ ] Install HDD
- [ ] Update BIOS
- [ ] Update PERC 6/i
- [ ] Set up RAID Arrays
- [ ] Install Ubuntu
- [ ] Set Up Samba
- [ ] Set up Plex (Docker)
- [ ] SMART HDD Monitor


# rick

- [x] Install Ubuntu
- [x] Set Up Samba
- [ ] ~~Automount external USB drive~~
- [x] Set up Plex (Docker)
- [ ] Crashplan (Docker)
- [x] Dropbox Headless
- [x] SMART HDD Monitor


## Ubuntu
> Base Operating System

1. Download Ubuntu server
2. Burn iso to disk
3. Install distro


## Samba
> Shared drives

1. Make sure samba is installed if you did not install it during [[Install Ubuntu]]
2. Identify directories that you want to share
3. Assuming samba is sharing with trusted users, add the following to the bottom of `/etc/samba/smb.conf`:

| [plex]           | [backups]        | [shared]         | [dropbox]         | [pictures]       |
| ---------------- |------------------| ---------------- | ----------------- | -----------------|
| browseable = yes | browseable = yes | browseable = yes | browseable = yes  | browseable = yes |
| path = /videos/  | path = /backups/ | path = /shared/  | path = /dropbox/  | path = /pictures |
| guest ok = yes
| force user = pconwell
| force group = pconwell
| read only = no
| create mask = 664
| force create mode = 644
| directory mask = 755
| force directory mode = 755

4. Restart Samba: `sudo service smbd restart`

## Automount external USB drive

> Will probably scratch this plan and repurpose external HDD as MD0 (RAID 1). The below steps are to MANUALLY mount usb (`/dev/sdc1`)

1. `$ sudo mkdir /media/usbdrive`
2. Add `/media/usbdrive` to `smb.conf`
3. `$ sudo mount -t ntfs /dev/sdc1 /media/usbdrive`
4. `$ sudo service smbd restart`

Only the last two steps need to be repeated during reboots.

## Docker
> Container Manager

1. Install Docker `$ wget -qO- https://get.docker.com/ | sh`
2. Add user to docker group `$ sudo usermod -aG docker pconwell`
3. Logout and back in
4. Test docker instasll `$ docker run hello-world`

To remove a docker container: `docker rm --force [name]`
To shell into container: `docker exec -it [name] bash`

### Plex (Docker)
> Media Server

Before we begin, we will need a ['plex claim' token](https://plex.tv/claim). The token is only good for 5 minutes, so if the install process takes too long, generate a new token.

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

Also, make sure you are paying attention to `-v /videos/:/data` because this is where the media will be 'mounted' when you look for it inside the plex container (e.g. when we look at the web interface to add media folders). So, if your media physically resides at `/videos/`, you will find it at `/data/` when you look in the plex web interface.

To restart, stop, start: `$ docker start|stop|restart plex`

### Crashplan (Docker)
> Remote Backups

Crashplan works in two parts: the frontend (GUI) and backend (server). The frontend will be installed on a local machine and the backend will be intsalled on a headless server.

#### Backend

1. Install Crashplan Docker:

```
docker run -d \
  --name crashplan \
  -h $HOSTNAME \
  -e TZ="${TZ:-$(cat /etc/timezone 2>/dev/null)}" \
  --publish 4242:4242 --publish 4243:4243 \
  --volume /backups:/backups \
  --volume /videos:/videos \
  --volume /pictures:/pictures \
  --volume /dropbox:/dropbox \
  --volume /shared:/shared \
  jrcs/crashplan:latest
  ```
2. Modify my.services.xml with the CONTAINER'S IP address:
```
$ docker exec -it crashplan bash
# cd /var/crashplan/conf/
# vi my.services.xml

change <location> to 172.17.0.6:4242
change <service host> to 172.17.0.6

[esc]:wq
```
3. Modify ui.properties with the CONTAINER'S IP address:
```
$ docker exec -it crashplan bash
# cd /var/crashplan/conf/
# vi ui.properties

change #serviceHost to 172.17.0.6

[esc]:wq
```  
4. Restart `docker restart crashplan`. Wait a couple minutes for the container to boot up
  
. Check .ui_info
```
$ docker exec -it crashplan bash
# cd /var/crashplan/id/.ui_info
```
It should look something like `4243,1234567890abcdef,172.17.0.6`. Note the IP address at the end of the string.

#### Frontend

1. If you have a current install, back up your `.ui_info` file. It can be found at `C:\ProgramData\CrashPlan\.ui_info`
2. Find the backend's `.ui_info` above.
3. Copy the backend's `.ui_info` file to `C:\ProgramData\CrashPlan\.ui_info`. If your computer is being difficult, edit the file on your desktop then copy it to `C:\ProgramData\CrashPlan\.ui_info` using admin
4. Change the IP address to the HOST'S IP address:
```
4243,1234567890abcdef,172.17.0.6
```

The two .ui_info files should be identical EXCEPT the one inside the container has the CONTAINER'S IP address while the one on the remote machine has the HOST'S IP address.

### Dropbox Headless (Docker)
> Cloud Storage

1. `$ sudo mkdir /dropbox && sudo chown -R pconwell:pconwell /dropbox`
2. Install Dropbox
```
docker run -d --restart=always --name=dropbox \
-v /dropbox:/dbox/Dropbox \
-e DBOX_UID=1000 \
-e DBOX_GID=1000 \
janeczku/dropbox
```
3. Once you create the container, it will download and install Dropbox automatically in the background. This can take a few minutes. Once it's installed, check the logs to find login URL: `$ docker logs dropbox`. There is no message when Dropbox has finished installing, so you will just need to keep checking the logs every 30 seconds or so until you see the URL.

> This computer isn't linked to any Dropbox account...
>
> Please visit https://www.dropbox.com/cli_link_nonce?nonce=ffdb0e2dfb2e8838b627b5234b805f5e to link this device.

Follow the provided URL to link your account. Once it is sucessfully linked, you should see `This computer is now linked to Dropbox. Welcome <your name>`.

4. Navigate to your dropbox folder `$ cd /dropbox` and make sure your existing dropbox files are showing up.

### Muximux Dashboard (Docker)
> Server Dashboard

This doesn't seem to actually do much. Probably more useful if I used more of the services it attaches to. Might play with it later and see if I can add value.

1. `$ mkdir -p ~/.muximux/config`
2. Insatll the Muximux container:
```
docker run \
 --name=muximux \
 --restart=always \
 -v ~/.muximux/config:/config \
 -e PGID=1000 -e PUID=1000 \
 -p 80:80 \
 -p 443:443 \
linuxserver/muximux
```
3. Open IP of server in browser

### Glances (Docker)
> Server Monitor

1. `$ docker pull nicolargo/glances`
2. Webservices mode: `docker run -d --restart="always" -p 61208-61209:61208-61209 -e GLANCES_OPT="-w" -v /var/run/docker.sock:/var/run/docker.sock:ro --pid host docker.io/nicolargo/glances`
3. http://192.168.1.11:61208

## SMART HDD Monitor
> HDD Monitor

1. `$ sudo apt-get install smartmontools`
2. Check for SMART capability `$ sudo smartctl -i /dev/sda`

Replace `sda` for each HDD you want to check. Generally, your first HDD will be `sda`, the second will be `sdb` and so on. If the HDD supports SMART you will see `SMART support is: Available - device has SMART capability` and `SMART support is: Enabled`. If SMART is not enabled but is available, you can enable it with `sudo smartctl -s on /dev/sda`.

3. Get a time estimate for the various types of SMART tests `$ sudo smartctl -c /dev/sda`

Expect the `short` test to be quick (1 - 2 minutes) and the `extended` test to take a WHILE (up to 6+ hours depending on disk size). Obviously don't run the extended test if you are expecting to access the disk during the test.

4. For detailed info about drive `$ sudo smartctl -a -d ata /dev/sda`
5. To conduct test `$ sudo smartctl -t short|long|cnveyance /dev/sda`
6. To view test progress `$ sudo smartctl -l selftest /dev/sda`

### SMART send email

1.
