> Debian 10 VM (will not work with LXC)

```
$ sudo apt update && sudo apt upgrade -y
$ wget https://download.onlyoffice.com/install/workspace-install.sh
$ sudo echo 'GRUB_CMDLINE_LINUX_DEFAULT="vsyscall=emulate"' >> /etc/default/grub
$ chmod +x ./workspace-install.sh
$ sudo ./workplace-install.sh
```

Proceed to IP address in browser.
