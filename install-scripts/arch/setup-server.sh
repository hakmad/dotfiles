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

# Function for logging.
log () {
	echo $@
	echo $(date "+%Y/%m/%d %H:%M:%S") $@ >> setup.log
}

# Stop the script if there are errors.
set -e

# Remove old log file.
rm -f setup.log
log "Setup started!"

# Connect to the internet.
log "Starting NetworkManager service..."
sudo systemctl enable --now NetworkManager.service
sleep 5
log "Connecting to the internet..."
sudo nmtui
sleep 5

# Update packages, refresh package database.
log "Updating..."
sudo pacman -Syu --noconfirm

# Set time zone.
log "Setting timezone..."
sudo timedatectl set-timezone Europe/London

# Install fonts.
log "Installing fonts..."
sudo pacman -S --noconfirm terminus-font

# Install SSH server.
sudo pacman -S --noconfirm openssh
sudo systemctl enable sshd.service
sudo systemctl start sshd.service

# Install miscellaneous utilities.
log "Installing miscellaneous utilities..."
sudo pacman -S --noconfirm acpi tree ntfs-3g htop wireless_tools python \
        python-pip texlive-most youtube-dl zip unzip p7zip jq bash-completion

# Install VirtualBox.
log "Installing VirtualBox..."
sudo pacman -S --noconfirm virtualbox virtualbox-host-modules-arch \
        virtualbox-guest-iso
install_aur virtualbox-ext-oracle

# Push dotfiles.
log "Installing dotfiles..."
~/.dotfiles/bin/push-dotfiles.sh bash
~/.dotfiles/bin/push-dotfiles.sh bin
~/.dotfiles/bin/push-dotfiles.sh git
~/.dotfiles/bin/push-dotfiles.sh vim

# Extra things.
# Set /etc/issue to clear, /etc/motd to empty.
clear | sudo tee /etc/issue
echo "" | sudo tee /etc/motd

# Setup complete.
log "Setup complete! Please reboot. :)"
