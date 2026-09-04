# Extending Tools

> *This is build-time documentation, for using Black Fox during an actual
> recovery session see the [wiki](../wiki/Home.md) instead.*

`/bin/others` in the Black Fox rootfs is the where you can drop in extra static
binaries you build by hand (LVM, LUKS, and anything else not covered below).

This page covers how to add tools of your own on top of
those. See [Building](Building.md) for the rest of the build
process.

## What's already automated

```bash
make tools
```

Statically builds and installs into `/bin`:

- `e2fsck`, `fsck.ext4`, `resize2fs`, `mke2fs`, `mkfs.ext4`, `dumpe2fs`, `tune2fs`: From
  `e2fsprogs` (`E2FSPROGS_VERSION` in the `Makefile`, default 1.47.4)
- `fsck.vfat`, `fsck.fat`, `mkfs.vfat`, `mkfs.fat`: from `dosfstools` (`DOSFSTOOLS_VERSION` in the `Makefile`, default 4.2)
- `lk`: A small filesystem or shell CLI from [source-liskalinux/lk](https://github.com/source-liskalinux/lk), built on the same `liblk` crate as Black Fox own `init` (`LK_VERSION` in the `Makefile`, default main). For how to use it during recovery, see the [upstream documentations](https://github.com/source-liskalinux/lk)
> ***NOTE:** `lk` own `--mount` and `--umount` flags are newer than that doc page. This page only covers how it's built.*
- `fox`: A small static terminal editor built from `src/fox.rs`. Open a file with `fox /path/to/file`, use `Ctrl + S` to save, `Ctrl + X` to exit, `Ctrl + W` to search, and `Ctrl + H` to show the shortcut line.
- `losetup`, `blkid`, `fdisk`, `cfdisk`, `sfdisk`, `findmnt`, `swapon`, `swapoff`, `mkswap`, `blockdev`, `fsck`, `mount`, `umount`: From `util-linux` (`UTIL_LINUX_VERSION` in the `Makefile`, default 2.41.2), replacing `busybox` minimal versions of the same commands. `cfdisk` uses the static wide-character ncurses library built by `ncurses-tool` (`NCURSES_VERSION` in the `Makefile`, default 6.5).
- `mkfs.xfs`, `xfs_repair`, `xfs_db`, `xfs_growfs`, `xfs_info`, `xfs_admin`: From `xfsprogs` (`XFSPROGS_VERSION`, default 7.1.1).
- `btrfs`, `mkfs.btrfs`, `fsck.btrfs`: From `btrfs-progs` (`BTRFSPROGS_VERSION`, default 7.1).
- `mkfs.f2fs`, `fsck.f2fs`, `dump.f2fs`, `resize.f2fs`, `sload.f2fs`: From `f2fs-tools` (`F2FS_TOOLS_VERSION`, default 1.16.0).
- `ntfs-3g`, `mount.ntfs`, `mount.ntfs-3g`, `ntfsfix`, `ntfsresize`, `ntfsclone`, `ntfslabel`, `mkntfs`, `mkfs.ntfs`: from `ntfs-3g` (`NTFS3G_VERSION` in the `Makefile`, default 2026.7.7), built with its internal FUSE so there's no libfuse or FUSE-module dependency at runtime.
- `testdisk`, `photorec`: From `testdisk` (`TESTDISK_VERSION` in the `Makefile`, default 7.2).
- `rsync`: From `rsync` (`RSYNC_VERSION` in the `Makefile`, default 3.5.0), built without OpenSSL, lz4, xxHash, or zstd to keep its dependency footprint small.

This runs automatically as part of `make all` or `make rootfs`. You can bump
the versions with:

```bash
make tools E2FSPROGS_VERSION=1.47.2 DOSFSTOOLS_VERSION=4.2 LK_VERSION=v1.0.0 \
    UTIL_LINUX_VERSION=2.41.2 NTFS3G_VERSION=2022.10.3 TESTDISK_VERSION=7.2 RSYNC_VERSION=3.4.1
```

## Why some `busybox` applets are now disabled?

`mount`, `umount`, `cp`, `ls`, `mv`, `rm`, `mkdir`, `chmod`, `chown`, `ln`, `losetup`,
`blkid`, `lsblk`, `fdisk`, `swapon`, `swapoff`, `mkswap`, `blockdev`, and `fsck` used to 
come from `busybox`. Now that `lk` covers the first group (guarded `mount`, `umount`, `cp`,
`ls`, `mv`, `rm`, `mkdir`, `chmod`, `chown`, `ln`) and `util-linux` covers the second (
`fdisk`, `blkid`, `swapon`, `swapoff`, etc.), the `busybox:` `Makefile` target disables
those specific applets in `busybox` `.config` before building it. So there's exactly one
binary providing each command on `$PATH`, not two different implementations shadowing each
other depending on install order. Everything else `busybox` provides (`sh`, `cat`, `vi`,
`grep`, etc.) is untouched. `sfdisk` and `findmnt` were never `busybox` applets to begin
with, they're pure additions from `util-linux`.

> ***GOTCHA:** Because of this, `make rootfs` (and therefore `make all`) depends on `tools`
> running first. If you ever invoke rootfs underlying steps by hand and skip `make tools`,
> you'll end up with no `mount`, `cp`, etc. at all, since `busybox` own copies are compiled
> out. Always build through `make all` or `make rootfs`, not by cherry-picking individual
> sub-targets out of order.*

## Adding a tool that isn't automated (e.g. lvm2, cryptsetup)

### The important rule: the binary MUST be static

Black Fox has no dynamic linker or shared libraries beyond what `busybox`
itself brings (which is static). If you copy a normal dynamically-linked
binary (from `apt install`, or `cargo build` without a musl target), it
**will not run**, instead it will fails with something like:

```
/bin/others/foo: No such file or directory
```

> ***NOTE:** Even though the file clearly exists, that message shows up because the
> dynamic linker path it's looking for `/lib64/ld-linux...` or other lib. It doesn't
> exist on Black Fox by default.*

Always check before copying:

```bash
file tool-binary
# must say "statically linked", NOT "dynamically linked"
ldd tool-binary
# must say "not a dynamic executable"
```

### Example: building `lvm2` statically

```bash
git clone https://sourceware.org/git/lvm2.git
cd lvm2
./configure --enable-static_link
make -j$(nproc)
# resulting binaries typically under tools/ — copy the ones you need
```

`lvm2` links against `libdevmapper`, make sure a static `libdevmapper.a` is
available (either build device-mapper from the same source tree with
`--enable-static_link`, or point `LDFLAGS`/`PKG_CONFIG_PATH` at a static
build) or the static link step will fail.

### Example: building `cryptsetup` statically

```bash
git clone https://gitlab.com/cryptsetup/cryptsetup.git
cd cryptsetup
./autogen.sh
./configure --enable-static --disable-shared \
    LDFLAGS="-static"
make -j$(nproc)
```

`cryptsetup` depends on `libdevmapper`, `libpopt`, `json-c`, and (for
Argon2) `libargon2`. All of these need static `.a` archives available at
link time, which is exactly why this isn't automated in the `Makefile`: the
exact incantation tends to differ per build host or distro.

### Example: building a Rust-based tool statically

Same target as the init binary itself:

```bash
rustup target add x86_64-unknown-linux-musl
cargo build --release --target x86_64-unknown-linux-musl
```

The `lk` `Makefile` target does exactly this (`git clone` + musl build),
for [`lk`](https://github.com/source-liskalinux/lk) see the `Makefile`
`lk-tool:` recipe as a working, copy-pasteable example for wiring up any
other pure-Rust CLI the same way.

### Example: building a C tool with musl-gcc (alternative to glibc `-static`)

Sometimes glibc static linking misbehaves (NSS-dependent functions like
`getpwnam` print link warnings, or bloat the binary). `musl-gcc` is often a
cleaner static-link target:

```bash
CC=musl-gcc ./configure --enable-static
make -j$(nproc)
```

## Wiring a manually-built tool into the image

Add it to the `Makefile` `rootfs:` target, right after the existing
`cp $(OUT_DIR)/tools/* ...` line:

```makefile
	cp /path/to/your/tool $(ROOTFS_DIR)/bin/others/tool
	chmod +x $(ROOTFS_DIR)/bin/others/tool
```

Or, tidier, drop pre-built static binaries into a `tools/` directory in the
project and let the existing loop pick them up, copy them into
`$(OUT_DIR)/tools/` before the `rootfs` target runs, matching the pattern
used by `e2fsprogs-tool` or `dosfstools-tool`.

Then rebuild:

```bash
make rootfs squashfs iso
```

## Check the final image size

```bash
ls -lh out/blackfox.sfs
```

If the size grows significantly, remember to raise `ramdisk_size=` in
`configs/grub.cfg` and/or `RAMDISK_SIZE` for `make run` or `make test` (see
[Booting Black Fox](../wiki/Booting-Black-Fox.md)), otherwise boot will fail
because the file gets truncated while being copied into `/dev/ram0`.

## Good candidates to add for recovery work

| Tool | What it's for | Automated? |
|---|---|---|
| `e2fsprogs`  | `ext4` repair or resize                                                    | <p style="color:green">Yes</p> |
| `dosfstools` | `vfat` or EFI System Partition repair                                      | <p style="color:green">Yes</p> |
| `ntfs-3g`    | `ntfs` mount, repair, resize, clone, and mkfs                              | <p style="color:green">Yes</p> |
| `util-linux` | Providing `fdisk`, `cfdisk`, `sfdisk`, `mount`, `umount`, `findmnt`, `swapon`, `blockdev`, `fsck`, etc. | <p style="color:green">Yes</p> |
| `xfsprogs`   | XFS creation, repair, inspection, and growth                         | <p style="color:green">Yes</p> |
| `btrfs-progs`| Btrfs creation, checking, and administration                         | <p style="color:green">Yes</p> |
| `f2fs-tools` | F2FS creation, checking, dumping, resizing, and loading              | <p style="color:green">Yes</p> |
| `lk`         | Guarded file ops, partition listing, mount or umount, built-in shell       | <p style="color:green">Yes</p> |
| `testdisk`   | Partition table and deleted file recovery                                  | <p style="color:green">Yes</p> |
| `rsync`      | Fast backups before risky operations                                       | <p style="color:green">Yes</p> |
| `lvm2`       | Target uses LVM volume groups                                              | <p style="color:red">No</p> |
| `cryptsetup` | Target uses LUKS full-disk encryption                                      | <p style="color:red">No</p> |
