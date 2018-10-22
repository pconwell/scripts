# Ubuntu 18.04 b2 (minimal)

## initial

``` 
$ touch ~/bin/update.sh
$ echo -e '#!/bin/bash\n\nsudo apt-get update\nsudo apt-get upgrade -y\nsudo apt-get clean\nsudo apt-get autoclean\nsudo apt-get autoremove -y' > ~/bin/update.sh
$ chmod +x ~/bin/update.sh

```
cycle login to make ~/bin pop into path

```
$ update.sh
$ sudo apt-get install cifs-utils curl
```

## chromium
```
$ sudo apt-get install chromium-browser
```

## python
```
$ sudo apt-get install python3-pip -y
$ echo "# Python3 alias" >> .bashrc
$ echo "alias python=python3" >> .bashrc
$ echo "alias pip=pip3" >> .bashrc
```

## latex
```
$ sudo apt-get install texlive texlive-latex-extra texstudio
```

## r / rstudio

> Download RStudio: https://www.rstudio.com/products/rstudio/download/#download

```
$ sudo apt-get install r-base r-base-dev libjpeg62
$ sudo dpkg -i ~/Downloads/rstudio-xenial-1.1.442-amd64.deb
```

## horizon client

> Current Version: https://my.vmware.com/web/vmware/details?downloadGroup=CART18FQ4_LIN64_470&productId=578&rPId=20573

```
$ wget https://download3.vmware.com/software/view/viewclients/CART18FQ4/VMware-Horizon-Client-4.7.0-7395152.x64.bundle
$ chmod +x VMware-Horizon-Client-4.7.0-7395152.x64.bundle 
$ sudo ./VMware-Horizon-Client-4.7.0-7395152.x64.bundle
```

## ssh / gpg
### generate ssh key
```
$ ssh-keygen -t rsa -b 4096 -C "your@email.tld"
```

### generate gpg key
```
$ gpg --gen-key
```

## git / github
```
$ sudo apt-add-repository ppa:git-core/ppa
$ sudo apt-get install git
```

### config
```
$ git config --global user.email "you@example.com"
$ git config --global user.name "Your Name"

$ git config --global core.autocrlf input
$ git config --global core.safecrlf warn

$ git config --global alias.unstage "reset HEAD --"
$ git config --global alias.hist "log --pretty=format:'%G? %C(white)%h %C(green)%ad %C(bold)%C(green)| %C(dim)%C(green)[%C(bold)%C(cyan)%an%C(dim)%C(green)] %C(bold)%C(normal)%s%d' --graph"

$ read -p "Title for key: " title; read -p "username: " user; read -s -p "password: " pass; read -p "2FA code: " otp; curl -u "$user:$pass" -H "X-GitHub-OTP: $otp" --data '{"title":"'"$title"'","key":"'"`cat ~/.ssh/id_rsa.pub`"'"}' https://api.github.com/user/keys

$ git config --global user.signingkey `gpg --list-keys --keyid-format LONG | head -3 | tail -1 | awk -F" " '{print $2}' | awk -F"/" '{print $2}'`
$ git config --global commit.gpgsign true
$ read -p "username: " user; read -s -p "password: " pass; read -p "2FA code: " otp; curl -u "$user:$pass" -H "X-GitHub-OTP: $otp" --data '{"armored_public_key":"'"$(gpg --armor --export `gpg --list-secret-keys --keyid-format LONG | head -3 | tail -1 | awk -F" " '{print $2}' | awk -F"/" '{print $2}'` | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')"'"}' https://api.github.com/user/gpg_keys
```

## vlc
```
$ sudo apt-get install vlc
```

## brasero
```
$ sudo apt-get install brasero
```

# Update

## filebot
```
$ sudo apt-get install openjdk-8-jre openjfx
$ sudo dpkg -i ~/filebot_4.7.9_amd64.deb
```


# Optional

## pycharm

> Download: https://www.jetbrains.com/pycharm/download/download-thanks.html?platform=linux

```
tar -xzf ...tar...gz
cd ...pycharm.../bin
chmod +x pycharm.sh
./pycharm.sh  
```

## docker
```
$ sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$ apt-key fingerprint 0EBFCD88
$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
$ sudo apt-get update && sudo apt-get install docker-ce
$ sudo groupadd docker
$ sudo usermod -aG docker $USER
$ sudo systemctl enable docker
$ sudo shutdown now -r
```

## Node.js / Electron / npm
```
$ sudo apt-get install nodejs npm
```

## atom
```
$ sudo apt-get install gconf-service gconf-service-backend gconf2 gconf2-common libgconf-2-4
$ curl -J -L -o atom.deb https://atom.io/download/deb
$ sudo dpkg -i atom.deb
```
