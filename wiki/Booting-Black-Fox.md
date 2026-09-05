# Booting Black Fox

Black Fox can boot as a hybrid ISO or as a kernel plus initramfs root image from
an existing bootloader. The ISO route is usually simplest for a damaged system,
the kernel-and-initramfs route is useful when another Linux installation still
boots.

Black Fox is a single-user `busybox`-based recovery environment. The Rust `init`
program is PID 1, mounts `/proc`, `/sys`, `/dev`, and `/tmp`, then starts the
`busybox` shell. It does not use `systemd`, a login manager, or a persistent root
filesystem. The initramfs image is passed as the kernel initrd or root image,
this is not a distro-generated cpio initramfs.

## 1. Boot from ISO (recommended for physical USB or CD)

Download a release ISO, or build one locally with `make iso`. Writing the ISO
overwrites the target device, so identify the device carefully first:

### 1.1. From another Linux computer

```bash
dd if=/path/to/blackfox.iso of=/dev/<your-usb-device> bs=4M status=progress conv=fsync
```

Replace `<your-usb-device>` with the whole target device, such as `/dev/sda` or
`/dev/sdb`, not a partition such as `/dev/sda1`. Check the device first:

```bash
lsblk -o NAME,SIZE,MODEL,TRAN,MOUNTPOINTS
```

Unmount its partitions, write the image, and flush pending writes:

```bash
umount /dev/<your-usb-device-partition> 2>/dev/null || true
dd if=/path/to/blackfox.iso of=/dev/<your-usb-device> bs=4M status=progress conv=fsync
sync
```

The ISO is built with `grub-mkrescue`, so it is a hybrid image suitable for
direct writing to removable media. It includes BIOS and UEFI boot support when
the host GRUB toolchain provides both targets.

### 1.2. Boot the target machine

Select the USB or CD in the firmware boot menu, usually opened with `F12`, `F2`,
`Del`, or `Esc` during POST. If it is not listed, check the firmware's UEFI or
legacy mode and disable Fast Boot temporarily.

### 1.3. From Windows, macOS, or another platform

Use an image-writing tool such as Rufus or balenaEtcher. Select the ISO and the
whole removable device, not an individual partition. Accept the warning that
existing data will be erased and do not format the media after writing it.

## 2. Boot alongside an existing Linux installation

Black Fox can be added alongside an existing Linux installation. The entry
format depends on the bootloader (GRUB, Limine, rEFInd, systemd-boot, etc.).
Download the kernel and initramfs image from the release artifacts, or build
them locally with `make rootfs kernel`. After that, copy both to `/boot`:

```bash
sudo cp out/blackfox /boot/blackfox
sudo cp out/blackfox.img /boot/blackfox.img
```

### 2.1. GRUB

Add this entry to `/etc/grub.d/40_custom`:

```text
menuentry "Black Fox" {
	linux  /boot/blackfox console=ttyS0 console=tty0 gfxpayload=keep
	initrd /boot/blackfox.img
}
```

Regenerate the menu:

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
# Debian or Ubuntu commonly use:
sudo update-grub
```

If `/boot` is a separate filesystem, GRUB may need `/blackfox` and `/blackfox.img`
instead of `/boot/blackfox` and `/boot/blackfox.img`, use the paths visible from GRUB.

### 2.2. systemd-boot

The current kernel configuration enables EFI stub support. Mount the EFI System
Partition and copy the artifacts into it after rebuilding the kernel:

```bash
sudo mkdir -p /boot/EFI/BlackFox
sudo cp out/blackfox /boot/EFI/BlackFox/blackfox.efi
sudo cp out/blackfox.img /boot/EFI/BlackFox/blackfox.img
sudo mkdir -p /boot/loader/entries
```

Create `/boot/loader/entries/blackfox.conf`:

```text
title   Black Fox Recovery
linux   /EFI/BlackFox/blackfox.efi
initrd  /EFI/BlackFox/blackfox.img
options console=ttyS0 console=tty0 gfxpayload=keep
```

The paths in a systemd-boot entry are relative to the EFI System Partition.
Keep the existing Linux loader entries, systemd-boot will show Black Fox as an
additional boot option. If using a separate ESP mount such as `/boot/efi`, copy
the files there and adjust the entry paths relative to that ESP.

### 2.3. Other bootloaders (Limine, rEFInd, etc.)

Other bootloaders need equivalent kernel and initrd entries. Use
`/boot/blackfox` as the kernel, `/boot/blackfox.img` as the initramfs initrd
image, and preserve this command line:

```text
console=ttyS0 console=tty0 gfxpayload=keep
```

Consult the bootloader's documentation for its entry syntax.

## 3. First boot and shell

PID 1 mounts `/proc`, `/sys`, `/dev`, and `/tmp`, changes to `/admin`, installs
BusyBox applet links, and starts a BusyBox shell. There is no login prompt,
getty, or password because this is a single-user recovery environment.

After boot, check the available tools before modifying a disk. BusyBox creates
its own applet symlinks in `/bin`, do not create host absolute symlinks into the
Black Fox root filesystem:

```bash
busybox --list
lk -w command-name
lk -l /bin
```

Unmount target filesystems before rebooting or removing the recovery media after
all process completed.
