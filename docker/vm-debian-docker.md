> check qemu `enabled` when creating vm
> install debian (10.6 at time of writing) net install with *nothing* except `SSH server`

```
$ su
# apt update && apt upgrade -y && apt autoremove -y
# apt install sudo
# usermod -aG sudo [USER]
# shutdown now -r

$ sudo apt install qemu-guest-agent nfs-common
$ sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
$ curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
$ sudo apt-key fingerprint 0EBFCD88
$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
$ sudo apt-get update
$ sudo apt-get install docker-ce docker-ce-cli containerd.io

$ sudo groupadd docker
$ sudo usermod -aG docker [USER]
$ sudo shutdown now -r

$ docker volume create portainer_data
$ docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer 
```

> http://IP:9000 and set up portainer
