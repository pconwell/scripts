## Unifi

```
docker run -d --name=unifi --restart=always -v /home/pconwell/.unifi/:/config/ -e PGID=1000 -e PUID=1000 -p 3478:3478/udp -p 10001:10001/udp -p 8080:8080 -p 8081:8081 -p 8443:8443 -p 8843:8843 -p 8880:8880 linuxserver/unifi
```

## portainer

```
docker run -d --restart=always --name=portainer -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v /opt/portainer:/data portainer/portainer
```

## crashplan


```
docker run --restart=always -d --name=crashplan -e TZ="${TZ:-$(cat /etc/timezone 2>/dev/null)}" -p 5800:5800 -v /docker/appdata/crashplan-pro:/config -v /backups:/backups -v /movies:/videos -v /shows:/shows -v /photos:/pictures -v /dropbox:/dropbox -v /shared:/shared jlesage/crashplan-pro
```

## rstudio


```
docker run -d --name=rstudio_test -p 8781:8787 -e USER=<user> -e PASSWORD=<password> pconwell/rstudio
```

## handbrake


```
docker run -d --name=handbrake -p 5880:5800 -p 5900:5900 -e AUTOMATED_CONVERSION_PRESET="H.265 MKV 720p30" -e AUTOMATED_CONVERSION_FORMAT="mkv" -v /docker/appdata/handbrake_movies:/config:rw -v $HOME:/storage:ro -v /movies:/movies -v /shows:/shows -v /movies/to_convert:/watch:rw -v /movies/movies_rips:/output:rw jlesage/handbrake
```

## plex


```
docker run -d --name plex --network=host -e TZ="${TZ:-$(cat /etc/timezone 2>/dev/null)}" -e PLEX_CLAIM="CLAIM-NZPSFP7A3KL3X8D6WGSQ" -v ~/.plex/config:/config -v ~/.plex/transcode:/transcode -v /movies:/movies -v /shows:/shows plexinc/pms-docker:public
```

## dokuwiki


```
docker run -d -p 8888:80 --name dokuwiki pconwell/dokuwiki
```

## dropbox


```
docker run --restart=always -d --name=crashplan -e TZ="${TZ:-$(cat /etc/timezone 2>/dev/null)}" -p 5800:5800 -v /docker/appdata/crashplan-pro:/config -v /backups:/backups -v /movies:/videos -v /shows:/shows -v /photos:/pictures -v /dropbox:/dropbox -v /shared:/shared jlesage/crashplan-pro
```
