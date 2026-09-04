# Fixing System Manager

Black Fox has **no system manager of its own**. The commands below repair the
installed operating system on the target disk; they do not manage Black Fox.
Prepare the target with [Fixing Initramfs](Fixing-Initramfs.md) first, then run
the target system's `systemctl`, `journalctl`, `rc-service`, or equivalent
commands inside the chroot.

## 1-5: Same as [Fixing Initramfs](Fixing-Initramfs.md)

Check the required tools, identify the target root with `lk -P`, mount it at
`/mnt`, mount any separate `/boot` or EFI partition, bind-mount `/proc`, `/sys`,
and `/dev`, then enter the chroot. Bind `/run` only when the target's manager
needs a live runtime directory; do not confuse Black Fox's shell with the
target's shell after `chroot /mnt`.

Before making changes, save the relevant configuration and record the current
state:

```bash
cp -a /mnt/etc /mnt/etc.blackfox-backup
blkid
cat /mnt/etc/fstab
```

Inside the chroot, confirm that the expected manager and service names exist:

```bash
command -v systemctl || command -v rc-service || command -v sv
cat /etc/os-release
```

If the target uses a different architecture or its dynamic loader is missing,
its commands may not execute in the chroot. In that case repair files from
outside the chroot or use a matching userspace environment.

## 6. Check which units failed

Inside the chroot:

```bash
# If systemd:
systemctl --failed
# runit:
sv status /etc/service/*
# OpenRC:
rc-status --all
```

For a system that is not currently booted, commands that query a running
daemon may fail with a D-Bus or PID 1 error. Use the offline forms where
available, or inspect unit files and logs directly instead of trying to start
services in the rescue environment.

If the target's systemd needs `/run` for runtime state, leave the chroot and
bind the running rescue system's runtime tree before entering it:

```bash
exit
mkdir -p /mnt/run
mount --rbind /run /mnt/run
mount --make-rslave /mnt/run
chroot /mnt /bin/sh
```

Use this only when needed. A bind-mounted `/run` exposes Black Fox runtime
state to the target; it does not start the target's system manager.

## 7. Read logs without a full boot

```bash
journalctl -xb -1                              # previous boot's log
journalctl -u service-name.service --no-pager
```

List available boots and units when the journal exists:

```bash
journalctl --list-boots
systemctl list-unit-files --state=enabled
systemctl list-dependencies default.target
```

If `journalctl` errors out because the journal is corrupt:

```bash
journalctl --verify
```

Or, if the journal is too damaged to salvage, remove it so systemd creates a
fresh one on the next boot (old log data is lost, but the system can boot
again):

```bash
rm -rf /var/log/journal/*
```

## 8. Disable or mask the unit causing the hang

```bash
systemctl disable service-name.service
# or, more forcefully, so it can't be pulled in manually or as a dependency:
systemctl mask service-name.service
```

`mask` is stronger than `disable`, use it when a service keeps getting
pulled back in as another unit's dependency, causing the boot to hang again
even after a plain `disable`.

For an offline target, do not assume Black Fox has the target's `systemctl`
binary or its dynamic libraries. Disable a unit by removing its target-side
enablement symlink, or mask it by replacing the unit name with a symlink to
`/dev/null`:

```bash
rm -f /mnt/etc/systemd/system/multi-user.target.wants/service-name.service
ln -sfn /dev/null /mnt/etc/systemd/system/service-name.service
```

Check the resulting symlinks under `/mnt/etc/systemd/system` before rebooting.

## 9. Restore the correct default boot target

If the system has "wandered" into the wrong boot target (e.g.
`emergency.target` became the default because of a broken config):

```bash
systemctl get-default
systemctl set-default multi-user.target
# or, if a GUI is expected:
systemctl set-default graphical.target
```

For an offline target, inspect or change the `default.target` symlink directly
only when the target's `systemctl --root` support is unavailable:

```bash
readlink -f /mnt/etc/systemd/system/default.target
ln -sfn /lib/systemd/system/multi-user.target /mnt/etc/systemd/system/default.target
```

## 10. Check fstab if the boot hangs on a mount failure

A very common cause of boot dropping into emergency mode: an `/etc/fstab`
entry whose device or UUID is no longer valid (disk was swapped, a partition
was resized, etc.).

```bash
cat /mnt/etc/fstab
lk -P
blkid
```

Edit `/mnt/etc/fstab` (from outside the chroot using a Black Fox, or `vi` inside the chroot
if the target has one), fix the mismatched UUID or device, add `nofail` to the mount options
if that device is actually optional:

```
UUID=xxxx-xxxx  /data  ext4  defaults,nofail  0  2
```

Test the corrected entry before rebooting:

```bash
mount -a
findmnt --verify
```

Do not use `mount -a` for a target filesystem that is already mounted at a
different path. Unmount it first or test the specific mount command.

## 11. Verify and clean up

Before leaving, check that the service is no longer enabled or masked
incorrectly and that the target filesystem is writable:

```bash
systemctl is-enabled service-name.service 2>/dev/null || true
sync
```

Exit the chroot and unmount in reverse order:

```bash
exit
umount -R /mnt/run 2>/dev/null || true
umount -R /mnt/dev 2>/dev/null || true
umount -R /mnt/sys 2>/dev/null || true
umount -R /mnt/proc 2>/dev/null || true
umount /mnt/boot 2>/dev/null || true
umount /mnt
reboot
```

If recursive unmount is unavailable, unmount the bind mounts individually:
`umount /mnt/dev /mnt/sys /mnt/proc /mnt/run`, then unmount `/mnt/boot` and
`/mnt`.
