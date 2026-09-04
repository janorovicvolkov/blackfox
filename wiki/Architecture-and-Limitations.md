# Architecture and Limitations

## What Black Fox HAS

- Linux kernel.
- Static BusyBox. Since this uses `defconfig` (not a hand-picked minimal config),
  most standard BusyBox applets are available. Check the exact list with:
  ```bash
  busybox --list
  ```
  from inside Black Fox shell since the applet set can change if Black Fox updated
  again later.
- A custom `init` (`src/main.rs`, using the `liblk` and `nix` crate) as 
  PID 1, mounts pseudo-filesystems, `chdir` into `/admin`, then `exec` into
  `busybox sh` or `lk --shell` as fallback.
- Static recovery tools in `/bin`, built automatically by `make tools`: e2fsprogs,
  dosfstools, `lk`, util-linux (`fdisk`, `cfdisk`, `mount`, `umount`, `sfdisk`,
  `findmnt`, `blkid`, and filesystem helpers), XFS tools, Btrfs tools, F2FS tools,
  ntfs-3g, testdisk, photorec, and rsync. See also [Fixing Disks and Partitions](Fixing-Disks-and-Partitions.md).
- Directory layout:
```bash
/
/proc
/sys
/dev
/tmp
/lib    # (with "/lib64" → "/lib" symlink)
/bin    # (with "/sbin" → "/bin" symlink)
/mnt
/admin
```
- Kernel filesystem support: **squashfs, ext4, vfat, btrfs, xfs, f2fs, ntfs3**, plus
  GPT and MBR partition table parsing and device-mapper (kernel side). See
  [Supported Filesystems](Supported-Filesystems.md) for the full picture.
- Storage support: ATA or SATA (AHCI) and NVMe, plus loop devices.

## What Black Fox does NOT have

| Missing from Black Fox | Consequence |
|---|---|
| `system managers` | You cannot inspect, enable, or disable a service *from Black Fox directly*, you must chroot into the target system and use its **own** system manager tool (e.g. `systemctl`) |
| `system journals` | You can't read system manager journal logs directly, either read the target's log files manually or chroot and run the target's own journal tools |
| `dracut`, `mkinitcpio`, or `other initramfs tools` | Regenerating an initramfs has to happen **inside a chroot** using the target distro's own tool, Black Fox doesn't ship any of these |
| `package managers` | You can't install anything on Black Fox itself, if you need an extra tool it has to be statically built and baked into `/bin/others` before `make squashfs` (see [Extending Tools](../docs/Extending-Tools.md)) |
| `network driver` | The kernel config doesn't enable NIC drivers yet, if you need network-based recovery (scp'ing files out, etc.), you'll need to add NIC drivers + `CONFIG_INET` to `configs/kernel.config` first |

## Why is it built this way?

Black Fox is intentionally kept as small as possible so it boots fast and
stays compact (good for an emergency USB stick or PXE boot). The philosophy:
**Black Fox is the "key that opens the door"**, not the full workshop, it
just needs to be smart enough to mount a broken disk and get you into a
chroot, the actual repair work uses the tools that already live on the
broken system itself (or the ones you've explicitly added to `/bin/others`).
