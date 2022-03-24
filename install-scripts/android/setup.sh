#!/bin/bash

# Setup script for Android (Termux).

# Function for logging.
log() {
	echo $@
	echo $(date "+%Y/%m/%d %H:%M:%S") $@ >> setup.log
}

# Remove old log file.
rm -f setup.log
log "Setup started!"

# Set up Termux storage.
log "Setting up storage..."
termux-setup-storage

# Update packages and refresh package database.
log "Updating..."
pkg upgrade

# Install programs.
log "Installing utilities..."
pkg install ffmpeg git python vim man

# Install youtube-dl through pip.
log "Installing youtube-dl"
pip install --upgrade pip
pip install youtube-dl

# Clone and push dotfiles.
log "Setting up dotfiles..."
git clone https://github.com/hakmad/dotfiles ~/.dotfiles

~/.dotfiles/bin/push-dotfiles.sh bash
~/.dotfiles/bin/push-dotfiles.sh bin
~/.dotfiles/bin/push-dotfiles.sh git
~/.dotfiles/bin/push-dotfiles.sh vim

# Setup complete.
log "Setup complete! Please restart Termux. :)"
