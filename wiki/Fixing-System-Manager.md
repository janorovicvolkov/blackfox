# Fixing System Manager

Black Fox has **no system manager of its own**, so every `systemctl` or
`journalctl` operation below runs **inside a chroot**, using the binaries
belonging to the broken system (not Black Fox itself).

## 1-5: Same as [Fixing Initramfs](Fixing-Initramfs.md)

Check the required tools, mount the target's root to `/mnt`, bind-mount
`/proc /sys /dev`, then `chroot /mnt`.

## 6. Check which units failed

Inside the chroot:

```bash
# If systemd:
systemctl --failed
# If runit:

# If openrc:

# Or other system manager control tool
```

If the target's systemd is a newer version and needs `/run` mounted too
(some `systemctl` commands need this to work fully):

```bash
mount -t tmpfs tmpfs /run   # from inside the chroot, if /run is empty or unmounted
```

## 7. Read logs without a full boot

```bash
journalctl -xb -1                              # previous boot's log
journalctl -u service-name.service --no-pager
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

## 9. Restore the correct default boot target

If the system has "wandered" into the wrong boot target (e.g.
`emergency.target` became the default because of a broken config):

```bash
systemctl get-default
systemctl set-default multi-user.target
# or, if a GUI is expected:
systemctl set-default graphical.target
```

## 10. Check fstab if the boot hangs on a mount failure

A very common cause of boot dropping into emergency mode: an `/etc/fstab`
entry whose device or UUID is no longer valid (disk was swapped, a partition
was resized, etc.).

```bash
cat /mnt/etc/fstab
lk -P
```

Edit `/mnt/etc/fstab` (from outside the chroot using a Black Fox, or `vi` inside the chroot
if the target has one), fix the mismatched UUID or device, add `nofail` to the mount options
if that device is actually optional:

```
UUID=xxxx-xxxx  /data  ext4  defaults,nofail  0  2
```

## 11. Done, exit, and reboot

```bash
exit
umount /mnt/dev /mnt/sys /mnt/proc /mnt/run 2>/dev/null
lk --umount /mnt
reboot
```
