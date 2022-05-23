#!/bin/bash

# Script for installing Arch Linux.

# Basic variables.
HOSTNAME="laptop"
USER="hakmad"

# Logging function.
log () {
	echo $@
	echo $(date "+%Y/%m/%d %H:%M%:%S") $@ >> install.log
}

# Stop the script if there are errors.
set -e

# Remove old log file.
rm -f install.log
log "Installation started!"

# Load UK keyboard.
log "Loading UK keyboard..."
loadkeys uk

# Use NTP.
log "Setting NTP..."
timedatectl set-ntp true

# Partition and format /dev/sda.
log "Partitioning /dev/sda..."
fdisk /dev/sda
ESP=$(fdisk /dev/sda -l | awk '/EFI/ {print $1}')
ROOT=$(fdisk /dev/sda -l | awk '/Linux/ {print $1}')
log "Formatting root partition ($ROOT) as ext4..."
mkfs.ext4 $ROOT
if [[ $ROOT == "/dev/sda2" ]]; then
	log "Formatting boot partition ($ESP) as FAT32..."
	mkfs.fat -F 32 $ESP
else
	log "Not formatting boot partition ($ESP), as FAT32, leaving untouched..."
fi

# Mount partitions.
log "Mounting partitions..."
mount $ROOT /mnt
mkdir /mnt/boot
mount $ESP /mnt/boot

# Get mirrorlist.
log "Setting up mirrorlist..."
curl -L https://www.archlinux.org/mirrorlist/?country=GB > \
	/etc/pacman.d/mirrorlist
sed -i "s/^#Server/Server/" /etc/pacman.d/mirrorlist

# Install Arch base onto mountpoint.
log "Installing Arch base..."
pacstrap /mnt base base-devel linux linux-firmware vi vim git man-pages \
	man-db networkmanager

# Generate fstab file.
log "Generating fstab file..."
genfstab -U /mnt >> /mnt/etc/fstab

# Set time zone.
log "Setting timezone..."
arch-chroot /mnt ln -sf /usr/share/Europe/London /etc/localtime

# Generate locales.
sed -i "s/^#en_US.UTF-8/en_US.UTF-8/" /mnt/etc/locale.gen
sed -i "s/^#en_GB.UTF-8/en_GB.UTF-8/" /mnt/etc/locale.gen
log "Generating locales..."
arch-chroot /mnt locale-gen

# Set locales, keyboards and fonts.
echo "LANG=en_US.UTF-8" >> /mnt/etc/locale.conf
echo "KEYMAP=uk" >> /mnt/etc/vconsole.conf
echo "FONT=ter-112n" >> /mnt/etc/vconsole.conf

# Set hostname and hosts.
echo $HOSTNAME >> /mnt/etc/hostname
echo -e "127.0.0.1\tlocalhost" >> /mnt/etc/hosts
echo -e "::1\tlocalhost" >> /mnt/etc/hosts

# Setup users.
log "Setting password for root..."
arch-chroot /mnt passwd
arch-chroot /mnt useradd -m -G wheel $USER
log "Setting password for $USER..."
arch-chroot /mnt passwd $USER
arch-chroot /mnt visudo

# Clone dotfiles onto new system.
arch-chroot /mnt git clone https://github.com/$USER/dotfiles \
	/home/$USER/.dotfiles
arch-chroot /mnt chown -R $USER:$USER /home/$USER/.dotfiles

# Install (temporary) bootloader.
log "Installing bootloader..."
arch-chroot /mnt bootctl install --path=/boot
echo -e "default\tarch.conf" > /mnt/boot/loader/loader.conf
rm -f /mnt/boot/loader/entries/arch.conf
echo -e "title\tArch Linux" >> /mnt/boot/loader/entries/arch.conf
echo -e "linux\t/vmlinuz-linux" >> /mnt/boot/loader/entries/arch.conf
echo -e "initrd\t/initramfs-linux.img" >> /mnt/boot/loader/entries/arch.conf
echo -e "options\troot=$ROOT rw" >> /mnt/boot/loader/entries/arch.conf

# Installation complete.
log "Installation complete! Please reboot. :)"
