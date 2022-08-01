#!/bin/bash

# Setup script for Android (Termux).

# Set up Termux storage.
termux-setup-storage

# Update packages and refresh package database.
pkg upgrade

# Install programs.
pkg install ffmpeg git python vim man openssh termux-api

# Install youtube-dl through pip.
pip install --upgrade pip
pip install yt-dlp

# Clone and push dotfiles.
git clone git@github.com:hakmad/dotfiles ~/.dotfiles

~/.dotfiles/bin/push-dotfiles.sh bash
~/.dotfiles/bin/push-dotfiles.sh bin
~/.dotfiles/bin/push-dotfiles.sh git
~/.dotfiles/bin/push-dotfiles.sh vim

# Setup complete.
echo "Setup complete. Please restart Termux!"
