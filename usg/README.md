# Unifi Security Gateway ATT fiber bypass  
> based on https://medium.com/@mrtcve/at-t-gigabit-fiber-modem-bypass-using-unifi-usg-updated-c628f7f458cf  
> and: https://medium.com/@david.sandor/for-anyone-doing-this-with-the-unifi-security-gateway-pro-4-there-are-some-subtle-changes-you-need-da72bbce894d  
> The original article includes IPv6, these instructions only include IPv4  

Once set up, this will completely bypass the ATT Gateway. Internet traffic will pass directly from the USG to the ATT ONT. The only thing the ATT Gateway will do is provide the authentication certificates necessary to sign in to the ATT network. In fact, once it authenticates, you can disconnect the ATT Gateway. However, this is not particularly recommended as the USG may need to reauthenticate at unknown times. Leaving it connected allows the USG to reauthenticate whenever necessary.

NOTE: These instructions *probably* work with the USG Pro as well, but I haven't tested. If someone wants to send me a USG Pro, I'm happy to test :)

## Equipment:
  * ATT Optical Network Terminal (the box the fiber line goes into)
  * ATT Broadband Gateway - (tested with pace 5268Aac)
  * Unifi Security Gateway or Unifi Security Gateway Pro 4
  * Unifi Controller - (This will work with a cloud hosted instance, but you will need to do the steps in a different order *and* you can run into issues if you need to change configurations while the bypass is being set up. For the initial setup, a local running version of the controller is highly recommended.)
  
## Prep
1. Set up the USG/USG-Pro so that it is adopted by the controller. Not really able to help here as there are several different ways this can be accomplished, depending on your specific setup/needs.
  > The easiest thing to do here is first set up your USG inside the ATT gateway's "DMZ". Then completely configure your Unifi network the way you want it. Once you get your Unifi network configure, *then* work on setting up the bypass.
2. Download the necessary files (eap_proxy.py and eap_tcpdump.sh) to your computer in case the internet stops working.
3. Connect to the ATT gateway via one of the LAN ports on the ATT router.
4. Disable all possible services on the ATT gateway - particular the wifi radios.
5. Set the gateway LAN IP address to something like 192.168.254.254 or whatever won't conflict with your unifi LAN. This probably won't matter as we aren't using the LAN on the gateway, but just to make life easier.
6. Connect back to the Unifi LAN (either directly to the USG LAN port, or through a swich connected to the USG LAN port).

## Wiring configuration

### USG:

Depending on the version of your USG, you will either see [`WAN`,`LAN`,`VOIP`] ports, or [`WAN 1`,`LAN 1`,`WAN 2 / LAN 2`]. The hardware (as far as I know) is idential in both, so regardless of how they are labeled, they are mapped as follows:

| Port | Old Labels | New Labels    |
|:----:|------------|---------------|
| eth0 | WAN        | WAN 1         |
| eth1 | LAN        | LAN 1         |
| eth2 | VOIP       | WAN 2 / LAN 2 |

You will connect your cables as follows:

  1. USG eth0 (WAN 1)-> ATT ONT
  2. USG eth1 (LAN 1) -> Your LAN (probably a switch)
  3. USG eth2 (WAN 2) -> ATT Gateway ONT port

### USG Pro:

| Port | Labels |
|:----:|--------|
| eth0 | LAN 1  |
| eth1 | LAN 2  |
| eth2 | WAN 1  |
| eth3 | WAN 2  |

You will connect your cables as follows:

  1. USG eth0 (LAN 1) -> Your LAN (probably a switch)
  2. USG eth1 (LAN 2) -> Empty (unless you want something here - but your own your own if you do...)
  3. USG eth2 (WAN 1) -> ATT ONT
  4. USG eth3 (WAN 2) -> ATT Gateway ONT port
  
## Controller configuration

