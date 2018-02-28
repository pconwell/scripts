## initial

`$ sudo apt-get update && sudo apt-get upgrade -y`

## chromium
```
$ sudo apt-get install chromium-browser
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

## filebot
```
$ sudo apt-get install openjdk-8-jre openjfx
$ sudo dpkg -i ~/filebot_4.7.9_amd64.deb
```

## python
```
$ sudo apt-get install python3 python3-pip
$ echo "# Python3 alias" >> .bashrc
$ echo "alias python=python3" >> .bashrc
$ echo "alias pip=pip3" >> .bashrc
```

### libraries
```
$ pip install jupyter --user
```

## r / rstudio
```
$ sudo apt-get install r-base r-base-dev libjpeg62
$ sudo dpkg -i ~/rstudio-xenial-1.1.423-amd64.deb
```

### libraries
> Need to update this section with actual packages I need.

```
$ install.packages(c("tidyverse","data.table","dtplyr","devtools","roxygen2","bit64"), repos = "https://cran.rstudio.com/")
$ install.packages(c("knitr","rmarkdown"), repos='http://cran.us.r-project.org')
```

## horizon client
```
$ wget https://download3.vmware.com/software/view/viewclients/CART18FQ4/VMware-Horizon-Client-4.7.0-7395152.x64.bundle
$ chmod +x VMware-Horizon-Client-4.7.0-7395152.x64.bundle 
$ sudo ./VMware-Horizon-Client-4.7.0-7395152.x64.bundle
```

## atom
```
$ sudo apt-get install gconf-service gconf-service-backend gconf2 gconf2-common libgconf-2-4
$ curl -J -L -o atom.deb https://atom.io/download/deb
$ sudo dpkg -i atom.deb
```

## ssh
### generate key
```
$ ssh-keygen -t rsa -b 4096 -C "your@email.tld"
```

### add key to github
```
$ key=`cat ~/.ssh/id_rsa.pub`; echo "Enter title for key: "; read title; echo "Enter user name: "; read user; echo "Enter password: "; read pass; echo "Enter 2fa code: "; read otp; curl -u "$user:$pass" -H "X-GitHub-OTP: $otp" --data '{"title":"'"$title"'","key":"'"$key"'"}' https://api.github.com/user/keys
```


## git
```
$ sudo apt-add-repository ppa:git-core/ppa
$ sudo apt-get update
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

$ gpg --gen-key
$ git config --global user.signingkey `gpg --list-keys --keyid-format LONG | head -3 | tail -1 | awk -F" " '{print $2}' | awk -F"/" '{print $2}'`
$ git config --global commit.gpgsign true
$ key=$(gpg --armor --export `gpg --list-secret-keys --keyid-format LONG | head -3 | tail -1 | awk -F" " '{print $2}' | awk -F"/" '{print $2}'` | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g'); echo "Enter username: "; read user; echo "Enter password: "; read pass; echo "Enter 2fa code: "; read otp; curl -u "$user:$pass" -H "X-GitHub-OTP: $otp" --data '{"armored_public_key":"'"$key"'"}' https://api.github.com/user/gpg_keys
```

## latex
```
$ sudo apt-get install texlive texstudio
```
