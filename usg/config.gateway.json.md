# /usr/lib/unifi/sites/default/config.gateway.json

```

{
   "service":{
      "dns":{
         "forwarding":{
            "options":[
               "strict-order",
               "server=192.168.1.103",
               "server=192.168.10.23"
            ]
         }
      },
      "mdns":{
         "repeater":{
            "interface":[
               "eth1.10",
               "eth1.20",
               "eth1.30",
               "eth1.90"
            ]
         }
      },
      "nat":{
         "rule":{
            "1":{
               "description":"Redirect DNS queries to pihole",
               "destination":{
                  "port":"53"
               },
               "source":{
                  "address":"!192.168.1.103"
               },
               "inside-address":{
                  "address":"192.168.1.103",
                  "port":"53"
               },
               "inbound-interface":"eth1",
               "protocol":"tcp_udp",
               "type":"destination"
            },
            "5002":{
               "description":"Translate reply back",
               "destination":{
                  "address":"192.168.1.103",
                  "port":"53"
               },
               "outbound-interface":"eth1",
               "protocol":"tcp_udp",
               "type":"masquerade"
            }
         }
      }
   }
}
```
