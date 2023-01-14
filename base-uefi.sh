#!/bin/bash

ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc

echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "KEYMAP=ru" >> /etc/vconsole.conf
echo "arch" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 arch.localdomain arch" >> /etc/hosts

pacman -S grub efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools  avahi xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils inetutils dnsutils bluez bluez-utils cups hplip system-config-printer alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack zsh openssh rsync reflector acpi acpi_call tlp virt-manager qemu qemu-arch-extra edk2-ovmf bridge-utils dnsmasq vde2 openbsd-netcat iptables-nft ipset firewalld flatpak sof-firmware nss-mdns acpid ntfs-3g os-prober terminus-font

pacman -S --noconfirm nvidia nvidia-utils nvidia-settings nvidia-prime

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchLinux 

grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable tlp 
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable libvirtd
systemctl enable firewalld
systemctl enable acpid

useradd -m edgar
echo edgar:password | chpasswd
usermod -aG wheel edgar

echo "edgar ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/edgar


printf "Done!"




