#!/bin/bash

# Extra setup script for Arch Linux.

# Function for installing packages from the AUR.
install_aur() {
    git clone https://aur.archlinux.org/$1
    cd $1
    makepkg -si --noconfirm
    cd -
    rm -rf $1
}

# Install extra desktop applications.
sudo pacman -S --noconfirm obs-studio shotcut gimp krita blender steam audacity virtualbox virtualbox-guest-utils virtualbox-guest-iso 

# Install additional packages from AUR.
install_aur visual-studio-code-bin
install_aur pandoc-bin

# Install TeX live.
curl -L -O https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar -xf install-tl-unx.tar.gz
rm install-tl-unx.tar.gz
cd install-tl-*
sudo perl ./install-tl 
cd -
rm -rf install-tl-*

# Setup complete.
echo "Additional setup complete. Please reboot!"
