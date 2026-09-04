# <center>Black Fox Wiki</center>

<center><strong>"Operating System Recovery that saves other Operating Systems"</strong></center><br><br>

Black Fox is a minimal recovery operating system that boots fully from RAM.
This wiki explains how to *use* Black Fox to repair systems that fail to
boot Linux distros, broken system manager, corrupt initramfs, disk or 
partition problems, or other things that made you can't boot to your Linux.

> *Looking to build Black Fox itself instead? That's on the [build docs](../docs/Home.md) mate.*

## Table of contents

1. [Booting Black Fox](Booting-Black-Fox.md): Booting from ISO or from your own system
2. [Architecture and Limitations](Architecture-and-Limitations.md): What's inside, what's deliberately left out
3. [Supported Filesystems](Supported-Filesystems.md): What mounts out of the box vs what needs adding
4. [Troubleshooting Black Fox](Troubleshooting-Black-Fox.md): When Black Fox itself fails to boot
5. [Fixing Initramfs](Fixing-Initramfs.md): Dracut, mkinitcpio, or other initramfs tools with chroot
6. [Fixing System Manager](Fixing-System-Manager.md): Masking units, editing config, rescue chroot
7. [Fixing Disks and Partitions](Fixing-Disks-and-Partitions.md): Fdisk, mount, resize, corrupt partition tables

## Core principle (read this first)

Black Fox is **not** a full distro, it's just `busybox`, `lk`, `e2fsprogs`, `dosfstools`,
`util-linux`, `ntfs-3g`, `testdisk`/`photorec`, `rsync`, plus a Rust init. It has **no**
`systemctl`, `journalctl`, `dracut`, `mkinitcpio`, `apt`,
`pacman`, `dpkg`, or other normal Linux distro tool. Every repair against *other* system
is follows the same pattern:

```
1. Boot Black Fox
2. Mount the broken system's partition(s) under "/mnt"
3. Bind-mount Black Fox's "/proc" "/sys" "/dev" into "/mnt"
   (so tools inside the chroot behave like they're running natively)
4. chroot into "/mnt"
5. Inside the chroot, you are using the TARGET SYSTEM'S OWN TOOLS
   (systemctl, dracut, grub-install, etc. Not anything from Black Fox)
6. Exit the chroot, unmount everything, then reboot
```

Black Fox is the *"key that opens the door"*, not always as workshop.
The actual repair work happens with tools that already belong to the
broken system, because Black Fox is intentionally kept small so it
stays fast to boot.