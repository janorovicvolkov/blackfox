# Fixing Disks and Partitions

## 1. Check the required tools

Because Black Fox is currently bundles `busybox`, `lk`, `e2fsprogs`, `dosfstools`,
`util-linux`, `ntfs-3g`, `testdisk`, and `rsync`. **Always check before following
the steps below:**

```bash
busybox --list
lk -w command-name
which command-name
```

`/bin` should already contain the statically-built recovery tools from all of the
above. Note that `mount`, `umount`, `fdisk`, `sfdisk`, `lsblk`, `blkid`, `findmnt`,
`swapon`, `swapoff`, `mkswap`, `blockdev`, and `fsck` are now using `util-linux`
binaries, not from `busybox`. `busybox` own copies of these (and of `ls`, `mount`,
`umount`, `cp`, `mv`, `rm`, `mkdir`, `chmod`, `chown`, `ln` are now covered by lk) were
removed from the image to avoid two different implementations of the same command. If
`busybox --list` doesn't show one of those, that's expected, use the real one directly.

## 2. Search the target partition layout

```bash
lk -P
```

After found the target, check it with `fdisk`:

```bash
fdisk -l /dev/sda1
```

## 3. Corrupt partition table

Common symptom: `fdisk -l` shows garbled or missing partitions, or the kernel
log says `unknown partition table`.

### 3.1. Restore from a backup (safest if you have one)

```bash
sfdisk /dev/sda < /path/backup-partition-table.txt
```

### 3.2. No backup available (let testdisk cook it)

`testdisk` can scan a disk for filesystem signatures and rebuild a plausible partition
table from what it finds, useful when there's no saved `sfdisk` dump to restore from:

```bash
testdisk /dev/sda
```

It's a menu-driven text UI: pick the disk, let it "Analyse" the disk, and if it finds
partitions that match what you expect, use "Write" to commit a new partition table.
Always double check the proposed layout, this writes to the partition table, image the
disk first (see §8) if you're not sure.

## 4. Corrupt filesystem

`e2fsck` is available by default, this is a genuine improvement over `busybox`
generic `fsck` wrapper, which by itself can't repair `ext4` at all (it just
calls an external `fsck.<type>` binary that doesn't otherwise exist on Black
Fox). The bundled `fsck` (from `util-linux`) is now also the real frontend, so
`fsck /dev/sda2` correctly dispatches to `fsck.ext4` itself if you'd rather
not call `e2fsck` directly.

```bash
lk --umount /dev/sda2 2>/dev/null
e2fsck -f -y /dev/sda2
```

`-y` auto-answers "yes" to every suggested repair (non-interactive, good for
fast recovery but read the output, since heavy corruption can mean some
data loss regardless of the tool used).

For `vfat` or EFI System Partitions:

```bash
lk --umount /dev/sda1 2>/dev/null
fsck.vfat -a /dev/sda1
```

For `ntfs`:

```bash
lk --umount /dev/sda1 2>/dev/null
ntfsfix /dev/sda1
```

`ntfsfix` doesn't do a full filesystem check like `e2fsck` or`fsck.vfat`,
it clears the "dirty" flag Windows sets and fixes some common problems so
Windows will run its own `chkdsk` cleanly on next boot, or so the volume
mounts read-write again. For real bad-sector or deep-corruption analysis,
that has to happen from Windows itself, Black Fox's goal here is just to
get the volume mountable again.

## 5. Resizing a filesystem

```bash
resize2fs /dev/sda2
```

Run this after you've resized the underlying partition (with `fdisk` or
`sfdisk` or from a partition editor on another machine) so the ext4 
filesystem grows or shrinks to match. **Always shrink the filesystem
before shrinking the partition and always grow the partition before
growing the filesystem doing it in the wrong order risks data loss.**

For `ntfs`:

```bash
ntfsresize /dev/sda1
```
 
Run once without `--size` or `--force` first, it does a dry-run check
and reports whether shrinking is safe before actually resizing anything.

## 6. Creating a new filesystem

```bash
mke2fs -t ext4 /dev/sda3     # ext4, with journaling and extents
mkfs.vfat -F 32 /dev/sda4    # FAT32
mkntfs -f /dev/sda5          # NTFS (mkfs.ntfs also works, same binary)
```

## 7. Inspecting filesystem details

```bash
dumpe2fs /dev/sda2      # superblock, inode count, feature flags, etc.
tune2fs -l /dev/sda2    # summarized view, also used to change fs parameters
blkid /dev/sda2         # quick UUID/LABEL/TYPE lookup for any filesystem
```

## 8. Cloning or imaging a disk

```bash
lk -c /mnt/part1 /mnt/part2
```

For a real backup of files (preserving permissions, timestamps, symlinks,
and letting you resume an interrupted copy) rather than a one-shot copy,
`rsync` is usually a better fit than `lk -c`:

```bash
rsync -aAX --info=progress2 /mnt/source/ /mnt/backup/
```

`-a` (archive: recursive + preserves permissions/times/symlinks), `-A`
(ACLs), `-X` (extended attributes). Re-running the same command after an
interruption only transfers what's changed.
 
Always image the disk first if the data matters, there's no "undo" at the
block-device level once you start running repair or resize operations.

## 9. Recovering deleted files or lost partitions
 
If a partition or specific files were deleted rather than corrupted,
`testdisk` (partitions) and `photorec` (individual files, works even
without a valid filesystem) are the tools for it:
 
```bash
testdisk /path/to/disk.img     # or a raw device like /dev/sda
photorec /dev/sda
```
 
`photorec` writes recovered files to wherever you point it (usually a
separate, healthy disk or partition mounted under `/mnt`) rather than back
onto the source disk, never recover onto the same disk you're recovering
from, you'll overwrite the very data you're trying to get back.