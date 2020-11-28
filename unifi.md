https://metis.fi/en/2018/02/unifi-on-gcp/

1. create google compute cloud free (f1-micro)
2. enable storage api (may already be enabled): APIs & Services -> Dashboard -> Enable APIs & Services -> (search) Google Cloud Storage JSON API -> (click) Google Cloud Storage JSON API -> Enable.
3. create storage bucket (for backups): storage -> browser -> create new (use same region as f1-micro)
4. set up virutal network: VPC Network -> Firewall Rules -> create new (name *allow-unifi*)
    1. target: unifi
    2. tag: unifi
    3. source ip: 0.0.0.0/0
    4. protocols and ports:
        1. tcp: 8443,8080,8880,8843,6789,443,80
        2. udp: 3478
5. create static ip address: VPC Networks -> external ip addresses -> (use same region as f1-micro) -> reserve
6. create vm: compute engine -> vm instances -> create new
    1. zone: whatever zone offers free f1-micro instance (e.g. us-east1 South Carolina)
    2. boot disk: 15 gb
    3. boot disk: debian 9 (stretch)
    4. access scopes (api) -> storage -> change to read/write (for backups)
    5. Management, disks, networking, SSH keys -> advanced ->
        | KEY | VALUE | NOTES |
        | --- | ----- | ----- |
        | startup-script-url | https://gist.githubusercontent.com/pconwell/ab3cf6b792bb60d665dc2de58edb74e5/raw/993c0690bc988c710a14b8e613cd802f40a5ac87/gs-startup.sh
 | Required! |        
        | ddns-url | http://your.dyn.dns/update.php?key=xxxxx | Helps you access the Controller (not used) |
        | timezone | America/Chicago | set the correct timezone | 
        | dns-name | your.url.org | Required for HTTPS certificate | 
        | bucket | unifi-controller-XXXXXX | Required for offline backups | 
    6. Networking ->
        1. networking tags -> "unifi"
        2. network interfaces -> external ip -> default -> static ip (from above)
5. Create
6. Wait 10 minutes
7. Connect to controller and restore backup from existing controller
8. On existing controller, change controller address to new controller's ip address (settings -> controller -> controller hostname/ip & override inform host)
9. wait for devices to connect to new controller
10. shutdown old controller
11. set logging level to enable fail2ban: settings -> maintenance -> services -> log level -> set to "more"



create backup schedule



> to "fix" dns to fall-back only mode
> this way, it will use custom dns (pihole) only *unless* pihole is down
> on controller *host* (external):

`$ su`
`# nano /usr/lib/unifi/data/sites/default/config.gateway.json`

```json
{
    "service":{
        "dns":{
            "forwarding":{
                "options":[
                    "strict-order",
                    "server=1.1.1.1",
                    "server=192.168.1.93"
                ]
            }
        }
    }
}
````

> to reset controller each day at 3 am
> (test to see if it resets dns if primary dns fails)
> (currently, if primary dns fails, it falls back to secondary,
> but doesn't revert back to primary only once primary is back online)
> ssh into USG:

```
$ sudo su
# crontab -e
0 3 * * * /sbin/reboot
```