### USG
  
  1. Disable VOIP (you most likely won't see the option - which is fine, just skip this step): Settings > Site > Services and verify “Configure VOIP port as WAN2 on UniFi Security Gateway” is unchecked.
  2. Configure WAN (to talk to the ATT ONT):
      1. Network > WAN -> WAN -> Connection Type -> Using DHCP
      2. Network > WAN -> WAN -> IPv6 -> Disabled (refer to the original article if you want to set up IPv6)
      3. Network > WAN -> WAN -> DNS Server -> [BLANK]
      4. Network > WAN -> WAN -> Use VLAN ID -> 0
      5. Network > WAN -> WAN -> QoS Tag -> None
      6. Network > WAN -> WAN -> Smart Queues -> Unchecked
      7. Save
  4. Configure LAN 2 (to talk to the ATT Gateway): 
      1. Network -> LAN 2 -> Purpose -> Corporate
      2. Network -> LAN 2 -> Network Group -> LAN2
      2. Network -> LAN 2 -> Gateway IP/Subnet -> 192.168.254.1/24 (or whatever you prefer)
      3. Network -> LAN 2 -> DHCP Mode -> None
      4. Save
  5. Using SFTP/SCP/SSH/Whatver, copy `eap_proxy.py` and `eap_proxy.sh` to `/config/scripts/post-config.d/`
  6. SSH into USG
      1. Move `eap_proxy.py` with `sudo mv /config/scripts/post-config.d/eap_proxy.py /config/scripts/`
      2. Start up the python listening script with `sudo python /config/scripts/eap_proxy.py --restart-dhcp --ignore-when-wan-up --ignore-logoff --ping-gateway --set-mac eth0 eth2`
  7. Powercycle the ATT Gateway, wait 5+ minutes. Eventually, you should see something like `[2022-01-10 09:42:04,750]: eth0.0: 00:00:00:00:00:00 > 00:00:00:00:00:00, EAP packet (0) v1, len 4, Success (3) id 10, len 4 [0] > eth2`  
  The important part you are looking for is `Success`.
  7. Once you see `Success`, test your internet connection. You should be able to connect to the web. If not, retrace your steps.
  8. `ctrl + c` to stop the python listening script.
  9. Set the bash script to executable so it will run automatically: `chmod +x /config/scripts/post-config.d/eap_proxy.sh`
  10. Reboot usg with `reboot now`.

### USG Pro

Remote (ssh) into the router and run the following to set the proper configurations. We will need to do this because the USG Pro has a glitch when assigning VLAN 0 to the WAN port. Plus, the script is easier to use, anyway:

> **NOTE**: make sure to change `e0:22:04:86:c9:80` to whatever your ATT router's ONT MAC address is.

```bash
configure
set interfaces ethernet eth2 description WAN
set interfaces ethernet eth2 duplex auto
set interfaces ethernet eth2 firewall in name WAN_IN
set interfaces ethernet eth2 firewall local name WAN_LOCAL
set interfaces ethernet eth2 speed auto
set interfaces ethernet eth2 vif 0 address dhcp
set interfaces ethernet eth2 vif 0 description ‘WAN VLAN 0’
set interfaces ethernet eth2 vif 0 dhcp-options default-route update
set interfaces ethernet eth2 vif 0 dhcp-options default-route-distance 210
set interfaces ethernet eth2 vif 0 dhcp-options name-server update
set interfaces ethernet eth2 vif 0 firewall in name WAN_IN
set interfaces ethernet eth2 vif 0 firewall local name WAN_LOCAL
set interfaces ethernet eth2 vif 0 mac ‘e0:22:04:86:c9:80’
set interfaces ethernet eth3 description ‘AT&T router’
set interfaces ethernet eth3 duplex auto
set interfaces ethernet eth3 speed auto
set service nat rule 5010 description ‘masquerade for WAN’
set service nat rule 5010 outbound-interface eth2.0
set service nat rule 5010 protocol all
set service nat rule 5010 type masquerade
set system offload ipv4 vlan enable
commit
save
exit
```

  1. Copy `eap_proxy.py` and `eap_proxy.sh` to `/config/scripts/post-config.d/`
      - `scp /path/to/eap_proxy.py 192.168.1.1:/config/scripts/post-config.d/`
      - `scp /path/to/eap_proxy.sh 192.168.1.1:/config/scripts/post-config.d/`
      - > NOTE: Make sure to change `eap_proxy.sh` to match your eth ports and comment out `set-mac`!
  3. SSH into USG
      1. Move `eap_proxy.py` with `sudo mv /config/scripts/post-config.d/eap_proxy.py /config/scripts/`
      2. Start up the python listening script with `sudo python /config/scripts/eap_proxy.py --restart-dhcp --ignore-when-wan-up --ignore-logoff --ping-gateway`
  4. Powercycle the ATT Gateway, wait 5+ minutes. Eventually, you should see something like `[2022-01-10 09:42:04,750]: eth0.0: 00:00:00:00:00:00 > 00:00:00:00:00:00, EAP packet (0) v1, len 4, Success (3) id 10, len 4 [0] > eth2`  
  The important part you are looking for is `Success`.
  5. Once you see `Success`, test your internet connection. You should be able to connect to the web. If not, retrace your steps.
  6. `ctrl + c` to stop the python listening script.
  7. Set the bash script to executable so it will run automatically: `chmod +x /config/scripts/post-config.d/eap_proxy.sh`
  8. Reboot usg with `reboot now`.

## Conclusion
  
You should now have your USG / USG Prpo configured to completely bypass the ATT Gateway. Just note that you *will not* get full gig speeds setting up your network this way, particularly if you use the IDS/IPS setting provided by the USG. If this is an issue for you, there really isn't a good work around and you should buy different hardware. The USG simply can't handle gig speeds. However, in my experience, even without the USG in the mix, I've never come remotely close to using my available bandwidth. Even only getting around 80mbps/80mbps (with IPS enabled), I've never run into an issue. It will be rare that a server on the other end of your connection will pump out much more than that anyway. In reality, the only time you would likely see issues is if you have a whole bunch of people sharing one connection and they are all streaming 4k videos simulatinously. I tested with 6+ 4k streams running conncurrently and didn't have a problem.
