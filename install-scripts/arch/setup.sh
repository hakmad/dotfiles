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
sudo nmtui
sleep 5

# Update packages, refresh package database.
sudo pacman -Syu --noconfirm

# Set time zone.
sudo timedatectl set-timezone Europe/London

# Install X and video drivers.
sudo pacman -S --noconfirm xorg xorg-xinit xf86-video-intel xf86-video-fbdev \
	mesa

# Install audio and setup alsa.
sudo pacman -S --noconfirm alsa-utils alsa-lib pulseaudio \
	pulseaudio-alsa
set +e
sudo alsactl init
set -e

# Install fonts.
sudo pacman -S --noconfirm noto-fonts noto-fonts-extra noto-fonts-emoji \
	noto-fonts-cjk gnu-free-fonts ttf-liberation
install_aur bdf2psf
install_aur cozette-otb
install_aur psf-cozette

# Install desktop utilities.
sudo pacman -S --noconfirm bspwm sxhkd picom scrot slock
install_aur dmenu2
install_aur lemonbar-xft-git

# Install desktop applications.
sudo pacman -S --noconfirm alacritty qutebrowser firefox \
	zathura zathura-pdf-mupdf feh keepassxc syncthing

# Install miscellaneous utilities.
sudo pacman -S --noconfirm acpi tree ntfs-3g htop wireless_tools python \
	python-pip texlive-most youtube-dl zip unzip p7zip jq \
	xss-lock bash-completion xsel xdotool xclip openssh

# Push dotfiles.
cd ~/.dotfiles/
for package in $(find * -maxdepth 0 -type d -not \( \
	-name install-scripts -or
	-name misc \)); do
	~/.dotfiles/bin/push-dotfiles.sh $package
done
cd -

# Extra things.
# Remove fsck hooks.
sudo mkinitcpio -p linux

# Set qutebrowser as the default browser.
xdg-settings set default-web-browser org.qutebrowser.qutebrowser.desktop

# Generate SSH keys for this machine.
ssh-keygen
