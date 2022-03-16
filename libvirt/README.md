# Libvirt HOWTO

Now tested with `macOS 10.15.7 Catalina`

## Creating a VM

1. Install required packages with brew using [brew-install.sh](brew-install.sh)
2. Fix libvirt config files with [`./fix-qemu-conf.sh`](fix-qemu-conf.sh)
3. Launch libvirt services with `sudo libvirt-enable.sh` (you will be prompted your password to
   access `/Library/LaunchDaemons/` directory). Be careful while this step!
4. Create domain xml using [`./example-catalina.sh`](example-catalina.sh)
5. Define domain: `sudo virsh define ./Catalina/catalina.xml`
6. Attach install media for the first
   boot: `sudo virsh attach-device Catalina --file ./Catalina/installmedia.xml --config`
7. Start the VM: `sudo virsh start Catalina`
8. Complete installation and shutdown the VM (see [VM Management](#vm-management))
9. Connect to VM with VNC: `open vnc://localhost:5942` (password `0000`)
10. Done!

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

## Notes

For some reason networking via `virtio-net-pci` does not work properly with Catalina guest.
`vmxnet3` used instead.