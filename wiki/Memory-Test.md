# Memory Test with Memtest86+

Black Fox includes the upstream Memtest86+ project for testing physical RAM.
It is separate from the Black Fox recovery environment and runs before Black
Fox starts.

## Start the test

Write the generated ISO to USB, boot it, and select the entry matching the
firmware mode:

- **BIOS:** select `Memtest86+`. GRUB loads `/boot/memtest` with the Linux
  loader.
- **UEFI:** select `Memtest86+`. GRUB chainloads `/boot/memtest.efi` as an EFI
  application.

Do not start the BIOS entry while booted in UEFI mode or the UEFI entry while
booted in legacy BIOS mode. The available entries depend on the mode reported
by GRUB.

## Reading results

Allow at least one complete pass for a quick check. For higher confidence,
run several passes or leave the test running for an extended period. Record the
failing test number, address, and pattern when errors appear. Any repeatable
memory error should be treated as a hardware problem until proven otherwise.

Useful follow-up checks include:

- Test one RAM module at a time.
- Test modules in the motherboard slots recommended by its manual.
- Reseat the modules and check for dust or physical damage.
- Return overclocking, XMP, EXPO, or manually configured timings to defaults.
- Update firmware only after protecting important data and documenting the
  current settings.

Memtest86+ cannot repair RAM. It helps distinguish memory instability from disk,
filesystem, kernel, or initramfs problems.

## UEFI blind mode

On some firmware, Memtest86+ starts but shows no usable display under UEFI.
This is commonly caused by an incomplete or incompatible Graphics Output
Protocol (GOP) mode supplied by the firmware. It does not necessarily mean
that the memory test stopped.

Try the following:

1. Boot the ISO in the firmware's native UEFI display mode.
2. Disable unusual CSM, display, or GPU compatibility settings.
3. Try another monitor output or the integrated GPU if available.
4. Use the BIOS Memtest86+ entry when legacy boot is available.
5. Compare the result with the [UEFI Shell](UEFI-Shell.md) entry. If the shell
   displays normally but Memtest86+ is blind, the issue is specific to
   Memtest86+'s graphics initialization.

See [Troubleshooting Black Fox](Troubleshooting-Black-Fox.md) for broader boot
and firmware diagnostics.
