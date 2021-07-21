## nag buster

```
wget https://raw.githubusercontent.com/foundObjects/pve-nag-buster/master/install.sh
bash install.sh
```

## ups auto shutdown

```
apt install apcupsd 
  
  optional?: apt install apcupsd-doc apcupsd-cgi
  
nano /etc/apcupsd/apcupsd.conf

  UPSCABLE ether
  UPSTYPE snmp
  DEVICE 192.168.1.19
  LOCKFILE /var/lock
  SCRIPTDIR /etc/apcupsd
  PWRFAILDIR /etc/apcupsd
  NOLOGINDIR /etc
  ONBATTERYDELAY 6
  BATTERYLEVEL 50
  TIMEOUT 300
  ANNOY 300
  ANNOYDELAY 60
  NOLOGON disable
  KILLDELAY 0
  NETSERVER on
  NISIP 0.0.0.0
  NISPORT 3551
  EVENTSFILE /var/log/apcupsd.events
  EVENTSFILEMAX 10
  UPSCLASS standalone
  UPSMODE disable
  STATTIME 0
  STATFILE /var/log/apcupsd.status
  LOGSTATS off
  DATATIME 0
  

nano /etc/default/apcupsd

  ISCONFIGURED=yes

/etc/init.d/apcupsd start
apcaccess status

```
