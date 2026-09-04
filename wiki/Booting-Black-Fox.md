# Booting Black Fox

Black Fox can boot as a hybrid ISO or as a kernel plus squashfs image from an
existing bootloader. The ISO route is usually simplest for a damaged system;
the kernel-and-squashfs route is useful when another Linux installation still
boots.

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

Download the kernel and squashfs image from the release artifacts, or build them
locally with `make kernel squashfs`. Copy both to `/boot`:

```bash
sudo cp out/blackfox /boot/blackfox
sudo cp out/blackfox.sfs /boot/blackfox.sfs
```

### 2.1. GRUB

Add this entry to `/etc/grub.d/40_custom`:

```text
menuentry "Black Fox Recovery" {
	linux  /boot/blackfox root=/dev/ram0 rootfstype=squashfs ramdisk_size=262144 console=ttyS0 console=tty0
	initrd /boot/blackfox.sfs
}
```

Regenerate the menu:

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
# Debian or Ubuntu commonly use:
sudo update-grub
```

The `root=/dev/ram0` and `rootfstype=squashfs` arguments select the squashfs
image as the read-only root. `ramdisk_size=262144` matches the project's default
QEMU/GRUB setting; increase it if the image becomes larger.

### 2.2. QEMU

For a locally built image:

```bash
make run    # graphical QEMU window
make test   # serial console, no graphical window
```

The Makefile passes `out/blackfox` as the kernel and `out/blackfox.sfs` as the
initrd image.

### 2.3. Limine and rEFInd

Other bootloaders need equivalent kernel and initrd entries. Use
`/boot/blackfox` as the kernel, `/boot/blackfox.sfs` as the initrd or initramfs
image, and preserve this command line:

```text
root=/dev/ram0 rootfstype=squashfs ramdisk_size=262144 console=tty0
```

Consult the bootloader's documentation for its entry syntax.

## 3. First boot and shell

PID 1 mounts `/proc`, `/sys`, `/dev`, and `/tmp`, changes to `/admin`, installs
BusyBox applet links, and starts a BusyBox shell. There is no login prompt,
getty, or password because this is a single-user recovery environment.

After boot, check the available tools before modifying a disk:

```bash
busybox --list
lk -w command-name
lk -l /bin
```

Unmount target filesystems before rebooting or removing the recovery media after
all process completed.
