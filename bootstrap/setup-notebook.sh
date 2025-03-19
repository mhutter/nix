#!/usr/bin/env bash
set -e -u -o pipefail -x

# Disk to use.
# NOTE: THIS DISK WILL BE WIPED
DISK="/dev/disk/by-id/nvme-SAMSUNG_MZVL21T0HCLR-00BL7_S64PNX0R805055"
BOOT="${DISK}-part1"
LUKS="${DISK}-part2"
CRYPTROOT="/dev/mapper/cryptroot"
# Mountpoint
MNT="/mnt"

# Nuke and partition the disk
blkdiscard -f "$DISK" || :
parted --script --align=optimal "$DISK" -- \
  mklabel gpt \
  mkpart EFI 1MiB 4GiB \
  mkpart primary ext4 4GiB "100%" \
  set 1 esp on

partprobe "$DISK"
lsblk

cryptsetup luksFormat --type luks2 "${LUKS}"
cryptsetup open "${LUKS}" cryptroot

# Create filesystems
mkfs.vfat -n EFI "$BOOT"
mkfs.ext4 -F -L nix -m 0 "${CRYPTROOT}"

# Refresh /dev/disk/by-uuid entries
udevadm trigger
udevadm settle --timeout=5 --exit-if-exists=/dev/disk/by-label/nix

# Mount filesystems
mount -t tmpfs \
  -o defaults,size=25%,mode=755 \
  none "${MNT}"

mount -t vfat \
  -o fmask=0077,dmask=0077,iocharset=iso8859-1,X-mount.mkdir \
  "/dev/disk/by-label/EFI" "${MNT}/boot"

mount -t ext4 \
  -o X-mount.mkdir \
  /dev/disk/by-label/nix "${MNT}/nix"

nixos-generate-config --root "$MNT"


echo nixos-install -j 8 --cores 0 --flake .#tera --no-root-password
echo cp -av . "${MNT}/nix/persist/home/mh/.config/nix"
echo sync
echo umount -Rl /mnt
