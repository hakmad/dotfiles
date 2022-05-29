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

# Install Caddy.
apt install --yes debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' \
	| gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' \
	| tee /etc/apt/sources.list.d/caddy-stable.list
apt update
apt install caddy

# Clone dotfiles onto new system and push dotfiles.
log "Cloning dotfiles..."
git clone https://github.com/$USER/dotfiles /home/$USER/.dotfiles

log "Changing ownership of dotfiles..."
chown -R $USER:$USER /home/$USER/.dotfiles

log "Pushing dotfiles..."
su $USER -c "/home/$USER/.dotfiles/bin/push-dotfiles.sh bash"
su $USER -c "/home/$USER/.dotfiles/bin/push-dotfiles.sh bin"
su $USER -c "/home/$USER/.dotfiles/bin/push-dotfiles.sh vim"
su $USER -c "/home/$USER/.dotfiles/bin/push-dotfiles.sh git"
su $USER -c "/home/$USER/.dotfiles/bin/push-dotfiles.sh sshd"
su $USER -c "/home/$USER/.dotfiles/bin/push-dotfiles.sh caddy"
su $USER -c "/home/$USER/.dotfiles/bin/push-dotfiles.sh nftables"

# Setup firewall.
log "Setting up firewall..."
su $USER -c "sudo nft -f /etc/nftables.conf"

# Change hostname.
log "Changing hostname..."
echo $HOSTNAME >> /etc/hostname

# Setup complete.
log "Setup complete! Please login as $USER. :)"
