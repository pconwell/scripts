# Unifi Security Gateway ATT fiber bypass
> based on https://medium.com/@mrtcve/at-t-gigabit-fiber-modem-bypass-using-unifi-usg-updated-c628f7f458cf  
> The original article includes IPv6, these instructions only include IPv4


Equipment:
  * ATT Optical Network Terminal (the box the fiber line goes into)
  * ATT Broadband Gateway - (tested with pace 5268Aac)
  * Unifi Security Gateway
  * Unifi Controller - (This will work with a cloud hosted instance, but you will need to do the steps in a different order *and* you can run into issues if you need to change configurations while the bypass is being set up. For the initial setup, a local running version of the controller is highly recommended.)
  
## Prep
1. Set up the USG so that it is adopted by the controller. Not really able to help here as there are several different ways this can be accomplished, depending on your specific setup/needs.
  > The easiest thing to do here is first set up your USG inside the ATT gateway's "DMZ". Then completely configure your Unifi network the way you want it. Once you get your Unifi network configure, *then* work on setting up the bypass.
2. Download the necessary files (eap_proxy.py and eap_tcpdump.sh) to your computer in case the internet stops working.
3. Connect to the ATT gateway via one of the LAN ports.
4. Disable all possible services on the ATT gateway - particular the wifi radios.
5. Set the gateway LAN IP address to something like 192.168.254.254 or whatever won't conflict with your unifi LAN. This probably won't matter as we aren't using the LAN on the gateway, but just to make life easier.
6. Connect back to the Unifi LAN (either directly to the USG LAN port, or through a swich connected to the USG LAN port).

## Wiring configuration

1. Depending on the version of your USG, you will either see [`WAN`,`LAN`,`VOIP`] ports, or [`WAN 1`,`LAN 1`,`WAN 2 / LAN 2`]. The hardware (as far as I know) is idential in both, so regardless of how they are labeled, they are mapped as follows:

| Port | Old Labels | New Labels    |
|:----:|------------|---------------|
| eth0 | WAN        | WAN 1         |
| eth1 | LAN        | LAN 1         |
| eth2 | VOIP       | WAN 2 / LAN 2 |

  1. USG eth0 -> ATT ONT
  2. USG eth1 -> Your LAN (probably a switch)
  3. USG eth2 -> ATT Gateway ONT port
  
  ## Controller configuration
  
  1. Disable VOIP (you most likely won't see the option - which is fine, just skip this step): Settings > Site > Services and verify “Configure VOIP port as WAN2 on UniFi Security Gateway” is unchecked.
  2. Set WAN to VLAN 0: Settings -> Network -> WAN -> Use VLAN ID -> 0 -> Save
  3. Configure LAN 2 (to talk to the ATT Gateway): 
      1. Network -> LAN 2 -> Purpose -> Corporate
      2. Network -> LAN 2 -> Network Group -> LAN2
      2. Network -> LAN 2 -> Gateway IP/Subnet -> 192.168.254.1/24 (or whatever you prefer)
      3. Network -> LAN 2 -> DHCP Mode -> None
      4. Save
  4. Using SFTP/SCP/SSH/Whatver, copy `eap_proxy.py` and `eap_proxy.sh` to `/config/scripts/post-config.d/`
  5. SSH into USG
      1. Move `eap_proxy.py` with `sudo mv /config/scripts/post-config.d/eap_proxy.py /config/scripts/`
      2. Start up the python listening script with `sudo python /config/scripts/eap_proxy.py --restart-dhcp --ignore-when-wan-up --ignore-logoff --ping-gateway --set-mac eth0 eth2`
  6. Powercycle the ATT Gateway, wait 5+ minutes. Eventually, you should see something like `[2022-01-10 09:42:04,750]: eth0.0: 00:00:00:00:00:00 > 00:00:00:00:00:00, EAP packet (0) v1, len 4, Success (3) id 10, len 4 [0] > eth2`  
  The important part you are looking for is `Success`.
  7. Once you see `Success`, test your internet connection. You should be able to connect to the web. If not, retrace your steps.
  8. `ctrl + c` to stop the python listening script.
  9. Set the bash script to executable so it will run automatically: `chmod +x /config/scripts/post-config.d/eap_proxy.sh`
  10. Reboot usg with `reboot now`.
  
  
