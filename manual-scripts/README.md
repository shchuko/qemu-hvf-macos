## Manual VM setup scripts (aka `qemu-system-x86_64` wrappers)

Bash way to create and setup macOS VM

## A couple of required things

- [Patched QEMU](https://github.com/shchuko/qemu/tree/v6.2.0-vmnet-v20-hostosk-v8)

- [Patched UEFI](https://github.com/shchuko/OvmfDarwinPkg)

- [GLib v2.58.3](https://gitlab.gnome.org/GNOME/glib/-/tree/2.58.3) - required only for
  tap-networking. It's fine to use the recent version if tap networking is not needed. Related
  issue can be found [here](https://gitlab.com/qemu-project/qemu/-/issues/335).

- macOS's installation app (ex.`/Applications/Install macOS Catalina.app`)

- XCODE Command Line Tools

- [QEMU build requirements](https://wiki.qemu.org/Hosts/Mac)

## Installation HOWTO

### Part 1: Prepare the environment

There are two ways we can install all the tools and dependencies

1. Install from brew [shchuko/qemu-macguest](https://github.com/shchuko/homebrew-qemu-macguest)
   tap (*Note: glib v2.58.3 won't be installed this way, tap networking won't work*)
    ```bash
    ./prepare-brew.sh
    ```
   This installs tools into HOMEBREW_PREFIX as usual place for Homebrew.

2. Build manually from sources
    ```bash
    ./prepare-src.sh
    ```
   This installs tools into manual-scripts/src-build-scripts/destdir (relatively to repo root).

### Part 2: Start the vm

The simplest way to install macOS is:

```bash
# Firstly, run:
./boot-macos.sh -install-macos "Catalina"
# ... to attach installation media
# The drive to install system onto will be created and attached to VM
# Erase it, create APFS using Disk Utility and start OS installation
# After the reboot and installation finish detach the install media:
./boot-macos.sh
```

Replace 'Catalina' with required OS name to choose the app you wanted,
ex: `/Applications/Install macOS Catalina.app`.

> The script will clone and build QEMU with its GLib dependency,
> retrieve UEFI binaries, create installation media *BaseSystem.cdr*,
> create a drive to install macOS onto, and finally start QEMU VM. Notice that
> [../create-install-img.sh](../create-install-img.sh) being a part of
> [boot-macos.sh](boot-macos.sh) requires sudo privileges!

After everything is done, to boot your guest macOS just run:

```bash
./boot-macos.sh
```

## Attaching devices

Now you can attach QCOW2 and raw disk images:

```bash
./boot-macos.sh -drive-qcow2 /path/to/some/image.qcow2
./boot-macos.sh -drive-raw /path/to/some/image.raw
```

And network devices:

```bash
./boot-macos.sh -net-user # User (slirp) networking
./boot-macos.sh -net-tap # Tap networking - works only with glib 2.58.3 dependency!
./boot-macos.sh -vmnet-shared # vmnet.Framework networking in shared mode (experimental). Requires sudo!
./boot-macos.sh -vmnet-host # vmnet.Framework networking in host mode (experimental). Requires sudo!
./boot-macos.sh -vmnet-bridged enX # vmnet.Framework networking in bridged mode, bridged onto enX (experimental). Requires sudo!
```

Add as many devices as you need:

```bash
./boot-macos.sh -net-user \
  -drive-qcow2 /path/to/some/image.qcow2 \
  -net-tap \
  -drive-raw /path/to/some/image.raw \
  -vmnet-shared 
```

## Boot Order

1. Default drive has the highest boot priority.
    * you can detach this drive by passing `-no-default-drive`:

      ```bash
      ./boot-macos.sh -no-default-drive
      ```
    * you can force to boot from install media by passing `-installmedia-boot`:
      ```bash
      ./boot-macos.sh -install-macos Catalina -installmedia-boot 
      ```
2. Installation media has the next boot priority after default drive.

3. Other drives' boot order meets this script arguments pass order.

4. Attached netdevs' boot order meets this script arguments pass order.

5. Drives have higher boot priority than netdevs.

## Networking notes

### Tap networking

Requires Tun/Tap kernel extension: `brew install tuntap`. Also, you should run qemu with sudo. Most
likely, your preparation steps should be:

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

Modify [br-add-member.sh](bridge-utils/br-add-member.sh)
/[br-rm-member.sh](bridge-utils/br-rm-member.sh) if needed. By default QEMU-grabbed tapX will be
added to the `bridge0`.

**Note:** building QEMU with brew-provided **glib v2.66.7 corrupts tun/tap networking**, the problem
is needed to be investigated. Luckily, everything works fine with glib v2.58.3.

### vmnet.Framework networking

1. Requires sudo
2. This networking type may be unstable.

## Directory content

- [boot-macos.sh](boot-macos.sh) - macOS installation & run script. Run `./boot-macos.sh -help` for
  more information

- [src-build-scripts/*](src-build-scripts) - scripts to download and build tools from sources

- [../create-install-img.sh](../create-install-img.sh) - Install disk image creation script. Requires sudo
  privileges!

- [qemu-system-wrapper.sh](qemu-system-wrapper.sh) - Wrapper for qemu-system-x86_64.
  Run `./qemu-system-wrapper.sh -help` for more information

- [bridge-utils/*](bridge-utils) - simple wrappers for `ifconfig` to operate with network bridges

- [prepare-brew.sh](prepare-brew.sh) - script to install dependencies with brew
  from [shchuko/qemu-macguest](https://github.com/shchuko/homebrew-qemu-macguest) tap

- [prepare-src.sh](prepare-src.sh) - script build dependencies manually 
