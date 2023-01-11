#!/bin/bash

mkfs.btrfs -L "Arch Linux" /dev/nvme0n1p4
mount /dev/nvme0n1p4 /mnt
cd /mnt
btrfs subvolume create @
btrfs subvolume create @.snapshots
btrfs subvolume create @home
btrfs subvolume create @log
btrfs subvolume create @pkgs
cd
umount /mnt
mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@ /dev/nvme0n1p4 /mnt
mkdir -p /mnt/{.snapshots,home,var/log,var/cache/pacman/pkg,win10,boot/efi}
mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@.snapshots /dev/nvme0n1p4 /mnt/.snapshots
mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@home /dev/nvme0n1p4 /mnt/home
mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@log /dev/nvme0n1p4 /mnt/var/log
mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@pkgs /dev/nvme0n1p4 /mnt/var/cache/pacman/pkg
mount /dev/nvme0n1p3 /mnt/win10
mount /dev/nvme0n1p1 /mnt/boot/efi

pacstrap /mnt base base-devel linux linux-firmware vim git intel-ucode btrfs-progs
genfstab -U /mnt >> /mnt/etc/fstab