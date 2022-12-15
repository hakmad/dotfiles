#!/bin/bash

# Script for installing Arch Linux.

# System variables.
HOSTNAME="laptop"
USER="hakmad"
DEVICE="nvme0n1"

# Stop the script if there are errors.
set -e

# Load UK keyboard.
loadkeys uk

# Use NTP.
timedatectl set-ntp true

# Partition device.
fdisk /dev/$DEVICE
ESP=$(fdisk /dev/$DEVICE -l | awk '/EFI/ {print $1}' | tail -n 1)
ROOT=$(fdisk /dev/$DEVICE -l | awk '/Linux/ {print $1}')

# Format device.
mkfs.fat -F 32 $ESP
mkfs.ext4 $ROOT

# Label device.
e2label $ROOT "Arch Linux"

# Mount partitions.
mount $ROOT /mnt
mkdir /mnt/boot
mount $ESP /mnt/boot

# Get mirrorlist.
curl -L https://www.archlinux.org/mirrorlist/?country=GB > /etc/pacman.d/mirrorlist
sed -i "s/^#Server/Server/" /etc/pacman.d/mirrorlist

# Install Arch base onto mountpoint.
pacstrap /mnt base base-devel linux linux-firmware vi vim git man-pages man-db networkmanager

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

# Set hostname and hosts.
echo $HOSTNAME >> /mnt/etc/hostname
echo -e "127.0.0.1\tlocalhost" >> /mnt/etc/hosts
echo -e "::1\tlocalhost" >> /mnt/etc/hosts

# Setup users.
echo "Setting password for root user"
arch-chroot /mnt passwd
arch-chroot /mnt useradd -m -G wheel $USER
echo "Setting password for user $USER"
arch-chroot /mnt passwd $USER
arch-chroot /mnt visudo

# Clone dotfiles onto new system.
arch-chroot /mnt git clone https://github.com/$USER/dotfiles /home/$USER/.dotfiles
arch-chroot /mnt chown -R $USER:$USER /home/$USER/.dotfiles

# Install (temporary) bootloader.
arch-chroot /mnt bootctl install --path=/boot --no-variables
echo -e "default\tarch.conf" > /mnt/boot/loader/loader.conf
rm -f /mnt/boot/loader/entries/arch.conf
echo -e "title\tArch Linux" >> /mnt/boot/loader/entries/arch.conf
echo -e "linux\t/vmlinuz-linux" >> /mnt/boot/loader/entries/arch.conf
echo -e "initrd\t/initramfs-linux.img" >> /mnt/boot/loader/entries/arch.conf
echo -e "options\troot=\"LABEL=Arch Linux\" rw" >> /mnt/boot/loader/entries/arch.conf

# Add new bootloader to UEFI firmware.
efibootmgr --create --disk /dev/$DEVICE --part 1 --label "Linux Boot Manager" --loader "\EFI\systemd\systemd-bootx64.efi"

# Installation complete.
echo "Setup complete. Please reboot!"
