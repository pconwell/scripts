# morty

- [ ] Install RAM
- [ ] Install HDD
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
- [ ] Dropbox Headless
- [x] SMART HDD Monitor


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

[USB]
browseable = yes
path = /media/usbdrive
guest ok = yes
force user = pconwell
force group = pconwell
read only = no
create mask = 664
force create mode = 644
directory mask = 755
force directory mode = 755

[backups]
browseable = yes
path = /backups/
guest ok = yes
force user = pconwell
force group = pconwell
read only = no
create mask = 664
force create mode = 644
directory mask = 755
force directory mode = 755

[shared]
browseable = yes
path = /shared/
guest ok = yes
force user = pconwell
force group = pconwell
read only = no
create mask = 664
force create mode = 644
directory mask = 755
force directory mode = 755

[dropbox]
browseable = yes
path = /dropbox/
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

> Will probably scratch this plan and repurpose external HDD as MD0 (RAID 1). The below steps are to MANUALLY mount usb (`/dev/sdc1`)

1. `$ sudo mkdir /media/usbdrive`
2. Add `/media/usbdrive` to `smb.conf`
3. `$ sudo mount -t ntfs /dev/sdc1 /media/usbdrive`
4. `$ sudo service smbd restart`

Only the last two steps need to be repeated during reboots.

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

Also, make sure you are paying attention to `-v /videos/:/data` because this is where the media will be 'mounted' when you look for it inside the plex container (e.g. when we look at the web interface to add media folders). So, if your media physically resides at `/videos/`, you will find it at `/data/` when you look in the plex web interface.

To restart, stop, start: `$ docker start|stop|restart plex`

## Crashplan (Docker)

Crashplan works in two parts: the frontend (GUI) and backend (server). The frontend will be installed on a local machine and the backend will be intsalled on a headless server.

### Backend

1. Install Crashplan Docker:

```
docker run -d \
  --name crashplan \
  -h $HOSTNAME \
  -e TZ="${TZ:-$(cat /etc/timezone 2>/dev/null)}" \
  --publish 4242:4242 --publish 4243:4243 \
  --volume /srv/crashplan/data:/var/crashplan \
  --volume /srv/crashplan/storage/backups:/backups \
  --volume /srv/crashplan/storage/videos:/videos \
  --volume /srv/crashplan/storage/pictures:/pictures \
  --volume /srv/crashplan/storage/dropbox:/dropbox \
  --volume /srv/crashplan/storage/shared:/shared \
  jrcs/crashplan:latest
  ```

### Frontend

1. If you have a current install, back up your `.ui_info` file. It can be found at `C:\ProgramData\CrashPlan\.ui_info`
2. Find the backend's `.ui_info` at `/var/crashplan/data/id/.ui_info`
3. Copy the backend's `.ui_info` file to `C:\ProgramData\CrashPlan\.ui_info`
4. The two files should match (the headless server's `.ui_info` and the local machine's `.ui_info` should be exactly the same)

## SMART HDD Monitor

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

## Dropbox Headless (Docker)

1. `$ sudo mkdir /dropbox && sudo chown -R pconwell:pconwell /dropbox`
2. Install Dropbox
```
docker run -d --restart=always --name=dropbox \
-v /dropbox:/dbox/Dropbox \
-e DBOX_UID=1000 \
-e DBOX_GID=1000 \
janeczku/dropbox
```
3. Check logs to find login URL `$ docker logs dropbox`. It may take a while for dropbox to start. Eventually you will see something in the logs like

> This computer isn't linked to any Dropbox account...

> Please visit https://www.dropbox.com/cli_link_nonce?nonce=ffdb0e2dfb2e8838b627b5234b805f5e to link this device.

Follow the provided URL to link your account. Once it is sucessfully linked, you should see `This computer is now linked to Dropbox. Welcome <your name>`.

4. Navigate to your dropbox folder `$ cd /dropbox` and make sure your existing dropbox files are showing up.
