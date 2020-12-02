
```
apt install -y apt-transport-https openjdk-11-jre-headless uuid-runtime pwgen dirmngr gnupg wget

wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | apt-key add -
echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/4.2 main" | tee /etc/apt/sources.list.d/mongodb-org-4.2.list
apt-get update
apt-get install -y mongodb-org
systemctl daemon-reload
systemctl enable mongod.service
systemctl restart mongod.service
systemctl --type=service --state=active | grep mongod
mongo --eval " db.adminCommand( { setFeatureCompatibilityVersion: \"4.0\" } ) "

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/oss-6.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-6.x.list
apt update && apt install elasticsearch-oss
nano /etc/elasticsearch/elasticsearch.yml 
systemctl daemon-reload
systemctl enable elasticsearch.service
systemctl restart elasticsearch.service
systemctl restart elasticsearch.service

wget https://packages.graylog2.org/repo/packages/graylog-X.X-repository_latest.deb
dpkg -i graylog-X.X-repository_latest.deb
apt-get update && apt-get install graylog-server
echo -n "Enter Password: " && head -1 </dev/stdin | tr -d '\n' | sha256sum | cut -d" " -f1
nano /etc/graylog/server/server.conf
pwgen -N 1 -s 96
nano /etc/graylog/server/server.conf
systemctl daemon-reload
systemctl enable graylog-server.service
systemctl start graylog-server.service
systemctl --type=service --state=active | grep graylog

```
