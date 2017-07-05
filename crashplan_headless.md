You guys might already know this, but I wanted to share what I found. I've been trying to back up a headless server on my local network to crashplan central. As I'm sure you are aware, crashplan was not designed to run headless as the app has two parts: a 'gui' front end and the 'service' back end. The 'service' is what does all the actual work, the 'gui' is just how you make changes to settings, check status etc. It should be obvious that a headless server cannot run a gui. So you have to hack the app to run the gui on a local machine and connect to the service on the headless machine.

Getting crashplan up and running on the headless ubuntu server was mostly painless [following these instructions](https://support.code42.com/CrashPlan/4/Configuring/Using_CrashPlan_On_A_Headless_Computer). However, I did not want to have to set up an ssh tunnel every time I wanted to manage the backups. With a lot of help from /u/Atr3id3s, I was able to get the gui to connect to the service without having to use any tunnels, ssh, telnet, etc.

The process is pretty simple, but it is not documented at all anywhere. As far as I know, this is the first time this has been documented (at least according to my google searches).

The problem with the instructions in the link above is that the service is listening for a connection on the local loopback (127.0.0.1). What we need to have happen is we want the service to listen on the local LAN address. For me, the server's local LAN address is 192.168.1.11. So I want the service to listen on 192.168.1.11 on port 4243. To do this, you need to edit two files: my.service.xml and ui.properties and change the localhost and/or 127.0.0.1 address to 192.168.1.11. After restarting the crashplan service, you will need to check your ui_info file to make sure the key didn't change. The ui_info file on both the local machine and the server should be EXACTLY the same. For me, it was:

     4243,XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX,192.168.1.11

After that, everything should work perfectly without having to set up an ssh tunnel! Just start the gui on your local machine like normally and it will connect to the service!

