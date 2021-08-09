## Crashplan

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
      - 9.9.9.9
    volumes:
      - config:/config
      - storage:/storage
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
        gelf-address: 'udp://192.168.1.91:12201'      
    image: jlesage/crashplan-pro

volumes:
  config:
    driver: local
  storage:
    driver: local
```

## Transmission

```
version: '2'

services:
  transmission-openvpn:
    container_name: transmission
    hostname: transmission
    restart: unless-stopped
    environment:
      - CREATE_TUN_DEVICE=true
      - OPENVPN_PROVIDER=[provider]
      - OPENVPN_CONFIG=[leaveblank_deletethis]
      - OPENVPN_USERNAME=user@email.com
      - OPENVPN_PASSWORD=password
      - WEBPROXY_ENABLED=false
      - LOCAL_NETWORK=192.168.1.0/24
      - TRANSMISSION_DOWNLOAD_DIR="/mnt/shared/downloads/complete"
      - TRANSMISSION_INCOMPLETE_DIR="/mnt/shared/downloads/incomplete"
      - TRANSMISSION_INCOMPLETE_DIR_ENABLED="true"
      - TZ=America/Chicago
    dns:
      - 9.9.9.9
    volumes:
      - data:/data
      - config:/config
      - /mnt/user/shared/:/mnt/shared/
      - /mnt/user/movies/:/mnt/movies/
      - /mnt/user/shows/:/mnt/shows/
      - /mnt/user/isos/:/mnt/isos/
    ports:
      - 9091:9091
      - 8989:8989
      - 7878:7878
    cap_add:
      - NET_ADMIN
    logging:
      driver: gelf
      options:
        gelf-address: 'udp://192.168.1.91:12201'    
    image: haugene/transmission-openvpn


volumes:
  data:
    driver: local
  config:
    driver: local  
```

## Watchtower

```
version: '2'
services:
  
  watchtower:
    container_name: watchtower
    hostname: watchtower
    restart: unless-stopped
    environment:
      - TZ=America/Chicago
      - WATCHTOWER_SCHEDULE=0 0 4 * * *
      - WATCHTOWER_CLEANUP=true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    dns:
      - 9.9.9.9
    logging:
      driver: gelf
      options:
        gelf-address: 'udp://192.168.1.91:12201'   
    image: containrrr/watchtower
```
