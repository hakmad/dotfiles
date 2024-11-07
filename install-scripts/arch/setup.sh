#!/bin/bash

# Setup script for Arch Linux.

# Function for installing packages from the AUR.
install_aur() {
	git clone https://aur.archlinux.org/$1
	cd $1
	makepkg -si --noconfirm --skipinteg
	cd -
	rm -rf $1
}

# Stop the script if there are errors.
set -e

# Push dotfiles.
DOTFILES_LOCATION="$HOME/.dotfiles"

for package in $(find $DOTFILES_LOCATION -mindepth 1 -maxdepth 1 -type d \
	-not \( -name .git \
	-or -name install-scripts \
	-or -name wallpaper \
	-or -name misc \)); do
	echo $package
	$HOME/.dotfiles/bin/push-dotfiles.sh ${package#$DOTFILES_LOCATION/}
done

for package in $(find $DOTFILES_LOCATION/misc -mindepth 1 -maxdepth 1 -type d); do
	$HOME/.dotfiles/bin/push-dotfiles.sh ${package#$DOTFILES_LOCATION/}
done

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
sudo pacman -S --noconfirm xorg xorg-xinit mesa vulkan-intel

# Install audio and setup alsa.
sudo pacman -S --noconfirm alsa-utils alsa-lib pulseaudio pulseaudio-alsa
set +e
sudo alsactl init
set -e

# Install fonts.
sudo pacman -S --noconfirm noto-fonts noto-fonts-extra noto-fonts-emoji noto-fonts-cjk gnu-free-fonts ttf-liberation
install_aur dina-font-otb

# Install desktop utilities.
sudo pacman -S --noconfirm bspwm sxhkd scrot picom slock xss-lock
install_aur pod2man
install_aur dmenu2
install_aur lemonbar-xft-git

# Install desktop applications.
sudo pacman -S --noconfirm alacritty qutebrowser firefox zathura zathura-pdf-mupdf feh keepassxc syncthing

# Install miscellaneous utilities.
sudo pacman -S --noconfirm acpi tree ntfs-3g htop wireless_tools yt-dlp jq bash-completion xsel xdotool xclip openssh
install_aur light

# Install programming languages.
sudo pacman -S --noconfirm python python-pip go

# Extra things.
# Add user to light group.
sudo usermod -a -G video $USER

# Remove fsck hooks.
sudo mkinitcpio -p linux

# Generate SSH keys for this machine.
ssh-keygen

# Set qutebrowser as the default browser.
xdg-settings set default-web-browser org.qutebrowser.qutebrowser.desktop

# Setup complete.
echo "Setup complete. Please reboot!"
