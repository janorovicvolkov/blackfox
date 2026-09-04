# Booting Black Fox

## 1. Boot from ISO (recommended for physical USB or CD)

If your bootloader or Black Fox on your system is broken, this option might be the
right choice and only way to do. You can download the latest stable ISO at release then 
install the ISO on your USB or CD device:

### 1.1. If from other Linux computer:

```bash
dd if=/path/to/blackfox.iso of=/dev/<your-usb-or-cd-partition> bs=4M status=progress conv=fsync
```

Replace `<your-usb-or-cd-partition>` with your target USB or CD device like `sda` or
`sdb`, not a partition filesystem (e.g. `sda1`). The ISO is built with `grub-mkrescue`,
so it's a hybrid ISO that can be installed with `dd` directly to a USB stick or CD and still 
boot on BIOS or UEFI.

### 1.2. If from other platfrom (e.g. Windows, MacOS, FreeBSD, Android):

Lorem ipsum

### After write the ISO to the USB or CD....

Boot the target machine from USB or CD, selecting the boot device in the
BIOS or UEFI boot menu (usually `F12`, `F2`, `Del`, or `Esc` during POST,
varies by PC motherboard or laptop).

## 2. Boot alongside with your own Linux (for quick recovery)

If you want to use Black Fox with your own Linux, you must download the latest
stable Black Fox kernel and the squashfs image first in the GitHub release lists
(usually packed in `tar.zst` format). Then configure your `/boot/grub/grub.cfg` if
you using GRUB as bootloader, or other bootloader configuration file to add Black
Fox if can. After that, place the `blackfox` kernel and `blackfox.sfs` at your
`/boot` partition. For example:

### 2.1. If using GRUB:

```bash
root=/dev/ram0 rootfstype=squashfs ramdisk_size=262144 console=ttyS0 console=tty0
```

### 2.2. If using Limine:

Lorem ipsum

### 2.3. If using rEFInd:

Lorem ipsum

## 3. Logging in

There is no login prompt. Black Fox boots straight into a `busybox` or `lk` shell.
No getty and password, because this is a single-user rescue environment by design,
not a multi-user system.
