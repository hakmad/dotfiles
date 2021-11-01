#!/bin/bash

# Script for installing Arch Linux.

# Load UK keyboard.
loadkeys uk

# Use NTP.
timedatectl set-ntp true

# Partition and format /dev/sda.
fdisk /dev/sda
ESP=$(fdisk /dev/sda -l | awk '/EFI/ {print $1}')
ROOT=$(fdisk /dev/sda -l | awk '/Linux/ {print $1}')
mkfs.ext4 $ROOT

# Mount partitions.
mount $ROOT /mnt
mkdir /mnt/boot
mount $ESP /mnt/boot

# Get mirrorlist.
curl -L https://www.archlinux.org/mirrorlist/?country=GB > \
	/etc/pacman.d/mirrorlist
sed -i "s/^#Server/Server/" /etc/pacman.d/mirrorlist

# Install Arch base onto mountpoint.
pacstrap /mnt base base-devel linux linux-firmware vi vim git man-pages \
	man-db networkmanager

# Generate fstab file.
genfstab -U /mnt >> /mnt/etc/fstab

# Set time zone.
arch-chroot /mnt ln -sf /usr/share/Europe/London /etc/localtime

# Generate locales.
sed -i "s/^#en_US.UTF-8/en_US.UTF-8/" /mnt/etc/locale.gen
sed -i "s/^#en_GB.UTF-8/en_GB.UTF-8/" /mnt/etc/locale.gen
arch-chroot /mnt locale-gen

# Set locales, keyboards and fonts.
echo "LANG=en_US.UTF-8" >> /mnt/etc/locale.conf
echo "KEYMAP=uk" >> /mnt/etc/vconsole.conf
echo "FONT=ter-112n" >> /mnt/etc/vconsole.conf

# Set hostname and hosts.
echo "e5450" >> /mnt/etc/hostname
echo -e "127.0.0.1\tlocalhost" >> /mnt/etc/hosts
echo -e "::1\tlocalhost" >> /mnt/etc/hosts

# Setup users.
echo "Setting password for root:"
arch-chroot /mnt passwd
arch-chroot /mnt useradd -m -G wheel hakmad
arch-chroot /mnt passwd hakmad
arch-chroot /mnt sed -i "s/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel \
ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers

# Clone dotfiles onto new system.
arch-chroot /mnt git clone https://github.com/hakmad/dotfiles \
	/home/hakmad/.dotfiles
arch-chroot /mnt chown -R hakmad:hakmad /home/hakmad/.dotfiles

# Install (temporary) bootloader.
arch-chroot /mnt bootctl install --path=/boot
echo -e "default\tarch.conf" > /mnt/boot/loader/loader.conf
echo -e "title\tTemporary" >> /mnt/boot/loader/entries/arch.conf
echo -e "linux\t/vmlinuz-linux" >> /mnt/boot/loader/entries/arch.conf
echo -e "initrd\t/initramfs-linux.img" >> /mnt/boot/loader/entries/arch.conf
echo -e "options\troot=$ROOT rw" >> /mnt/boot/loader/entries/arch.conf
