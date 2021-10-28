# Libvirt HOWTO

Now tested with `macOS 10.15.7 Catalina`

## Creating a VM

1. Install required packages with brew using [brew-install.sh](brew-install.sh)
2. Create Libvirt config files: see and run [`./example-catalina.sh`](example-catalina.sh)
3. Start `libvirtd` service as root: `sudo brew services start libvirt`
4. Start `virtlogd` service as root: `sudo brew services start virtlogd`
5. Define domain: `sudo virsh define ./Catalina/catalina.xml`
6. Attach install media for the first
   boot: `sudo virsh attach-device Catalina --file installmedia.xml --config`
7. Start the VM: `sudo virsh start Catalina`
8. Complete installation and shutdown the VM (see [VM Management](#vm-management))
9. Connect to VM with VNC: `open vnc://localhost:5942` (password `0000`)
10. Done!

## VM Management

Start the VM: `sudo virsh start Catalina`
Shutdown the VM using [AppleQEMUGuestAgent](../AppleQEMUGuestAgent) (
preferred): `sudo virsh shutdown --mode agent Catalina`
Shutdown the VM (sometimes does not work, not investigated): `sudo virsh shutdown Catalina`
Destroy the VM: `sudo virsh destroy Catalina`
Describe network interfaces: `sudo virsh domifaddr --source agent Catalina`

