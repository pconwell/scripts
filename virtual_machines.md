# Virtual Machines

## Shutdown

VBoxManage controlvm <vmname> pause|resume|reset|poweroff|savestate

```$ VBoxManage controlvm testbox poweroff```

## Create VM Bash Script

```bash
#!/bin/bash
#

# change NAME to whatever you want to call the vm
vm_name='NAME'

# default to 10gb, but change to whatever. This is the *max* size, it is an expandable vdi.
vm_hdd_size='10000'

# 'RAM', default 1gb
vm_memory='1024'

# port for VRDE. This probably needs to be fixed so the default port (3389) is not being used by other VMs when VRDE is not needed on them.
vm_vrdeport='3391'

# Create VM
VBoxManage createvm --name $vm_name --register
VBoxManage modifyvm $vm_name --memory $vm_memory --acpi on --pae on --vrdeport $vm_vrdeport --boot1 dvd --nic1 bridged --bridgeadapter1 eth1
VBoxManage createhd --filename $vm_name.vdi --size $vm_hdd_size
VBoxManage storagectl $vm_name --name "IDE Controller" --add ide
VBoxManage storageattach $vm_name --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium ~/$vm_name.vdi
VBoxManage storageattach $vm_name --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium ~/current_ubuntu_server.iso

# Start VM
VBoxHeadless --startvm $vm_name

# Detach dvd drive
#VBoxManage storageattach $vm_name --storagectl "IDE Controller" --port 1 --device 0 --medium emptydrive
```
