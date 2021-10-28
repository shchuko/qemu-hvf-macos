# AppleQEMUGuestAgent

Tested with `macOS Catalina 10.15.7` Guest only.

macOS provides bundled `AppleQEMUGuestAgent` daemon which partially
implements [QMP protocol](https://wiki.qemu.org/Features/GuestAgent#QEMU_Guest_Agent_Protocol).

See [apple-qmp-commands.json](apple-qmp-commands.json) for supported commands and match them with
their description
on [QEMU Docs page](https://qemu.readthedocs.io/en/latest/interop/qemu-ga-ref.html#qapidoc-10).

To enable it we [should provide](https://wiki.qemu.org/Features/GuestAgent#Detailed_Summary) virtio
serial named `org.qemu.guest_agent.0`, than the daemon is started automatically by `launchd`.
See `/System/Library/LaunchDaemons/com.apple.AppleQEMUGuestAgent.plist`

Example of usage within [libvirt](../libvirt): `sudo virsh domifaddr --source agent Catalina`
describes network interfaces inside Guest
