# macOS over QEMU/HVF howto

Examples of running macOS over QEMU on Intel-based Mac hosts with Hypervisor.Framework acceleration (`-accel hvf`)

## A couple of required things

- [Patched QEMU](https://github.com/shchuko/qemu/tree/v5.2.0/darwin-support) (patches are merged into qemu master, but
  not released)

- [Patched UEFI](https://github.com/shchuko/OvmfDarwinPkg)

- [OSK Key retrieval tool](readosk) - required for AppleSMC emulation

- macOS installation app (ex.`/Applications/Install macOS Catalina.app`)

- XCODE Command Line Tools

- [QEMU build requirements](https://wiki.qemu.org/Hosts/Mac)

## Repo content

- [boot-macos.sh](boot-macos.sh) - macOS installation & run script. Invokes tools below in correct order.
  Run `./boot-macos.sh -help` for more information

- [readosk](readosk) - OSK Key retrieval tool sources

- [readosk-build.sh](readosk-build.sh) - readosk build script

- [qemu-build.sh](qemu-build.sh) - QEMU clone & build script

- [glib-build.sh](glib-build.sh) - GLib clone & build script

- [get-firmware.sh](get-firmware.sh) - Patched UEFI download & unpack script

- [create-install-img.sh](create-install-img.sh) - Install disk image creation script. Requires sudo privileges!

- [qemu-system-wrapper.sh](qemu-system-wrapper.sh) - VM boot script. Run `./qemu-system-wrapper.sh -help` for more
  information

- [bridge-utils/*](bridge-utils) - simple wrappers for `ifconfig` to operate with network bridges

## Installation HOWTO

The simplest way to install macOS is:

```bash
# Firstly, run:
./boot-macos.sh -install-macos "Catalina"
# ... to attach installation media
# The drive to install system onto will be created and attached to VM
# Erase it, create APFS using Disk Utility and start OS installation
# After the reboot detach install media and finish installation:
./boot-macos.sh
```

Replace 'Catalina' with required OS name to choose the app you wanted, ex: `/Applications/Install macOS Catalina.app`.

> The script will clone and build QEMU with its GLib dependency,
> retrieve UEFI binaries, create installation media *BaseSystem.cdr*, build `readosk` tool, retrieve OSK key,
> create a drive to install macOS onto, and finally start QEMU VM. Notice that
> [create-install-img.sh](create-install-img.sh) being a part of [boot-macos.sh](boot-macos.sh) requires sudo
> privileges!

After everything is done, to boot your guest macOS just run:

```bash
./boot-macos.sh
```

## Attaching devices

Now you can attach QCOW2 and raw disk images:

```bash
./boot-macos.sh -drive-qcow2 /path/to/some/image.qcow2
./boot-macos.sh -drive-qcow2 /path/to/some/image.raw
```

And network devices:

```bash
./boot-macos.sh -net-user # User (slirp) networking
./boot-macos.sh -net-tap # Tap networking
./boot-macos.sh -vmnet-shared # vmnet.Framework networking in shared mode (experimental)
./boot-macos.sh -vmnet-host # vmnet.Framework networking in host mode (experimental)
./boot-macos.sh -vmnet-bridged enX # vmnet.Framework networking in bridged mode, bridged onto enX (experimental)
```

Add as many devices as you need:

```bash
./boot-macos.sh -net-user \
  -drive-qcow2 /path/to/some/image.qcow2 \
  -net-tap \
  -drive-qcow2 /path/to/some/image.raw \
  -vmnet-shared 
```

## Boot Order

1. Installation media has the highest boot priority.

2. Default drive has the highest boot priority after installation media.

    * you can detach this drive by passing `-no-default-drive`:

      ```bash
      ./boot-macos.sh -no-default-drive
      ```

3. Other drives' boot order meets this script arguments pass order.

4. Attached netdevs' boot order meets this script arguments pass order.

5. Drives have higher boot priority than netdevs.

## Networking notes

### Tap networking

Requires Tun/Tap kernel extension: `brew install tuntap`. Also, you should run qemu with sudo. Most likely, your
preparation steps should be:

```bash
sudo ./bridge-utils/br-create.sh bridge0
sudo ./bridge-utils/br-add-member en0 bridge0
# Or, the same but simpler:
sudo ./bridge-utils/br-create.sh
sudo ./bridge-utils/br-add-member
```

To remove created bridge:

```bash
sudo ./bridge-utils/br-destroy.sh bridge0
# The same but simpler:
sudo ./bridge-utils/br-destroy.sh
```

Modify [br-add-member.sh](bridge-utils/br-add-member.sh)/[br-rm-member.sh](bridge-utils/br-rm-member.sh) if needed. By
default QEMU-grabbed tapX will be added to the `bridge0`.

**Note:** building QEMU with brew-provided **glib v2.66.7 corrupts tun/tap networking**, the problem is needed to be
investigated. Luckily, everything works fine with glib v2.58.3.

### vmnet.Framework networking

1. Requires sudo
2. This networking type is unstable not and not recommended to use.  
