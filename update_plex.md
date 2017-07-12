## Updated headless plex on ubuntu

### SSH into server

$ ssh mediaserver

### Download updated deb

$ wget https://downloads.plex.tv/plex-media-server/1.7.5.4035-313f93718/plexmediaserver_1.7.5.4035-313f93718_i386.deb

replace `plexmediaserver_1.7.5.4035-313f93718_i386.deb` with the current release

### Install package

$ sudo dpkg -i plexmediaserver_1.7.5.4035-313f93718_i386.deb

### Open web portal in browser

http://192.168.1.11:32400/web/index.html
