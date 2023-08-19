#!/bin/bash

# Extra setup script for Arch Linux.

# Install extra desktop applications.
sudo pacman -S --noconfirm obs-studio shotcut krita blender mpv

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
