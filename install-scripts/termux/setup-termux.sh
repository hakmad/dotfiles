#!/bin/bash

# Setup script for Termux (Android).

# Run termux-setup-storage to 
termux-setup-storage

# Upgrade.
pkg upgrade

# Install base packages.
pkg install git man vim python ffmpeg

# Upgrade pip and install youtube-dl.
pip install --upgrade pip
pip install youtube-dl

# Clone dotfiles.
git clone https://github.com/hakmad/dotfiles ~/.dotfiles

# Push dotfiles for bash, bin, git and vim.
~/.dotfiles/bin/push-dotfiles.sh bash
~/.dotfiles/bin/push-dotfiles.sh bin
~/.dotfiles/bin/push-dotfiles.sh git
~/.dotfiles/bin/push-dotfiles.sh vim
