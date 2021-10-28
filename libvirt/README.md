# Libvirt HOWTO

Now tested with `macOS 10.15.7 Catalina`

## Creating a VM

1. Install required packages with brew using [brew-install.sh](brew-install.sh)
2. Fix libvirt config files, setup launchd
   with [`./libvirt-afterinstall.sh`](libvirt-afterinstall.sh) (you will be prompted your password
   to access `/Library/LaunchDaemons/` directory)
3. Create domain xml using [`./example-catalina.sh`](example-catalina.sh)
4. Define domain: `sudo virsh define ./Catalina/catalina.xml`
5. Attach install media for the first
   boot: `sudo virsh attach-device Catalina --file installmedia.xml --config`
6. Start the VM: `sudo virsh start Catalina`
7. Complete installation and shutdown the VM (see [VM Management](#vm-management))
8. Connect to VM with VNC: `open vnc://localhost:5942` (password `0000`)
9. Done!

## VM Management

- Start the VM:

  `sudo virsh start Catalina`

- Shutdown the VM using [AppleQEMUGuestAgent](../AppleQEMUGuestAgent) (preferred):

  `sudo virsh shutdown --mode agent Catalina`

- Shutdown the VM: ACPI mode (sometimes does not work, not investigated):

  `sudo virsh shutdown Catalina` or `sudo virsh shutdown --mode acpi Catalina`

- Destroy the VM:

  `sudo virsh destroy Catalina`

- Describe network interfaces:

  `sudo virsh domifaddr --source agent Catalina`

