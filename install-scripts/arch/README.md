# Install Scripts

This directory contains installation scripts for making a fresh install of Arch
Linux.

## Pre-installation

To get started, read the Arch Wiki page
[here](https://wiki.archlinux.org/title/Installation_guide) to understand the
installation process and setup a live installation medium.

## Download

To download the main installer script on a live installation medium, run the
following:

```
curl -O https://raw.githubusercontent.com/hakmad/dotfiles/main/install-scripts/arch/install.sh
```

## Install

To begin an installation, run the following:

```
chmod +x install.sh
./install.sh
```

Note: when setting passwords, it is recommended to use simple passwords and
change them at a later stage. This is because the keyboard layout may not
always be set correctly, which can lead to issues with logging in.

## Setup

To setup, reboot the computer, log in, and run the following:

```
~/.dotfiles/install-scripts/arch/setup.sh
```

Optionally, run the following:

```
~/.dotfiles/install-scripts/arch/setup-extra.sh
```

Please note that this may take a while due to the larger sizes of the packages
to install.

## Post-installation

Reboot the computer (again), log in, and extract any backups that might have
been made onto the new machine.
