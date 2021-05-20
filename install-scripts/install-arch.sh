#!/bin/bash

# Installer script for Arch Linux.

# Stop the script if there are errors.
set -e

# Some variables which are used in the script.
KEYBOARD="uk"
COUNTRY="GB"
HOSTNAME="e5450"
USERNAME="hakmad"

# Create and clear log.
echo "Installation started at $(date)." > install.log

# Load keyboard layout.
echo "Loading keyboard layout..." >> install.log
loadkeys $KEYBOARD
echo "Done" >> install.log

# Enable network time synchronization.
echo "Enabling network time syncronization..." >> install.log
timedatectl set-ntp true
echo "Done" >> install.log

# Partition /dev/sda.
echo "Paritioning /dev/sda..." >> install.log
fdisk /dev/sda
echo "Done" >> install.log

# Set variables for partitions.
ESP=$(fdisk /dev/sda -l | awk '/EFI/ {print $1}')
ROOT=$(fdisk /dev/sda -l | awk '/Linux/ {print $1}')

# Format root partition as ext4.
echo "Formatting $ROOT as ext4..." >> install.log
mkfs.ext4 $ROOT
echo "Done" >> install.log

# Mount root partition to /mnt and mount ESP to /mnt/boot.
echo "Mounting root partition ($ROOT) to /mnt..." >> install.log
mount $ROOT /mnt
echo "Done" >> install.log
echo "Mounting ESP ($ESP) to /mnt/boot..." >> install.log
mkdir /mnt/boot
mount $ESP /mnt/boot
echo "Done" >> install.log

# Get mirrorlist and rewrite /etc/pacman.d/mirrorlist using it.
echo "Rewriting mirror list..." >> install.log
curl -L https://www.archlinux.org/mirrorlist/?country=$COUNTRY > \
	/etc/pacman.d/mirrorlist
sed -i "s/^#Server/Server/" /etc/pacman.d/mirrorlist
echo "Done" >> install.log

# Install base system along with basic packages.
echo "Installing base system..." >> install.log
pacstrap /mnt base base-devel linux linux-firmware vi vim git man-pages \
	man-db networkmanager
echo "Done" >> install.log

# Generate /etc/fstab for new system.
echo "Generating /etc/fstab..." >> install.log
genfstab -U /mnt >> /mnt/etc/fstab
echo "Done" >> install.log

# Set local time for new system.
echo "Setting /etc/localtime..." >> install.log
arch-chroot /mnt ln -sf /usr/share/Europe/London /etc/localtime
echo "Done" >> install.log

# Generate locales for new system.
echo "Generating new locales..." >> install.log
sed -i "s/^#en_US.UTF-8/en_US.UTF-8/" /mnt/etc/locale.gen
sed -i "s/^#en_$COUNTRY.UTF-8/en_$COUNTRY.UTF-8/" /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo "Done" >> install.log

# Set LANG, KEYMAP and FONT variables for new system.
echo "Setting locale..." >> install.log
echo "LANG=en_US.UTF-8" >> /mnt/etc/locale.conf
echo "Done" >> install.log
echo "Setting keyboard layout..." >> install.log
echo "KEYMAP=$KEYBOARD" >> /mnt/etc/vconsole.conf
echo "Done" >> install.log
echo "Setting console font..." >> install.log
echo "FONT=ter-112n" >> /mnt/etc/vconsole.conf
echo "Done" >> install.log

# Setup hostname and hosts for new system.
echo "Setting /etc/hostname..." >> install.log
echo "$HOSTNAME" >> /mnt/etc/hostname
echo "Done" >> install.log
echo "Setting /etc/hosts..." >> install.log
echo -e "127.0.0.1\tlocalhost" >> /mnt/etc/hosts
echo -e "::1\tlocalhost" >> /mnt/etc/hosts
echo "Done" >> install.log

# Set password for root user.
echo "Setting password for root user..." >> install.log
arch-chroot /mnt passwd
echo "Done" >> install.log

# Add new user and set password for them.
echo "Adding new user $USERNAME..." >> install.log
arch-chroot /mnt useradd -m -G wheel $USERNAME
echo "Done" >> install.log
echo "Setting password for new user $USERNAME..." >> install.log
arch-chroot /mnt passwd $USERNAME
echo "Done" >> install.log

# Edit /etc/sudoers for new system.
echo "Editing /etc/sudoers..." >> install.log
arch-chroot /mnt sed -i "s/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel \
ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers
echo "Done" >> install.log

# Get dotfiles and change their owner.
echo "Getting personal dotfiles..." >> install.log
arch-chroot /mnt git clone https://github.com/hakmad/dotfiles \
	/home/$USERNAME/.dotfiles
arch-chroot /mnt chown -R $USERNAME:$USERNAME /home/$USERNAME/.dotfiles
echo "Done" >> install.log

# Install systemd-boot for new system with temporary boot entries.
echo "Installing systemd-boot..." >> install.log
arch-chroot /mnt bootctl install --path=/boot
echo -e "default\tarch.conf" > /mnt/boot/loader/loader.conf
echo -e "title\tTemporary" >> /mnt/boot/loader/entries/arch.conf
echo -e "linux\t/vmlinuz-linux" >> /mnt/boot/loader/entries/arch.conf
echo -e "initrd\t/initramfs-linux.img" >> /mnt/boot/loader/entries/arch.conf
echo -e "options\troot=$ROOT rw" >> /mnt/boot/loader/entries/arch.conf
echo "Done" >> install.log

# Installation complete.
echo "Installation completed at $(date)." >> install.log
exit 0
