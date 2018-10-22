> This page needs to be updated. It is *generally* up-to-date but needs to be cleaned up and re-written/updated.

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

> See https://github.com/pconwell/scripts/blob/master/docker.md for up-to-date instructions

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

