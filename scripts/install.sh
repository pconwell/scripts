#!/bin/bash

# email for ssh/gpg/github
read -p "your email address: " email;

# github stuff
read -p "your name (for github commits): " name;
read -p "Title for key: " title; 
read -p "username: " user; 
read -s -p "password: " pass; 
#read -p "2FA code: " otp; ### Will probably have to do this multiple times, so probably read later

#download some files
wget -P ~/Downloads/ https://download1.rstudio.org/rstudio-xenial-1.1.456-amd64.deb
wget -P ~/Downloads/ https://download3.vmware.com/software/view/viewclients/CART19FQ3/VMware-Horizon-Client-4.9.0-9507999.x64.bundle
chmod +x ~/Downloads/VMware-Horizon-Client-4.9.0-9507999.x64.bundle

# Make update script and update system
mkdir ~/bin
touch ~/bin/update.sh
echo -e '#!/bin/bash\n\nsudo apt-get update\nsudo apt-get upgrade -y\nsudo apt-get clean\nsudo apt-get autoclean\nsudo apt-get autoremove -y' > ~/bin/update.sh
chmod +x ~/bin/update.sh
#~/bin/update.sh

# Install a bunch of stuff from repos
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common cifs-utils # core utils

## git
sudo apt-add-repository ppa:git-core/ppa

## docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt-get install \ # core utils
chromium-browser \ #chrome
python3-pip \ #python pip
texlive texlive-latex-extra texstudio \ #latex
r-base r-base-dev libjpeg62 \ # r
git \ # git
vlc \ # vlc
brasero \ # brasero
docker-ce \ # docker
-y

# install downloaded debs
sudo dpkg -i ~/Downloads/rstudio-xenial-1.1.456-amd64.deb
sudo env TERM=dumb ~/Downloads/VMware-Horizon-Client-4.9.0-9507999.x64.bundle --eulas-agree --required --console

#python aliases
echo "# Python3 alias" >> .bashrc
echo "alias python=python3" >> .bashrc
echo "alias pip=pip3" >> .bashrc

# ssh key gen
ssh-keygen -t rsa -b 4096 -C "you@email.tld" -f ~/.ssh/id_rsa -q -N ""








