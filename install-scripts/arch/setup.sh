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

# Install X and video drivers.
log "Installing X and video drivers..."
sudo pacman -S --noconfirm xorg xorg-xinit xf86-video-intel xf86-video-fbdev \
	mesa

# Install audio and setup alsa.
log "Installing audio packages..."
sudo pacman -S --noconfirm alsa alsa-utils alsa-lib pulseaudio \
	pulseaudio-alsa
set +e
log "Starting alsa..."
sudo alsactl init
set -e

# Install fonts.
log "Installing fonts..."
sudo pacman -S --noconfirm noto-fonts noto-fonts-extra noto-fonts-emoji \
	noto-fonts-cjk gnu-free-fonts ttf-liberation terminus-font
install_aur terminus-font-ttf

# Install desktop utilities.
log "Installing desktop utilities..."
sudo pacman -S --noconfirm bspwm sxhkd picom scrot
install_aur dmenu2
install_aur lemonbar-xft-git

# Install desktop applications.
log "Installing desktop applications..."
sudo pacman -S --noconfirm alacritty qutebrowser pavucontrol firefox \
	zathura zathura-pdf-mupdf mpv feh obs-studio wireshark-qt keepassxc \
	gimp blender krita syncthing

# Install miscellaneous utilities.
log "Installing miscellaneous utilities..."
sudo pacman -S --noconfirm acpi tree ntfs-3g htop wireless_tools python \
        python-pip texlive-most youtube-dl zip unzip p7zip slock jq \
	xss-lock bash-completion xsel openssh

# Install Java.
log "Installing Java..."
sudo pacman -S --noconfirm jdk-openjdk jre-openjdk openjdk-doc openjdk-src

# Push dotfiles.
log "Pushing dotfiles..."
for package in $(find * -maxdepth 0 -type d -not \( \
	-name install-scripts -o \
	-name caddy \)); do
	~/.dotfiles/bin/push-dotfiles.sh $package
done

# Extra things.
# Remove fsck hooks.
log "Regenerating initial RAM-disk..."
sudo mkinitcpio -p linux

# Hide kernel messages on the console.
echo "kernel.printk = 3 3 3 3" | sudo tee /etc/sysctl.d/20-quiet-printk.conf

# Set /etc/issue to clear, /etc/motd to empty.
clear | sudo tee /etc/issue
echo "" | sudo tee /etc/motd

# Set qutebrowser as the default browser.
xdg-settings set default-web-browser org.qutebrowser.qutebrowser.desktop

# Add user to group wireshark.
sudo gpasswd -a $USER wireshark

# Setup complete.
log "Setup complete! Please reboot. :)"
