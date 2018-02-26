`$ sudo apt-get update && sudo apt-get upgrade -y`

----

### chromium
```
$ sudo apt-get install chromium-browser
```


### docker
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

### filebot
```
$ sudo apt-get install openjdk-8-jre openjfx
$ sudo dpkg -i ~/filebot_4.7.9_amd64.deb
```

### python
```
$ sudo apt-get install python3 python3-pip
$ echo "# Python3 alias" >> .bashrc
$ echo "alias python=python3" >> .bashrc
$ echo "alias pip=pip3" >> .bashrc
```

### R / RStudio
```
$ sudo apt-get install r-base r-base-dev libjpeg62
$ sudo dpkg -i ~/rstudio-xenial-1.1.423-amd64.deb
```

### Horizon Client
```
$ wget https://download3.vmware.com/software/view/viewclients/CART18FQ4/VMware-Horizon-Client-4.7.0-7395152.x64.bundle
$ chmod +x VMware-Horizon-Client-4.7.0-7395152.x64.bundle 
$ sudo ./VMware-Horizon-Client-4.7.0-7395152.x64.bundle
```

### atom
```
$ sudo apt-get install gconf-service gconf-service-backend gconf2 gconf2-common libgconf-2-4
$ curl -J -L -o atom.deb https://atom.io/download/deb
$ sudo dpkg -i atom.deb
```


----


## Python
```
pip install jupyter --user
```

## R / RStudio


----





# TEMP



# Install R
sudo apt-get update
sudo apt-get install gdebi libxml2-dev libssl-dev libcurl4-openssl-dev libopenblas-dev r-base r-base-dev

# Install RStudio
cd ~/Downloads
wget https://download1.rstudio.org/rstudio-xenial-1.1.383-amd64.deb
sudo gdebi rstudio-xenial-1.1.383-amd64.deb
printf '\nexport QT_STYLE_OVERRIDE=gtk\n' | sudo tee -a ~/.profile

# install common packages
R --vanilla << EOF
install.packages(c("tidyverse","data.table","dtplyr","devtools","roxygen2","bit64"), repos = "https://cran.rstudio.com/")
q()
EOF

# Export to HTML/Excel
R --vanilla << EOF
install.packages(c("htmlTable","openxlsx"), repos = "https://cran.rstudio.com/")
q()
EOF

# Blog tools
R --vanilla << EOF
install.packages(c("knitr","rmarkdown"), repos='http://cran.us.r-project.org')
q()
EOF
sudo apt-get install python-pip
sudo pip install markdown rpy2==2.7.8 pelican==3.6.3

# PDF extraction tools
sudo apt-get install libpoppler-cpp-dev default-jre default-jdk r-cran-rjava
sudo R CMD javareconf
R --vanilla << EOF
library(devtools)
install.packages("pdftools", repos = "https://cran.rstudio.com/")
install_github("ropensci/tabulizer")
q()
EOF

# TTF/OTF fonts usage
sudo apt-get install libfreetype6-dev
R --vanilla << EOF
install.packages("showtext", repos = "https://cran.rstudio.com/")
q()
EOF

# Cairo for graphic devices
sudo apt-get install libgtk2.0-dev libxt-dev libcairo2-dev
R --vanilla << EOF
install.packages("Cairo", repos = "https://cran.rstudio.com/")
q()
EOF
