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
sfdisk --delete /dev/$DEVICE
cat << EOF > partition-scheme
label: gpt
device: /dev/$DEVICE
unit: sectors
sector-size: 512

/dev/$DEVICEp1 : start=2048, size=1048576, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B
/dev/$DEVICEp2 : start=1050624, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4
EOF

sfdisk /dev/$DEVICE < partition-scheme
rm partition-scheme

# Get partitions.
ESP=$(fdisk /dev/$DEVICE -l | awk '/EFI/ {print $1}' | tail -n 1)
ROOT=$(fdisk /dev/$DEVICE -l | awk '/Linux/ {print $1}')

# Format device.
mkfs.fat -F 32 $ESP
mkfs.ext4 -F $ROOT

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
pacstrap /mnt base base-devel linux linux-firmware vi vim git man-pages man-db networkmanager efibootmgr acpi

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

# Create users and setup sudoers file.
arch-chroot /mnt useradd -m -G wheel $USER
echo "%wheel ALL=(ALL:ALL) ALL" | EDITOR="tee -a" arch-chroot /mnt visudo

# Clone dotfiles onto new system.
arch-chroot /mnt git clone https://github.com/$USER/dotfiles /home/$USER/.dotfiles
arch-chroot /mnt chown -R $USER:$USER /home/$USER/.dotfiles

# Install (temporary) bootloader.
arch-chroot /mnt bootctl install --path=/boot --no-variables
echo -e "default\tarch.conf" > /mnt/boot/loader/loader.conf
rm -f /mnt/boot/loader/entries/arch.conf
cat > /mnt/boot/loader/entries/arch.conf << EOL
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root="LABEL=Arch Linux" rw
EOL

# Delete old bootloader entry.
efibootmgr --bootnum 0000 -delete-bootnum

# Add new bootloader to UEFI firmware.
efibootmgr --create --disk /dev/$DEVICE --part 1 --label "Linux Boot Manager" --loader "\EFI\systemd\systemd-bootx64.efi"

# Set passwords.
echo "Set password for root user"
arch-chroot /mnt passwd
echo "Set password for user $USER"
arch-chroot /mnt passwd $USER

# Installation complete.
echo "Setup complete. Please reboot!"
