## Install hassio in proxmox

1. Download latest qcow2 image: https://github.com/home-assistant/operating-system/releases/
2. Unzip on local machine (may be xz format, 7 zip can handle)
3. Copy unziped qcow2 image from local machine to proxmox host: `scp 'C:\Users\pconwell\Downloads\haos_ova-7.1.qcow2' root@IP/HOST:/root/`
4. Create a new VM ->
   1. VM ID: As appropriate
   2. Name: As appropriate
   3. OS: Do not use any media
   4. System: Machine -> q35
   5. System: BIOS -> OVMF
   6. System: Add EFI Disk -> uncheck
   7. Disks: Delete all disks
   8. CPU: 4 cores (or as appropriate)
   9. Memory: 2048 (or as appropriate)
   10. Network: bridge and VLAN as appropriate
5. On proxmox host: `qm importdisk [VM ID] /root/haos_ova-[VERSION].qcow2 local-lvm --format qcow2`
8. home-assistant -> hardware -> unused disk 0 -> double click -> add
9. home-assistant -> options -> boot order -> move scsi0 to top and enable checkbox (uncheck other two, if you want)
10. start VM
11. wait for boot (2-3 minutes), then find IP address and navigate to http://IP:8123
