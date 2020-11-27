https://metis.fi/en/2018/02/unifi-on-gcp/

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
> *in* controller (internal):

```
$ sudo su
# crontab -e
0 3 * * * /sbin/reboot
```
