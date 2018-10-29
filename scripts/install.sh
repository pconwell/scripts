#!/bin/bash

# email for ssh/gpg/github
read -p "your email address: " email;

# github stuff
read -p "your name (for github commits): " name;
read -p "Title for key (e.g. home, work, etc): " title; 
read -p "github username: " user; 
read -s -p "github password: " pass; 
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
~/bin/update.sh

# Install a bunch of stuff from repos
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common cifs-utils libgtk2.0-0 # core utils

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

# config docker
sudo groupadd docker
sudo usermod -aG docker $USER
sudo systemctl enable docker
#sudo shutdown now -r

# install downloaded debs
sudo dpkg -i ~/Downloads/rstudio-xenial-1.1.456-amd64.deb
sudo env TERM=dumb ~/Downloads/VMware-Horizon-Client-4.9.0-9507999.x64.bundle --eulas-agree --required --console

#python aliases
echo "# Python3 alias" >> .bashrc
echo "alias python=python3" >> .bashrc
echo "alias pip=pip3" >> .bashrc

# ssh key gen
ssh-keygen -t rsa -b 4096 -C $email -f ~/.ssh/id_rsa -q -N ""

# gpg key gen
echo '%echo Generating a basic OpenPGP key' > gpggen
echo '%echo This can be quick, or it could take a WHILE' >> gpggen
echo 'Key-Type: default' >> gpggen
echo 'Subkey-Type: default' >> gpggen
echo 'Name-Real: '"$USER"'' >> gpggen
echo 'Name-Comment: '"$title"'' >> gpggen
echo 'Name-Email: '"$email"'' >> gpggen
echo 'Expire-Date: 0' >> gpggen
echo 'Passphrase: ""' >> gpggen
echo '# Do a commit here, so that we can later print "done" :-)' >> gpggen
echo '%commit' >> gpggen
echo '%echo done' >> gpggen

gpg --batch --generate-key gpggen

# config git
git config --global user.email $email
git config --global user.name $name

git config --global core.autocrlf input
git config --global core.safecrlf warn

git config --global alias.unstage "reset HEAD --"
git config --global alias.hist "log --pretty=format:'%G? %C(white)%h %C(green)%ad %C(bold)%C(green)| %C(dim)%C(green)[%C(bold)%C(cyan)%an%C(dim)%C(green)] %C(bold)%C(normal)%s%d' --graph"

git config --global user.signingkey `gpg --list-keys --keyid-format LONG | head -3 | tail -1 | awk -F" " '{print $2}' | awk -F"/" '{print $2}'`
git config --global commit.gpgsign true


# config github
read -p "github 2FA code: " otp; curl -u "$user:$pass" -H "X-GitHub-OTP: $otp" --data '{"title":"'"$title"'","key":"'"`cat ~/.ssh/id_rsa.pub`"'"}' https://api.github.com/user/keys
read -p "2FA code: " otp; curl -u "$user:$pass" -H "X-GitHub-OTP: $otp" --data '{"armored_public_key":"'"$(gpg --armor --export `gpg --list-secret-keys --keyid-format LONG | head -3 | tail -1 | awk -F" " '{print $2}' | awk -F"/" '{print $2}'` | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')"'"}' https://api.github.com/user/gpg_keys


#sudo shutdown now -r



