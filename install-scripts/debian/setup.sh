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

# Setup users.
log "Setting password for root..."
passwd

log "Adding new user..."
useradd -m -G sudo -s /usr/bin/bash hakmad
passwd hakmad

# Update packages, refresh package database.
log "Updating..."
apt update
apt upgrade

# Install basic and miscellaneous utilities.
log "Installing basic and miscellaneous utilities..."
apt install vim git man-db tree htop python zip unzip p7zip jq \
	bash-completion

# Clone dotfiles onto new system and push dotfiles.
log "Cloning dotfiles..."
git clone https://github.com/hakmad/dotfiles /home/hakmad/.dotfiles

log "Pushing dotfiles..."
su hakmad -c /home/hakmad/.dotfiles/bin/push-dotfiles.sh bash
su hakmad -c /home/hakmad/.dotfiles/bin/push-dotfiles.sh bin
su hakmad -c /home/hakmad/.dotfiles/bin/push-dotfiles.sh vim
su hakmad -c /home/hakmad/.dotfiles/bin/push-dotfiles.sh git

# Setup complete.
log "Setup complete! Please login as hakmad. :)"
