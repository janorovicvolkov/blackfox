# Filesystem Support

| Filesystem | Supported? | Note |
|---|---|---|
| `squashfs`             | <p style="color:green">Support</p>          | - |
| `ext4`                 | <p style="color:green">Support</p>          | - |
| `vfat` or `fat32`      | <p style="color:green">Support</p>          | - |
| `btrfs`                | <p style="color:green">Support</p>          | - |
| `xfs`                  | <p style="color:green">Support</p>          | - |
| `ntfs`                 | <p style="color:green">Support</p>          | Kernel driver + bundled `ntfs-3g`, `ntfsfix`, and `ntfsresize` (see [Fixing Disks and Partitions](Fixing-Disks-and-Partitions.md)) |
| `gpt`                  | <p style="color:green">Support</p>          | - |
| `mbr`                  | <p style="color:green">Support</p>          | - |
| `lvm`                  | <p style="color:yellow">Partial Support</p> | Kernel driver only |
| `luks`                 | <p style="color:yellow">Partial Support</p> | Kernel driver and crypto algos only |

So the Black Fox kernel can already read and write `ext4`, `vfat`, `btrfs`, `xfs`
and `ntfs` partitions directly, and it understands GPT or MBR disks and device-mapper
volumes. `ntfs-3g` is also bundled as a userspace fallback for mounting `ntfs` and for
NTFS-specific repair (`ntfsfix`), resize (`ntfsresize`), cloning
(`ntfsclone`), and formatting (`mkntfs` or `mkfs.ntfs`) that the in-kernel
driver alone doesn't provide. What's still missing is the **userspace
tooling** to actually set up or manage LVM volume groups and LUKS
containers (`lvm2` and `cryptsetup`), the kernel is ready for them, the CLI
tools aren't bundled yet.

## Adding userspace tools for LVM or LUKS

See [Extending Tools](../docs/Extending-Tools.md) for the
general static-build recipe. `lvm2` and `cryptsetup` are intentionally *not*
auto-built by the Makefile because both pull in several extra dependencies
(`libdevmapper`, `libpopt`, `json-c`, `libargon2`, ...) that are fragile to
statically link reliably across different build hosts. Building them is a
manual, one-time task per environment rather than something that should
silently succeed or fail inside `make all`.

## Adding a filesystem that isn't listed above

1. Add the relevant config line(s) to `configs/kernel.config`, e.g. for
   ZFS-adjacent or exotic filesystems check the kernel's `make menuconfig`
   under `File systems`.
2. Rebuild the kernel:

```bash
make kernel
```

3. If that filesystem needs userspace tools too (btrfs benefits from
   `btrfs-progs` for advanced operations, though basic mount or repair works
   with just the in-kernel driver), add the static binary to `/bin/others`
   following [Extending Tools](../docs/Extending-Tools.md),
   then:

```bash
make rootfs squashfs iso
```

## Checking a partition's filesystem type (if unsure)

```bash
blkid /dev/sda2
# or
dd if=/dev/sda2 bs=1 skip=1080 count=2 2>/dev/null | xxd   # ext family magic at offset 0x438
```

If `mount -t ext4 /dev/sdaX /mnt` fails with `mount: mounting /dev/sdaX on
/mnt failed: Invalid argument`, that's the classic sign of **the kernel not
having a driver for that filesystem** and not necessarily that the disk itself
is corrupt. Check the table above before assuming the filesystem is damaged.
