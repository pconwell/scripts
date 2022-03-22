## Portainer
> in unRAID terminal

```
# docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /mnt/user/appdata/portainer/data:/data portainer/portainer-ce:latest
```


## adguard
```
version: "2"
services:
  adguardhome:
    container_name: adguardhome
    hostname: adguard
    restart: unless-stopped
    environment:
      - TZ=America/Chicago
    ports:
      - 53:53/tcp
      - 53:53/udp
      - 784:784/udp
      - 853:853/tcp
      - 3000:3000/tcp
      - 8080:80/tcp
      - 8443:443/tcp
    logging:
      driver: gelf
      options:
        gelf-address: 'udp://192.168.10.101:12201'
    volumes:
      - /mnt/user/appdata/adguard/work:/opt/adguardhome/work
      - /mnt/user/appdata/adguard/conf:/opt/adguardhome/conf

    image: adguard/adguardhome
```


## crashplan

```
version: '2'
services:
  
  crashplan:
    container_name: crashplan
    hostname: crashplan
    restart: unless-stopped
    environment:
      - TZ=America/Chicago
    dns:
      - 192.168.1.103
    volumes:
      - /mnt/user/appdata/crashplan/config:/config
      - /mnt/user/appdata/crashplan/storage:/storage
      - /mnt/user/appdata:/mnt/appdata:ro
      - /mnt/user/backups:/mnt/backups:ro
      - /mnt/user/domains:/mnt/domains:ro
      - /mnt/user/isos:/mnt/isos:ro
      - /mnt/user/movies:/mnt/movies:ro
      - /mnt/user/photos:/mnt/photos:ro
      - /mnt/user/proxmox:/mnt/proxmox:ro
      - /mnt/user/shared:/mnt/shared:ro
      - /mnt/user/shows:/mnt/shows:ro
      - /mnt/user/system:/mnt/system:ro
      - /mnt/user/timelapse:/mnt/timelapse:ro
    ports:
      - 5800:5800
    logging:
      driver: gelf
      options:
        gelf-address: 'udp://192.168.10.101:12201'      
    image: jlesage/crashplan-pro
```


## jackett
```
version: '2'
services:

  jackett:
    container_name: jackett
    hostname: jackett
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Chicago
    ports:
      - 9117:9117
    dns:
      - 192.168.1.103
    volumes:
      - /mnt/user/appdata/jacket/config:/config
      - /mnt/user/shows/:/shows
      - /mnt/user/movies/:/movies
      - /mnt/user/shared/downloads:/downloads
    logging:
      driver: gelf
      options:
        gelf-address: 'udp://192.168.10.101:12201'
    image: linuxserver/jackett
```


## radarr
```
version: '2'
services:

  radarr:
    container_name: radarr
    hostname: radarr
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Chicago
    ports:
      - 7887:7878
    dns:
      - 192.168.1.103
    volumes:
      - /mnt/user/appdata/radarr/config:/config
      - /mnt/user/movies/:/mnt/movies/
      - /mnt/user/shared/downloads/complete:/mnt/shared/downloads/complete/
    logging:
      driver: gelf
      options:
        gelf-address: 'udp://192.168.10.101:12201'
    image: linuxserver/radarr
```


## sonarr
```
version: '2'
services:

  sonarr:
    container_name: sonarr
    hostname: sonarr
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Chicago
      - UMASK_SET=022 #optional
    ports:
      - 8998:8989
    dns:
      - 192.168.1.103
    volumes:
      - /mnt/user/appdata/sonarr/config:/config
      - /mnt/user/shows:/shows
      #- /mnt/user/shared/downloads:/downloads
      - /mnt/user/shared/downloads:/mnt/shared/downloads
    logging:
      driver: gelf
      options:
        gelf-address: 'udp://192.168.1.101:12201'
    image: linuxserver/sonarr
```


##  transmission
```
version: '2'

services:
  transmission-openvpn:
    container_name: transmission
    hostname: transmission
    restart: unless-stopped
    environment:
      - CREATE_TUN_DEVICE=true
      - OPENVPN_PROVIDER=
      - OPENVPN_CONFIG=
      - OPENVPN_USERNAME=
      - OPENVPN_PASSWORD=
      - WEBPROXY_ENABLED=false
      - LOCAL_NETWORK=192.168.0.0/16
      - TRANSMISSION_DOWNLOAD_DIR="/mnt/shared/downloads/complete"
      - TRANSMISSION_INCOMPLETE_DIR="/mnt/shared/downloads/incomplete"
      - TRANSMISSION_INCOMPLETE_DIR_ENABLED="true"
      - TZ=America/Chicago
    dns:
      - 192.168.1.103
    volumes:
      - /mnt/user/appdata/transmission/data:/data
      - /mnt/user/appdata/transmission/config:/config
      - /mnt/user/shared/:/mnt/shared/
      - /mnt/user/movies/:/mnt/movies/
      - /mnt/user/shows/:/mnt/shows/
      - /mnt/user/isos/:/mnt/isos/
      - /mnt/user/private:/mnt/private/
    ports:
      - 9091:9091
      - 8989:8989
      - 7878:7878
    cap_add:
      - NET_ADMIN
    logging:
      driver: gelf
      options:
        gelf-address: 'udp://192.168.1.101:12201'  
    image: haugene/transmission-openvpn
```


## watchtower
```
version: '2'
services:
  
  watchtower:
    container_name: watchtower
    hostname: watchtower
    restart: unless-stopped
    environment:
      - TZ=America/Chicago
      - WATCHTOWER_SCHEDULE=0 0 2 * * *
      - WATCHTOWER_CLEANUP=true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    dns:
      - 192.168.1.103
    logging:
      driver: gelf
      options:
        gelf-address: 'udp://192.168.10.101:12201'   
    image: containrrr/watchtower
```
