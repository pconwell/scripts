# morty 2.0 (ESXi / vSphere)
> First, you need to navigate the needlessly complex website for vmware. Most likely, you will want this: https://www.vmware.com/go/get-free-esxi which is the free version of ESXi. Getting the download to work can be a major pain in the ass and I have so far been unsucessful in downloading the iso.


# morty (poweredge r710)

## Quick Stats

* Processor: Dual Xeon ...
* RAM: 32 GB (8 x 4 GB)
* HDD: 136 GB & 3636 GB

- [x] Install RAM
- [x] Install HDD
- [ ] ~~~Update Firmware(s)~~~
- [x] Set up RAID Arrays
- [ ] Install Ubuntu
- [ ] Dell OpenManage
- [ ] Set Up Samba
- [ ] Set up Plex Repo
- [ ] SMART HDD Monitor (?)

## Install RAM
> 32 GB (8 x 4 GB). 16 GB for each processor.

## Install HDD
> Two RAID arrays. One for the OS and one for /plex videos

* SAS
  - PD 00: HP EH0146FBQDC (146 GB)
  - PD 04: HP EH0146FBQDC (146 GB)
* SATA
  - PD 01: HGST HTS721010A9 (1 TB)
  - PD 02: HGST HTS721010A9 (1 TB)
  - PD 03: HGST HTS721010A9 (1 TB)
  - PD 05: HGST HTS721010A9 (1 TB)
  - PD 06: HGST HTS721010A9 (1 TB)
  - PD 07: HGST HTS721010A9 (1 TB)
    
## Update firmware
> I can't get the firmware to update. The bootable USB wouldn't work at all (it would boot but then "couldn't find the .bin files"). Burnt a disk and it *acted* like it would work but then kept saying there wasn't enough memory. The firmware is all mostly up-to-date as is, and the changelogs don't show anything that should hender my needs. So, I'll just skip this for now.

