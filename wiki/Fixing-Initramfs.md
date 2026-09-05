# Fixing Initramfs

## 1. Check the required tools

Because Black Fox currently bundles `busybox`, `lk`, `e2fsprogs`, `dosfstools`,
`util-linux`, `ntfs-3g`, `testdisk`, `rsync`, `ddrescue`, `smartctl`, `mdadm`,
GPT fdisk, and exFAT tools. **Always check before following
the steps below:**

```bash
busybox --list
lk -w command-name
lk -l /bin
```

`/bin` should already contain the statically-built recovery tools from all of the
above. Note that `mount`, `umount`, `fdisk`, `cfdisk`, `sfdisk`, `lsblk`, `blkid`,
`findmnt`, `swapon`, `swapoff`, `mkswap`, `blockdev`, and `fsck` are now using
`util-linux` binaries, not from `busybox`. `busybox` own copies of these (and of `ls`,
`mount`, `umount`, `cp`, `mv`, `rm`, `mkdir`, `chmod`, `chown`, `ln` are now covered
by `lk`) were removed from the image to avoid two different implementations of the
same command. If `busybox --list` doesn't show one of those, that's expected, use
the real one directly.

## 2. Identify the target partition

```bash
# see all detected block devices
lk -P
```

> ***NOTE:** The target's root partition device, e.g. `/dev/sda2`, and its `/boot`
> partition if separate (e.g. `/dev/sda1`). **NOT** the harddisk, e.g. `/dev/sda` or
> `/dev/sdb`*

## 3. Mount the target's root filesystem

```bash
mount /dev/sda2 /mnt ext4
```

If `/boot` is a separate partition:

```bash
mount /dev/sda1 /mnt/boot vfat
```

> ***NOTE:** If the target's filesystem isn't `btrfs`, `ext` (`2`, `3`, `4`), `f2fs`, `ntfs3`, `vfat`,
> `exfat`, or `xfs`, the mount command will fail. See [Supported Filesystems](Supported-Filesystems.md)
> for covered filesystems list.*

## 4. Bind-mount Black Fox's pseudo-filesystems into the target

**This is required**, without it many tools inside the chroot (including
`dracut`, `mkinitcpio`, `grub-install`, etc) will fail because they need
working `/proc`, `/sys`, `/dev` from the currently-running kernel
(Black Fox), not from the target disk.

```bash
mount --bind /proc /mnt/proc
mount --bind /sys  /mnt/sys
mount --bind /dev  /mnt/dev
```

If `mount` doesn't support `--bind` (check with `mount --help`),
use:

```bash
mount -o bind /proc /mnt/proc
mount -o bind /sys  /mnt/sys
mount -o bind /dev  /mnt/dev
```

## 5. Chroot into the target system

```bash
chroot /mnt /bin/bash
```

If the target doesn't have `/bin/bash` or `/bin/sh` (a minimal-based system), use
whatever shell is available on the target:

```bash
chroot /mnt /bin/zsh
```

> ***WARNING:** Once inside the chroot, you're using binaries *belonging
> to the target* (its dynamic linker, its libc, all its tools), not Black
> Fox anymore. If `chroot` fails with `exec format error` or `No such file
> or directory` even though the file clearly exists, this usually means the
> target's CPU architecture differs from Black Fox's build (e.g. target is
> `ARM64` or `aarch64` while Black Fox was built for `x86_64`).*

## 6. Regenerate the initramfs using the target's own tool

Depending on the target distro:

```bash
# Debian or Ubuntu based
update-initramfs -u -k all
# Arch Linux based
mkinitcpio -P
# Fedora, RHEL, or openSUSE based
dracut --force --regenerate-all
# Liska Linux based
lkinit
```

If the tool asks for a kernel version and you're not sure which one is
installed:

```bash
lk -l /mnt/lib/modules
```

## 7. Also repair the bootloader IF needed

If you suspect the problem isn't just the initramfs but GRUB as well:

```bash
grub-install /dev/sda
# Debian or Ubuntu based
update-grub
# Or in other distros
grub-mkconfig -o /boot/grub/grub.cfg
```

## 8. Done, exit, and reboot

```bash
exit
umount /mnt/dev /mnt/sys /mnt/proc /mnt/run 2>/dev/null
umount /mnt
reboot
```

## Common pitfalls

| Symptom | Most likely cause |
|---|---|
| `chroot: failed to run command '/bin/bash': No such file or directory` even though the file exists | Forgot to bind-mount `/proc` or `/dev`, or the target is a different CPU architecture |
| Inside the chroot, `dracut` or `mkinitcpio` can't see any disks | Forgot to bind-mount `/dev` (these tools need live device nodes, not just a static snapshot) |
| After regenerating the initramfs, it still fails to boot | The disk driver (NVMe, LVM, or LUKS) might genuinely be missing from the target's kernel or initramfs config, not an initramfs corruption issue. Check `/mnt/etc/mkinitcpio.conf` or `/mnt/etc/dracut.conf` for included modules |
| `mount: /mnt: wrong fs type` | The target filesystem isn't the one Black Fox kernel currently supports, check [Supported Filesystems](Supported-Filesystems.md) for more information |
