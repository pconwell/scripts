
```
apt update && apt upgrade -y
apt install php php-gd php-curl php-zip php-dom php-xml php-simplexml php-mbstring apache2 libapache2-mod-php mariadb-server php-mysql unzip

systemctl status apache2

mysql -u root -p

  CREATE DATABASE nextclouddb;
  GRANT ALL ON nextclouddb.* TO '[DB_USER_NAME]'@'localhost' IDENTIFIED BY '[DB_USER_PASS]';
  FLUSH PRIVILEGES;
  EXTI;

cd /tmp
wget https://download.nextcloud.com/server/releases/nextcloud-16.0.1.zip
unzip nextcloud-16.0.1.zip

mv nextcloud /var/www/html
cd /var/www/html
chown -R www-data:www-data nextcloud
chmod -R 755 nextcloud
```

Go to the IP address in broswer. Enter whatever info for admin user/password. For the database connection, you should be able to leave everything default, just enter the database user as created during the database creation process.
