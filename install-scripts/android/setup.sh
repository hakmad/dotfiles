#!/bin/bash

# Setup script for Android (Termux).

# Create downloads directory.
mkdir downloads

# Set up Termux storage.
termux-setup-storage

# Update packages and refresh package database.
pkg upgrade

# Install programs.
pkg install ffmpeg git python vim man openssh termux-api bash-completion

# Install youtube-dl through pip.
pip install yt-dlp

# Create SSH keys.
ssh-keygen

# Clear screen and display SSH key.
clear
cat ~/.ssh/id_ed25519.pub

# Wait until user uploads SSH key to GitHub.
read -p "Upload SSH key to GitHub, then press any key to continue..."

# Clone and push dotfiles.
git clone git@github.com:hakmad/dotfiles ~/.dotfiles

~/.dotfiles/bin/push-dotfiles.sh bash
~/.dotfiles/bin/push-dotfiles.sh bin
~/.dotfiles/bin/push-dotfiles.sh git
~/.dotfiles/bin/push-dotfiles.sh vim

# Setup complete.
echo "Setup complete. Please restart Termux!"
