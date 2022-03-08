#!/bin/bash

# Script for setting a Debian based server.

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

# Update packages, refresh package database.
log "Updating..."
sudo apt update
sudo apt upgrade

# Install basic and miscellaneous utilities.
log "Installing basic and miscellaneous utilities..."
sudo apt install vim git man-db tree htop python zip unzip p7zip jq \
	bash-completion

# Clone dotfiles onto new system and push dotfiles.
log "Cloning dotfiles..."
git clone https://github.com/hakmad/dotfiles ~/.dotfiles

log "Pushing dotfiles..."
~/.dotfiles/bin/push-dotfiles.sh bash
~/.dotfiles/bin/push-dotfiles.sh bin
~/.dotfiles/bin/push-dotfiles.sh vim
~/.dotfiles/bin/push-dotfiles.sh git

# Setup complete.
log "Setup complete! Please login as hakmad. :)"
