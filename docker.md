> Update to compose https://composerize.com/

### Install
```
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce
sudo groupadd docker
sudo usermod -aG docker $USER
```

You will need to log out after `sudo usermod -aG docker $USER` so the changes are populated.

> `apt-key fingerprint 0EBFCD88` == 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88

To start docker on host system boot: `$ sudo systemctl enable docker`

To test installation: `$ docker run hello-world`

### MakeMKV
```
docker run -d --name=makemkv --restart=always -p 5800:5800 -e USER_ID=1000 -e GROUP_ID=1000 -v /home/pconwell/.makemkv/config/:/config:rw -v /home/pconwell/movies/makemkv/storage/:/storage:ro -v /home/pconwell/movies/makemkv/output:/output:rw --device /dev/sr0 --device /dev/sg1 jlesage/makemkv
```


### unifi

```
docker run -d --name=unifi --restart=always -v ~/.unifi/:/config/ -e PGID=1000 -e PUID=1000 -p 3478:3478/udp -p 10001:10001/udp -p 8080:8080 -p 8081:8081 -p 8443:8443 -p 8843:8843 -p 8880:8880 linuxserver/unifi
```

### portainer

```
docker run -d --name=portainer --restart=always -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v /opt/portainer:/data portainer/portainer
```

### crashplan


```
docker run -d --name=crashplan --restart=always -e TZ="${TZ:-$(cat /etc/timezone 2>/dev/null)}" -p 5800:5800 -v ~/.crashplan/config:/config -v /backups:/backups -v /movies:/videos -v /shows:/shows -v /photos:/pictures -v /dropbox:/dropbox -v /shared:/shared jlesage/crashplan-pro
```

### rstudio


```
docker build --tag rstudio https://github.com/pconwell/rstudio.git#master
docker run -d --name=rstudio --restart=always -p 8781:8787 -e USER=<username> -e PASSWORD=<password> -v ~/.rstudio:/home rstudio
```

> 1. Log in to rstudio, then Tools -> Global Options -> Git/SVN -> create RSA key
> 2. View Public Key
> 3. Copy Public Key to githbub


### handbrake


```
docker run -d --name=handbrake --restart=always -p 5880:5800 -p 5900:5900 -e AUTOMATED_CONVERSION_PRESET="H.265 MKV 720p30" -e AUTOMATED_CONVERSION_FORMAT="mkv" -v ~/.handbrake/config:/config:rw -v $HOME:/storage:ro -v /movies:/movies -v /shows:/shows -v /movies/to_convert:/watch:rw -v /movies/movies_rips:/output:rw jlesage/handbrake
```

### plex


```
docker run -d --name plex --restart=always --network=host -e TZ="${TZ:-$(cat /etc/timezone 2>/dev/null)}" -e PLEX_CLAIM="CLAIM-NZPSFP7A3KL3X8D6WGSQ" -v ~/.plex/config:/config -v ~/.plex/transcode:/transcode -v /movies:/movies -v /shows:/shows plexinc/pms-docker:public
```

#### tautulli
```
docker run -d --name=tautulli --restart=always -v /home/pconwell/.plex/config:/config -v "/home/pconwell/.plex/config/Library/Application Support/Plex Media Server/Logs":/logs:ro -e PGID=1000 -e PUID=1000 -e TZ="${TZ:-$(cat /etc/timezone 2>/dev/null)}" -p 8181:8181 tautulli/tautulli
```
### dokuwiki


```
docker run -d --name=dokuwiki --restart=always -p 8888:80 --name dokuwiki pconwell/dokuwiki
```

### dropbox


```

```
