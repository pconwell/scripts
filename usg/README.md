# Unifi Security Gateway ATT fiber bypass  
> based on https://medium.com/@mrtcve/at-t-gigabit-fiber-modem-bypass-using-unifi-usg-updated-c628f7f458cf  
> and: https://medium.com/@david.sandor/for-anyone-doing-this-with-the-unifi-security-gateway-pro-4-there-are-some-subtle-changes-you-need-da72bbce894d  
> The original article includes IPv6, these instructions only include IPv4

** Confirmed working as of July 2024 **

Once set up, this will completely bypass the ATT Gateway. Internet traffic will pass directly from the USG to the ATT ONT. The only thing the ATT Gateway will do is provide the authentication certificates necessary to sign in to the ATT network. In fact, once it authenticates, you can disconnect the ATT Gateway. However, this is not particularly recommended as the USG may need to reauthenticate at unknown times. Leaving it connected allows the USG to reauthenticate whenever necessary.

## Equipment:
  * ATT Optical Network Terminal (the box the fiber line goes into)
  * ATT Broadband Gateway - (tested with pace 5268Aac)
  * Unifi Security Gateway or Unifi Security Gateway Pro 4
  * Unifi Controller - (This will work with a cloud hosted instance, but you will need to do the steps in a different order *and* you can run into issues if you need to change configurations while the bypass is being set up. For the initial setup, a local running version of the controller is highly recommended.)
  
## Prep
1. Set up your USG / USG Pro so that it is adopted by the controller.
2. (Optional) Using the ATT "DMZ" so the USG / USG Pro can connect to the internet, configure your network the way you want it and make sure everything works correctly.
   - > NOTE: I would recommend configuring the BARE MINIMUM to test that the internet works, THEN do the bypass, THEN configure your network the way you want it.
   - > ATT ONT --> ATT Gateway (DMZ) --> USG / USG Pro --> LAN
2. Download the necessary files from this repo (eap_proxy.py and eap_tcpdump.sh) to your computer because the internet will stop working at certain steps.
3. Connect your computer to the ATT gateway via one of the LAN ports on the ATT router.
  - Disable all possible services on the ATT gateway - particular the wifi radios.
  - Set the gateway LAN IP address to something like 192.168.254.254 or whatever won't conflict with your unifi LAN. This won't really matter as we aren't using the LAN on the gateway, but just to make life easier.
4. Connect your computer back to the Unifi LAN (either directly to the USG LAN port, or through a swich connected to the USG LAN port).

## Wiring configuration

### USG:

Depending on when your USG was manufactured, you will either see ports labeled [`WAN`,`LAN`,`VOIP`], or [`WAN 1`,`LAN 1`,`WAN 2 / LAN 2`]. The hardware (as far as I know) is idential in both, so regardless of how they are labeled, they are mapped as follows:

| Port | Old Labels | New Labels    | Connect to...      |
|:----:|------------|---------------|----------------------|
| eth0 | WAN        | WAN 1         | ATT ONT box          |
| eth1 | LAN        | LAN 1         | Your LAN             |
| eth2 | VOIP       | WAN 2 / LAN 2 | ATT Gateway ONT Port |

### USG Pro:

| Port | Labels | Connect to...      |
|:----:|--------|----------------------|
| eth0 | LAN 1  | Your LAN             |
| eth1 | LAN 2  |                      |
| eth2 | WAN 1  | ATT ONT box          |
| eth3 | WAN 2  | ATT Gateway ONT Port |

  
## Controller configuration

### USG

After following the prep instructions above, remote (ssh) into the router and run the following series of commands to set the proper configurations:  
> NOTE: I have not specifically tested the below config scripts, but they should work. If they don't - refer to an earlier history of this file for previous working instructions.

