#!/bin/bash

# Script for setting a Debian based server.

# Basic variables.
HOSTNAME="server"
USER="hakmad"

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
useradd -m -G sudo -s /usr/bin/bash $USER
passwd $USER

# Update packages, refresh package database.
log "Updating..."
apt update
apt upgrade

# Install basic and miscellaneous utilities.
log "Installing basic and miscellaneous utilities..."
apt install --yes vim git man-db acpi tree htop python zip unzip p7zip jq \
	file bash-completion

# Clone dotfiles onto new system and push dotfiles.
log "Cloning dotfiles..."
git clone https://github.com/$USER/dotfiles /home/$USER/.dotfiles

log "Pushing dotfiles..."
su $USER -c "/home/$USER/.dotfiles/bin/push-dotfiles.sh bash"
su $USER -c "/home/$USER/.dotfiles/bin/push-dotfiles.sh bin"
su $USER -c "/home/$USER/.dotfiles/bin/push-dotfiles.sh vim"
su $USER -c "/home/$USER/.dotfiles/bin/push-dotfiles.sh git"

log "Changing ownership of dotfiles..."
chown -R $USER:$USER /home/$USER/.dotfiles

# Change hostname.
log "Changing hostname..."
echo $HOSTNAME >> /etc/hostname

# Setup complete.
log "Setup complete! Please login as $USER. :)"
