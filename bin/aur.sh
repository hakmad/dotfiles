#!/bin/bash

# Script for installing packages from the AUR.
#
# The usage of this script is as follows:
#	aur.sh [package]
#
# where [package] is the name of a package in the AUR.

# Stop the script if there are errors.
set -e

# Get the package and download into ~/downloads/ using git.
PACKAGE=$1
git clone https://aur.archlinux.org/$PACKAGE ~/downloads/$PACKAGE

# Install the package.
cd ~/downloads/$PACKAGE
makepkg -si
cd -

# Cleanup afterwards.
rm -rf ~/downloads/$PACKAGE

# Exit.
echo "Successfully installed $PACKAGE from the AUR."
exit 0
