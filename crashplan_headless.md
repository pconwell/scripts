# Headless CrashPlan with remote GUI

## Install Crashplan on remote (headless) server

1. Download [crashplan for linux](https://www.crashplan.com/en-us/thankyou/?os=linux)
2. `$ tar -xvzf ./crashplan.tgz`
3. `$ cd ./crashplan-install`
4. `$ sudo ./install.sh`

## Install Crashplan on local computer

1. Download [crashplan](https://www.crashplan.com/en-us/download/)
2. Install crashplan

## Point GUI on local machine to headless machine

(Clean up this section...)

The problem with the instructions in the link above is that the service is listening for a connection on the local loopback (127.0.0.1). What we need to have happen is we want the service to listen on the local LAN address. For me, the server's local LAN address is 192.168.1.11. So I want the service to listen on 192.168.1.11 on port 4243. To do this, you need to edit two files: my.service.xml and ui.properties and change the localhost and/or 127.0.0.1 address to 192.168.1.11. After restarting the crashplan service, you will need to check your ui_info file to make sure the key didn't change. The ui_info file on both the local machine and the server should be EXACTLY the same. For me, it was:

     4243,XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX,192.168.1.11

After that, everything should work perfectly without having to set up an ssh tunnel! Just start the gui on your local machine like normally and it will connect to the service!