1. ~~~Download [R710 firmware ISO](https://dell.app.box.com/v/BootableR710)~~~
2. ~~~Make bootable USB with [Rufus](https://rufus.akeo.ie/)~~~
3. ~~~Boot to USB (F11 to get to the boot selection screen)~~~

## Set up RAID Arrays
> This can take a while.

1. Boot into RAID Controller (ctrl + R during boot)
2. Set up RAID as desired. Make sure RAID is set to force write back (not write through). Write through is 'safer', but much slower.
  - VD0 --> RAID 1 136.125 GB
  - VD1 --> RAID 6 3.636 TB
3. Initalize both RAIDs and wait for background initialization to complete. This will take about 3 hours.

> You can probably start using the array before the background init is complete, but it doesn't take too long and there is some information that suggets that trying to use more space on the array that the percentage of background init completed will cause issues. Better safe than sorry.

## Ubuntu
> Base Operating System

1. Download Ubuntu server
2. Burn iso to disk
3. Install distro

* VD0 --> sda
  - sda1 --> /boot
  - sda2 --> /
  - sda3 --> swap
* VD1 --> sdb
  - sdb1 --> /plex
  
`sudo apt-get update && sudo apt-get upgrade -y`

## Dell OpenManage
> http://linux.dell.com/repo/community/ubuntu/

1. `$ sudo echo 'deb http://linux.dell.com/repo/community/ubuntu xenial openmanage' | sudo tee -a /etc/apt/sources.list.d/linux.dell.com.sources.list`
2. `$ sudo gpg --keyserver pool.sks-keyservers.net --recv-key 1285491434D8786F`
3. `$ sudo gpg -a --export 1285491434D8786F | sudo apt-key add -`
4. `$ sudo apt-get update`

5. `$ $ sudo apt-get install srvadmin-storageservices srvadmin-webserver`
6. `$ sudo update-rc.d dsm_om_connsvc defaults`

7. https://192.168.1.12:1311

  
## Samba
> Shared drives

1. Make sure samba is installed if you did not install it during [[Install Ubuntu]]
2. Identify directories that you want to share
3. Assuming samba is sharing with trusted users, add the following to the bottom of `/etc/samba/smb.conf`:

| [plex]           |
| ---------------- |
| browseable = yes 
| path = /plex/  
| guest ok = yes
| force user = pconwell
| force group = pconwell
| read only = no
| create mask = 664
| force create mode = 644
| directory mask = 755
| force directory mode = 755

5. `$ sudo chown pconwell:pconwell /videos`
4. Restart Samba: `sudo service smbd restart`

6. `$ scp pconwell@rick:/videos/.../files.mkv /videos/.../`

> `$ scp remote_username@remote_host:file /local/directory/`

## Plex Repo
> https://support.plex.tv/hc/en-us/articles/235974187-Enable-repository-updating-for-supported-Linux-server-distributions

## Virtualbox Headless
> For windows 10 install. Make sure virtualization is enabled in the bios on the server before starting.

1. `$ sudo apt-get install virtualbox virtualbox-ext-pack virtualbox-guest-additions-iso`
2. Download latest windows 10 iso (64 bit) to /home
3. `$ VBoxManage createvm --name "windows" -ostype Windows10_64 --register`
4. `$ VBoxManage modifyvm "windows" --memory 8192 --vram 256 --cpus 4 --acpi on --boot1 dvd --nic1 nat`
5. `$ VBoxManage createhd --filename "win10.vdi" --size 50000`
6. `$ VBoxManage storagectl "windows" --name "IDE Controller" --add ide --controller PIIX4`
7. `$ VBoxManage storageattach "windows" --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium "win10.vdi"`
8. `$ VBoxManage storageattach "windows" --storagectl "IDE Controller" --port 0 --device 1 --type dvddrive --medium ~/Win10_1703_English_x64.iso`
> replace Win10_1703_English_x64.iso with name of current windows 10 iso
9. `$ VBoxManage modifyvm "windows" --vrde on`
10. `$ VBoxHeadless --startvm "windows"`

Once you start the vm, you will need to connect via RDP and the *host's* IP address. Once you have connected via RDP and installed your guest OS, and everything is up and running, you will need to install the guest additions.

1. Shut down your guest OS
2. `$ wget http://download.virtualbox.org/virtualbox/5.0.40/VBoxGuestAdditions_5.0.40.iso`
> Check your version of virtualbox and download the correct version
3. `$ VBoxManage storageattach "windows" --storagectl "IDE Controller" --port 0 --device 1 --type dvddrive --medium ~/VBoxGuestAdditions_5.0.40.iso`
4. Restart the guest and using the guest's file explorer, open the attached 'CD' and install the guest additions.
5. `$  VBoxManage storageattach "windows" --storagectl "IDE Controller" --port 0 --device 1 --medium none`
> Shut down the guest again and detatch the iso
6. Restart the guest OS and everything should be good.

Once everything is good to go and you are happy, run the VM as a background, detached process:

`$ VBoxManage startvm "windows" --type headless`


# rick (poweredge 850)

- [x] Install Ubuntu
- [x] Set Up Samba
- [x] Set up Plex (Docker)
- [ ] Crashplan (Docker)
- [x] Dropbox Headless
- [x] SMART HDD Monitor


## Ubuntu
> Base Operating System

1. Download Ubuntu server
2. Burn iso to disk
3. Install distro
  - Software RAID 1 (1.5 TB)
    - `/backups`
    - `/shared`
    - `/dropbox`
    - `/pictures`


## Samba
> Shared drives

1. Make sure samba is installed if you did not install it during [[Install Ubuntu]]
2. Identify directories that you want to share
3. Assuming samba is sharing with trusted users, add the following to the bottom of `/etc/samba/smb.conf`:

| [backups]        | [shared]         | [dropbox]         | [pictures]       |
|------------------| ---------------- | ----------------- | -----------------|
| browseable = yes | browseable = yes | browseable = yes  | browseable = yes |
| path = /backups/ | path = /shared/  | path = /dropbox/  | path = /pictures |
| guest ok = yes
| force user = pconwell
| force group = pconwell
| read only = no
| create mask = 664
| force create mode = 644
| directory mask = 755
| force directory mode = 755

4. `$ sudo chown pconwell:pconwell /backups`
  - Repeat for `shared`, `dropbox`, and `pictures`

5. Restart Samba: `sudo service smbd restart`

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

Before setting up crashplan, make sure to mount the network drive for plex (plex share on morty)

1. `$ sudo nano /etc/samba/user`
2. add the following to lines to the above file
```
username=samba_user
password=samba_user_password
```
3. `$ sudo mkdir /plex_mount`
4. `$ sudo chown pconwell:pconwell /plex_mount`
4. `$ sudo nano /etc/fstab`
5. add `//192.168.1.12/plex /plex_mount cifs credentials=/etc/samba/user,noexec 0 0`
> `192.168.1.12` is the IP address to morty
6. `$  sudo mount /plex_mount/`

#### Backend

1. Install Crashplan Docker:

```
sudo docker run --restart=always -d \
  --name crashplan \
  -h $HOSTNAME \
  -e TZ="${TZ:-$(cat /etc/timezone 2>/dev/null)}" \
  --publish 4242:4242 --publish 4243:4243 \
  --volume /backup:/backups \
  --volume /plex_mount:/videos \
  --volume /pictures:/pictures \
  --volume /dropbox:/dropbox \
  --volume /share:/shared \
  jrcs/crashplan:latest
  ```
2. Copy .ui_info from the crashplan container:
```
$ docker exec -it crashplan bash
# cat /var/crashplan/id/.ui_info
4243,5f2abe42-313c-48ff-8e58-80bd2073484e,0.0.0.0
```
Make a note of the `.ui_info` file.

#### Frontend

1. If you have a current install, back up your `.ui_info` file. It can be found at `C:\ProgramData\CrashPlan\.ui_info`
2. Find the backend's `.ui_info` above.
3. Copy the backend's `.ui_info` file to `C:\ProgramData\CrashPlan\.ui_info`. If your computer is being difficult, edit the file on your desktop then copy it to `C:\ProgramData\CrashPlan\.ui_info` using admin
4. Change the IP address to the HOST'S IP address:
```
4243,5f2abe42-313c-48ff-8e58-80bd2073484e,192.168.1.11
```

> The two .ui_info files should be identical EXCEPT for the IP addresses

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
