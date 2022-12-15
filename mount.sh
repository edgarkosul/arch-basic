#!/bin/bash

mkfs.btrfs -L "Arch Linux" /dev/nvme0n1p4
mount /dev/nvme0n1p4 /mnt
cd /mnt
btrfs subvolume create @
btrfs subvolume create @home
btrfs subvolume create @log
cd
umount /mnt
mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@ /dev/nvme0n1p4 /mnt
mkdir -p /mnt/{boot/efi,home,var/log,win10}
mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@home /dev/nvme0n1p4 /mnt/home
mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@log /dev/nvme0n1p4 /mnt/var/log
mount /dev/nvme0n1p3 /mnt/win10
mount /dev/nvme0n1p1 /mnt/boot/efi

