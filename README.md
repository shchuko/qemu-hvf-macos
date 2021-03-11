# macOS over QEMU/HVF howto

Examples of running macOS over QEMU on Intel-based Mac hosts with Hypervisor.Framework acceleration (`-accel hvf`)

## A couple of required things

- [Patched QEMU](https://github.com/shchuko/qemu/tree/v5.2.0/darwin-support) (patches are merged into qemu
  master, but not released)

- [Patched UEFI](https://github.com/shchuko/OvmfDarwinPkg)

- [OSK Key retrieval tool](readosk) - required for AppleSMC emulation

- macOS installation app (ex.`/Applications/Install macOS Catalina.app`)

- XCODE Command Line Tools

- [QEMU build requirements](https://wiki.qemu.org/Hosts/Mac)

## Repo content

- [vm-run-install.sh](vm-run-install.sh) - macOS installation & run script. Invokes tools below in correct order

- [readosk](readosk) - OSK Key retrieval tool sources

- [readosk-build.sh](readosk-build.sh) - readosk build script

- [qemu-build.sh](qemu-build.sh) - QEMU clone & build script

- [glib-build.sh](glib-build.sh) - GLib build script

- [get-firmware.sh](get-firmware.sh) - Patched UEFI download & unpack script

- [create-install-img.sh](create-install-img.sh) - Install disk image creation script. Requires sudo privileges!

- [boot.sh](boot.sh) - VM boot script. Run `./boot.sh -help` for more information

- [tap-up.sh](tap-up.sh) - tap interface UP script, adds `tapX` used by VM to `bridge0`

- [tap-down.sh](tap-down.sh) - tap interface DOWN script, , removes `tapX` used by VM from `bridge0`

## Installation HOWTO

The simplest way to install macOS is:

```bash
./vm-run-install.sh -install 
# Or
./vm-run-install.sh -install -os "Catalina"
```

Replace 'Catalina' with required OS name (default is 'Catalina') to choose the app you wanted,
ex: `/Applications/Install macOS Catalina.app`.

> The script will clone and build QEMU with its GLib dependency,
> retrieve UEFI binaries, create installation media *BaseSystem.cdr*, build `readosk` tool, retrieve OSK key, 
> create a drive to install macOS onto, and finally start QEMU VM. Notice that 
> [create-install-img.sh](create-install-img.sh) being a part of [vm-run-install.sh](vm-run-install.sh) requires sudo 
> privileges!

Continue installation there. After it completes, to boot your guest macOS just run:

```bash
./vm-run-install.sh
```

## Networking

### User networking

By default [boot.sh](boot.sh) will run QEMU using `-nic user`. Usage:

```bash
./vm-run-install.sh
# Or 
./boot.sh
```

### Tap networking

Requires Tun/Tap kernel extension that can be
found [here](https://github.com/Tunnelblick/Tunnelblick/tree/master/third_party). To use tap networking run:

```bash
./vm-run-install.sh -tap-net

# Or, manually using boot.sh
./boot.sh -tap -t-up ./tap-up.sh -t-down ./tap-down.sh
```

Modify [tap-up.sh](tap-up.sh)/[tap-down.sh](tap-down.sh) if needed. By default it uses the first available `/dev/tapX`
adding it to `bridge0`. Most likely, your preparation steps should be:

```bash
ifconfig bridge0 create
ifconfig bridge0 addm en0
ifconfig bridge0 up
```

**Note:** building QEMU with glib v2.66.7 **corrupts** tun/tap networking, the problem is needed to be investigated.
Luckily, everything works fine with glib v2.58.3.
