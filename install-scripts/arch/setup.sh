#!/bin/bash

# Setup script for Arch Linux.

# Function for installing packages from the AUR.
install_aur() {
	git clone https://aur.archlinux.org/$1
	cd $1
	makepkg -si --noconfirm
	cd ..
	rm -rf $1
}

# Stop the script if there are errors.
set -e

# Connect to the internet.
sudo systemctl enable --now NetworkManager.service
sleep 5
nmtui
sleep 5

# Update packages, refresh package database.
sudo pacman -Syu --noconfirm

# Set time zone.
sudo timedatectl set-timezone Europe/London

# Install X and video drivers.
sudo pacman -S --noconfirm xorg xorg-xinit xf86-video-intel mesa

# Install audio and setup alsa.
sudo pacman -S --noconfirm alsa alsa-utils alsa-lib pulseaudio \
	pulseaudio-alsa
set +e
sudo alsactl init
set -e

# Install fonts.
sudo pacman -S --noconfirm noto-fonts noto-fonts-extra noto-fonts-emoji \
	noto-fonts-cjk gnu-free-fonts ttf-liberation terminus-font
install_aur terminus-font-ttf

# Install desktop utilities.
sudo pacman -S --noconfirm bspwm sxhkd picom scrot
install_aur dmenu2
install_aur lemonbar-xft-git

# Install desktop applications.
sudo pacman -S --noconfirm alacritty qutebrowser pavucontrol \
        zathura zathura-pdf-mupdf discord mpv feh obs-studio

# Install miscellaneous utilities.
sudo pacman -S --noconfirm acpi tree ntfs-3g htop wireless_tools python \
        python-pip texlive-most youtube-dl zip unzip p7zip slock jq \
	xss-lock bash-completion xsel

# Install utilities.
sudo pacman -S --noconfirm virtualbox virtualbox-host-modules-arch \
        virtualbox-guest-iso
install_aur virtualbox-ext-oracle

# Push dotfiles.
set +e
for package in $(ls ~/.dotfiles); do
	~/.dotfiles/bin/push-dotfiles.sh $package
done
set -e

# Extra things.
# Remove fsck hooks.
sudo sed -i "s/HOOKS=(base udev autodetect modconf block filesystems \
keyboard fsck)/HOOKS=(base udev autodetect modconf block filesystems \
keyboard)/g" /etc/mkinitcpio.conf
sudo pacman -S --noconfirm linux

# Hide kernel messages on the console.
echo "kernel.printk = 3 3 3 3" | sudo tee /etc/sysctl.d/20-quiet-printk.conf

# Set /etc/issue to clear, /etc/motd to empty.
clear | sudo tee /etc/issue
echo "" | sudo tee /etc/motd
