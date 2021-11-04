#!/bin/bash

# Setup script for Android (Termux).

# Set up Termux storage.
termux-setup-storage

# Update packages and refresh package database.
pkg upgrade

# Install programs.
pkg install ffmpeg git python vim 

# Install youtube-dl through pip.
pip install --upgrade pip
pip install youtube-dl

# Clone dotfiles.
git clone https://github.com/hakmad/dotfiles ~/.dotfiles

# Push dotfiles.
~/.dotfiles/bin/push-dotfiles.sh bash
~/.dotfiles/bin/push-dotfiles.sh bin
~/.dotfiles/bin/push-dotfiles.sh git
~/.dotfiles/bin/push-dotfiles.sh vim
