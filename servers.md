## morty 3.0 (ESXi 6.5)

### Install ESXi
> First, you need to navigate the needlessly complex website for vmware. Most likely, you will want this: https://www.vmware.com/go/get-free-esxi which is the free version of ESXi. Getting the download to work can be a major pain in the ass and I have so far been unsucessful in downloading the iso.

1. install internal SD Card, min 16 GB.
2. burn image to disk (haven't had luck with bootable USBs lately...)
3. boot to disk. It's slow so be prepared to wait a good 10 minutes or more while it boots to the disk.
4. follow on screen instructions. It's pretty straight forward. Install is relatively quick. Just make sure you install to the internal SD card and not the HDD.
5. reboot. You should eventually see a screen that looks a lot like the install screen. (if not, make sure you have set USB to boot in the BIOS).
6. Once it's booted up, navigate to your server's IP address (or host name) using your browser. Username/Password is root/your_password_you_entered_during_install
7. If that is all sucessful, you have finished the ESXi install.

> Before you go further, might as well properly license your install. You just need to register for a free account using the link above and you will be give a key. Even free versions of ESXi need a key.

## Provisioning Disks
> Most likely, previous disks (if you have multiple disks) will need to be formatted for vm. Under 'Storage', click the disk (or array) you want to use. Click 'New Datastore', then give it a name. Format as appropriate.

## Install a Guest/Client
1. Click 'Virual Machines' on the left.
2. Click 'Create / Register VM' near the top.
3. Follow the screens. It will pretty much walk you through it step-by-step.
> Add a second HDD for plex. During creation, on VM settings page, click 'Add new disk', then expand the advanced settings on the new disk. Navigate to the datastorage from 'provisioning disks' above.
4. Once configured, you may need to click "refresh" to see the VM
5. Click on the VM and click 'run'.
> This is kind of the make-or-break point because it can get tricky as to what ESXi free version will let you provision for your VM. For example, you cannot have more than 8 vCPUs even though it will let you add more than 8. If you add more than 8, it will just kinda *fail* when you click run. Right now, I'm not sure what vCPUs are exactly and how they relate to physical CPUs/Cores.
6. If the VM started correctly, you should see a bunch of different settings, charts, graphs and a little image of the VM running in the upper left.
7. You will now need to add your ISO to the 'datastore'. Click storage, then datastore1 (or whatever you called yours).
8. Then 'create directory', name it ISO (or whatever you want), then click 'upload'. Upload your ISO.
9. Go back to yoru VM and 'edit settings'. Under cd/dvd, mount the iso. Reset the VM.
10. Enter into the console. The console is basically an HTML5 RDP client.
11. Install guest OS.

### Docker VM

```
$ sudo apt-get install apt-transport-https ca-certificates curl software-properties-common 
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$ sudo apt-key fingerprint 0EBFCD88
$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
$ sudo apt-get update
$ sudo apt-get install docker-ce 
$ sudo docker run hello-world

$ cat /proc/sys/fs/inotify/max_user_watches 
$ sudo nano /etc/sysctl.conf 
$ sudo sysctl -p /etc/sysctl.conf 
$ cat /proc/sys/fs/inotify/max_user_watches 

$ sudo docker run --restart=always -d --name=crashplan-pro -e TZ="${TZ:-$(cat /etc/timezone 2>/dev/null)}" -p 5800:5800 -v /docker/appdata/crashplan-pro:/config -v /backups:/backups -v /movies:/videos -v /shows:/shows -v /photos:/pictures -v /dropbox:/dropbox -v /shared:/shared jlesage/crashplan-pro

$ sudo nano /etc/fstab 
$ sudo mount -a

$ sudo groupadd docker
$ sudo usermod -aG docker pconwell
$ exit
$ groups
$ docker run hello-world
$ sudo shutdown now -r
```
#### Crashplan

```
sudo docker run --restart=always -d --name=crashplan-pro -e TZ="${TZ:-$(cat /etc/timezone 2>/dev/null)}" -p 5800:5800 -v /docker/appdata/crashplan-pro:/config -v /backups:/backups -v /movies:/videos -v /shows:/shows -v /photos:/pictures -v /dropbox:/dropbox -v /shared:/shared jlesage/crashplan-pro
```
#### Plex
> You will need to replace the claim code with your own claim code. https://www.plex.tv/claim/

```
docker run -d --name plex --network=host -e TZ="${TZ:-$(cat /etc/timezone 2>/dev/null)}" -e PLEX_CLAIM="CLAIM-..." -v ~/.plex/config:/config -v ~/.plex/transcode:/transcode -v /movies:/movies -v /shows:/shows plexinc/pms-docker:public
```

#### RStudio
> To access outside network, set up port fowarding to port 8787

```
docker run -d -p 8787:8787 rocker/rstudio
```

#### Dokuwiki

```
docker run -d -p 8888:80 --name dokuwiki pconwell/dokuwiki
```

#### Dropbox
> You will need to go into `$ docker logs dropbox` to set up and link your account.

```
docker run -d --restart=always --name=dropbox -v /dropbox/:/dbox/Dropbox -e DBOX_UID=1000 -e DBOX_GID=1000 janeczku/dropbox
```

#### Handbrake

```
docker run -d --rm --name=handbrake_movies -p 5880:5800 -p 5900:5900 -v /docker/appdata/handbrake_movies:/config:rw -v $HOME:/storage:ro -v /movies/to_convert:/watch:rw -v /movies/movies_rips:/output:rw jlesage/handbrake
```

### Files VM

#### Samba

```
[movies]
browseable = yes
path = /movies/
guest ok = yes
force user = pconwell
force group = pconwell
read only = no
create mask = 664
force create mode = 644
directory mask = 755
force directory mode = 755

[shows]
browseable = yes
path = /shows/
guest ok = yes
force user = pconwell
force group = pconwell
read only = no
create mask = 664
force create mode = 644
directory mask = 755
force directory mode = 755

[photos]
browseable = yes
path = /photos/
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

```
$ sudo chown pconwell:pconwell /movies/
$ sudo chown pconwell:pconwell /shows/
$ sudo chown pconwell:pconwell /backups/
$ sudo chown pconwell:pconwell /shared/
$ sudo chown pconwell:pconwell /dropbox/
```

`$ sudo service smbd restart`

### Windows VM
> Nothing special

