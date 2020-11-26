https://metis.fi/en/2018/02/unifi-on-gcp/

> on controller *host*

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
