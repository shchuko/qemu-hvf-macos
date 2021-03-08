# macOS over QEMU/HVF howto

Examples of running macOS over QEMU on Intel-based Mac hosts with Hypervisor.Framework acceleration (`-accel hvf`)

## A couple of required things

- [Patched QEMU](https://github.com/shchuko/qemu/tree/v5.2.0/darwin-support) (patches haven't been merged into qemu
  master yet)

- [Patched UEFI](https://github.com/shchuko/OvmfDarwinPkg)

- [OSK Key retrieval tool](readosk) - required for AppleSMC emulation

- macOS installation app (ex.`/Applications/Install macOS Catalina.app`)

- XCODE Command Line Tools

- [QEMU build requirements](https://wiki.qemu.org/Hosts/Mac)

## Repo content

- [readosk](readosk) - OSK Key retrieval tool sources

- [readosk-build.sh](readosk-build.sh) - readosk build script

- [qemu-build.sh](qemu-build.sh) - QEMU clone & build script

- [get-firmware.sh](get-firmware.sh) - Patched UEFI download & unpack script

- [create-install-img.sh](create-install-img.sh) - Install disk image creation script. May ask sudo password!

- [boot.sh](boot.sh) - VM boot script. Run `./boot.sh -help` for more information

- [vm-run-install.sh](vm-run-install.sh) - macOS installation & run script. Invoked scripts below in correct order

- [tap-up.sh](tap-up.sh) - tap interface UP script example

- [tap-down.sh](tap-down.sh) - tap interface DOWN script example

## Installation HOWTO

The simplest way to install macOS is:

```bash
./vm-run-install.sh -install 
# Or
./vm-run-install.sh -install -os "Catalina"
```

Replace 'Catalina' with required OS name (default is 'Catalina') to choose 
the app you wanted: `/Applications/Install macOS Catalina.app`. The script downloads and 
builds QEMU, downloads UEFI, creates installation media, builds `readosk` tool, retrieves 
OSK key, creates drive to install macOS onto, starts QEMU VM. May ask sudo password!

Continue installation there. You may need to choose the startup disk from UEFI boot menu, 
if you run into EFI shell

After installation complete, to boot your guest macOS just run

```bash
./vm-run-install.sh
```

## Networking

By default [boot.sh](boot.sh) will run QEMU using `-nic user`. Also, **tap networking is supported**. 
Required Tun/Tap kernel extension can be found [here](https://github.com/Tunnelblick/Tunnelblick/tree/master/third_party)

**Note:** building QEMU with glib v2.66.7 **corrupts** tun/tap networking, the problem is needed to be investigated. Luckily, 
everything works fine with glib v2.58.3

To use tap-networking run:

```bash
./vm-run-install.sh -tap-net
```

