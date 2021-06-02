#!/bin/bash

# Setup script for Arch Linux.

# Stop the script if there are errors.
set -e

install_aur() {
	# Function for installing packages from the AUR
	git clone https://aur.archlinux.org/$1
	cd $1
	makepkg -si --noconfirm
	cd ..
	rm -rf $1
}

# Create and clear log.
echo "Setup started at $(date)." >> setup.log

# Create directories.
echo "Creating directories..." >> setup.log
mkdir -p ~/downloads ~/media/books ~/media/documents \
	~/media/images/screenshots ~/media/music ~/media/usb ~/media/sd \
	~/media/videos ~/workspace
echo "Done." >> setup.log

# Connect to the internet.
echo "Starting NetworkManager service..." >> setup.log
sudo systemctl enable --now NetworkManager.service
echo "Done." >> setup.log
sleep 5
echo "Running nmtui..." >> setup.log
nmtui
sleep 5
echo "Done." >> setup.log

# Update packages and refresh package database.
echo "Updating packages..." >> setup.log
sudo pacman -Syu --noconfirm
echo "Done." >> setup.log

# Set timezone and related information.
echo "Setting timezone..." >> setup.log
sudo timedatectl set-timezone Europe/London
echo "Done." >> setup.log

# Remove fsck hook from /etc/mkinitcpio.conf.
echo "Removing fsck hook from /etc/mkinitcpio.conf..." >> setup.log
sudo sed -i "s/HOOKS=(base udev autodetect modconf block filesystems \
keyboard fsck)/HOOKS=(base udev autodetect modconf block \
filesystems keyboard)/g" /etc/mkinitcpio.conf
echo "Reinstalling linux so changes take effect..." >> setup.log
sudo pacman -S --noconfirm linux
echo "Done." >> setup.log

# Set kernel messages to be hidden from console.
echo "Setting kernel messages to be hidden from console..." >> setup.log
echo "kernel.printk = 3 3 3 3" | sudo tee /etc/sysctl.d/20-quiet-printk.conf
echo "Done." >> setup.log

# Install X and video drivers.
echo "Installing X and video drivers..." >> setup.log
sudo pacman -S --noconfirm xorg xorg-xinit xf86-video-intel mesa
echo "Done." >> setup.log

# Install audio.
echo "Installing audio packages..." >> setup.log
sudo pacman -S --noconfirm alsa alsa-utils alsa-lib pulseaudio pulseaudio-alsa
# Temporary disable failure system because alsactl init fails sometimes.
set +e
sudo alsactl init
# Enable failure system again.
set -e
echo "Done." >> setup.log

# Install WM.
echo "Installing WM..." >> setup.log
sudo pacman -S --noconfirm bspwm
echo "Done." >> setup.log

# Install fonts.
echo "Installing fonts..." >> setup.log
sudo pacman -S --noconfirm noto-fonts noto-fonts-extra noto-fonts-emoji \
	noto-fonts-cjk gnu-free-fonts ttf-liberation terminus-font
install_aur terminus-font-ttf
echo "Done." >> setup.log

# Install desktop utilities.
echo "Installing desktop utilities..." >> setup.log
sudo pacman -S --noconfirm sxhkd picom scrot hsetroot
install_aur dmenu2
install_aur lemonbar-xft-git
echo "Done." >> setup.log

# Install desktop applications.
echo "Installing desktop applications..." >> setup.log
sudo pacman -S --noconfirm qutebrowser firefox zathura zathura-pdf-mupdf \
	discord mpv feh obs-studio blender alacritty
install_aur godot-bin
echo "Done." >> setup.log

# Install utilities/miscellaneous packages.
echo "Installing extra utilities and miscellaneous packages..." >> setup.log
sudo pacman -S --noconfirm acpi tree ntfs-3g htop wireless_tools python \
	python-pip texlive-most youtube-dl zip unzip p7zip cronie slock \
	xss-lock imagemagick
sudo systemctl enable cronie
sudo systemctl start cronie
echo "Done." >> setup.log

# Install VirtualBox.
echo "Installing VirtualBox..." >> setup.log
sudo pacman -S --noconfirm virtualbox virtualbox-host-modules-arch \
	virtualbox-guest-iso
install_aur virtualbox-ext-oracle
echo "Done." >> setup.log

# Push dotfiles to their locations.
echo "Pushing dotfiles..." >> setup.log
# Temporary disable failure system again because I can't be bothered to
# catch README.md and TODO.md from ~/.dotfiles/.
set +e
for package in $(ls ~/.dotfiles); do
	~/.dotfiles/bin/push-dotfiles.sh $package
done
# Enable failure system again.
set -e
echo "Done." >> setup.log

# Do extra stuff.
echo "Setting /etc/motd to null..." >> setup.log
echo "" | sudo tee /etc/motd
echo "Done." >> setup.log
echo "Setting /etc/issue to clear..." >> setup.log
clear | sudo tee /etc/issue
echo "Done." >> setup.log

# Setup complete.
echo "Setup completed at $(date)." >> setup.log
exit 0
