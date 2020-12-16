```
apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev curl libbz2-dev unzip libpq-dev postgresql
curl -O https://www.python.org/ftp/python/3.8.6/Python-3.8.6.tar.xz
tar -xf Python-3.8.6.tar.xz
cd Python-3.8.6/
./configure --enable-optimizations
make -j 2
make install
apt install python3-pip

wget https://github.com/vabene1111/recipes/archive/master.zip
unzip master.zip
cd recipes-develop
pip3 install -r requirements.txt

su - postgres
psql

    CREATE DATABASE djangodb;
    CREATE USER djangouser WITH PASSWORD 'password';
    GRANT ALL PRIVILEGES ON DATABASE djangodb TO djangouser;
    ALTER DATABASE djangodb OWNER TO djangouser;

    --Maybe not necessary, but should be faster:
    ALTER ROLE djangouser SET client_encoding TO 'utf8';
    ALTER ROLE djangouser SET default_transaction_isolation TO 'read committed';
    ALTER ROLE djangouser SET timezone TO 'UTC';

    --Grant superuser right to your new user, it will be removed later
    ALTER USER djangouser WITH SUPERUSER;
  
\q
exit

mv .env.template .env
base64 /dev/urandom | head -c50 (to generate secret key for .env below)
nano .env (set secret key and POSTGRES_HOST=localhost and postgres username and password as above)
export $(cat .env |grep "^[^#]" | xargs)
python3 manage.py migrate
python3 manage.py collectstatic

python3 manage.py runserver 0.0.0.0:80
```