```
configure
set interfaces ethernet eth0 description WAN
set interfaces ethernet eth0 duplex auto
set interfaces ethernet eth0 firewall in name WAN_IN
set interfaces ethernet eth0 firewall local name WAN_LOCAL
set interfaces ethernet eth0 speed auto
set interfaces ethernet eth0 vif 0 address dhcp
set interfaces ethernet eth0 vif 0 description ‘WAN VLAN 0’
set interfaces ethernet eth0 vif 0 dhcp-options default-route update
set interfaces ethernet eth0 vif 0 dhcp-options default-route-distance 210
set interfaces ethernet eth0 vif 0 dhcp-options name-server update
set interfaces ethernet eth0 vif 0 firewall in name WAN_IN
set interfaces ethernet eth0 vif 0 firewall local name WAN_LOCAL
set interfaces ethernet eth0 vif 0 mac ‘e0:22:04:xx:xx:xx’
set interfaces ethernet eth2 description ‘AT&T router’
set interfaces ethernet eth2 duplex auto
set interfaces ethernet eth2 speed auto
set service nat rule 5010 description ‘masquerade for WAN’
set service nat rule 5010 outbound-interface eth0.0
set service nat rule 5010 protocol all
set service nat rule 5010 type masquerade
set system offload ipv4 vlan enable
commit
save
exit
```

  1. Copy `eap_proxy.py` and `eap_proxy.sh` to `/config/scripts/post-config.d/` by running `scp` from your computer:
      - `scp /path/to/eap_proxy.py username@192.168.1.1:/config/scripts/post-config.d/`
      - `scp /path/to/eap_proxy.sh username@192.168.1.1:/config/scripts/post-config.d/`
      - > NOTE: Make sure to change `eap_proxy.sh` to match your eth ports depending on which model you have! And change `username` to whatever your unifi username is.
  3. Remote (ssh) into USG:
      1. Move `eap_proxy.py` with `sudo mv /config/scripts/post-config.d/eap_proxy.py /config/scripts/`
      2. Start up the python listening script with `sudo python /config/scripts/eap_proxy.py --restart-dhcp --ignore-when-wan-up --ignore-logoff --ping-gateway --set-mac eth0 eth2`
  4. Powercycle the ATT Gateway, wait 5+ minutes.
     - After several minutes, you should see something like `[2022-01-10 09:42:04,750]: eth0.0: 00:00:00:00:00:00 > 00:00:00:00:00:00, EAP packet (0) v1, len 4, Success (3) id 10, len 4 [0] > eth2`
     - The important part you are looking for is `Success`.
  6. Once you see `Success`, test your internet connection. You should be able to connect to the web. If not, retrace your steps.
  7. `ctrl + c` to stop the python listening script.
  8. Set the bash script to executable so it will run automatically: `chmod +x /config/scripts/post-config.d/eap_proxy.sh`
  9. Reboot usg with `reboot now`.
  10. Test that you have internet connectivity.

### USG Pro

After following the prep instructions above, remote (ssh) into the router and run the following series of commands to set the proper configurations:

> **NOTE**: make sure to change `e0:22:04:xx:xx:xx` to whatever your ATT router's ONT MAC address is. It should be the MAC printed on the side of the router - very easy to find.

```
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
set interfaces ethernet eth2 vif 0 mac ‘e0:22:04:xx:xx:xx’
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

  1. Copy `eap_proxy.py` and `eap_proxy.sh` to `/config/scripts/post-config.d/` by running `scp` from your computer:
      - `scp /path/to/eap_proxy.py username@192.168.1.1:/config/scripts/post-config.d/`
      - `scp /path/to/eap_proxy.sh username@192.168.1.1:/config/scripts/post-config.d/`
      - > NOTE: Make sure to change `eap_proxy.sh` to match your eth ports depending on which model you have! And change `username` to whatever your unifi username is.
  3. Remote (ssh) into USG:
      1. Move `eap_proxy.py` with `sudo mv /config/scripts/post-config.d/eap_proxy.py /config/scripts/`
      2. Start up the python listening script with `sudo python /config/scripts/eap_proxy.py --restart-dhcp --ignore-when-wan-up --ignore-logoff --ping-gateway --set-mac eth2 eth3`
  4. Powercycle the ATT Gateway, wait 5+ minutes.
     - After several minutes, you should see something like `[2022-01-10 09:42:04,750]: eth0.0: 00:00:00:00:00:00 > 00:00:00:00:00:00, EAP packet (0) v1, len 4, Success (3) id 10, len 4 [0] > eth2`
     - The important part you are looking for is `Success`.
  6. Once you see `Success`, test your internet connection. You should be able to connect to the web. If not, retrace your steps.
  7. `ctrl + c` to stop the python listening script.
  8. Set the bash script to executable so it will run automatically: `chmod +x /config/scripts/post-config.d/eap_proxy.sh`
  9. Reboot usg with `reboot now`.
  10. Test that you have internet connectivity.

## Conclusion
  
You should now have your USG / USG Prpo configured to completely bypass the ATT Gateway.

Just note that with the USG *will not* get full gig speeds setting up your network this way, particularly if you use the IDS/IPS settings. If this is an issue for you, there really isn't a good work around and you should buy different hardware. The USG simply can't handle gig speeds. However, in my experience, even without the USG in the mix, I've never come remotely close to using my available bandwidth anyway, so it's not an issue for me. Even only getting around 80mbps/80mbps (with IPS enabled), I've never run into a bandwidth issue. I tested with 6+ 4k streams running conncurrently and didn't have a problem.
