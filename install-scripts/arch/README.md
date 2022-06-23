# Installation Scripts

These directory contains installation scripts for making a fresh install of
Arch Linux.

## Pre-installation

To get started, read the Arch Wiki page
[here](https://wiki.archlinux.org/title/Installation_guide) to understand the
installation process and setup a live installation medium.

## Downloading

To download the main installer script on a live installation medium:

```
curl https://raw.githubusercontent.com/hakmad/dotfiles/main/install-scripts/arch/install.sh
```

## Installation

To begin an installation:

```
chmod +x install.sh
./install.sh
```

## Setup

To setup, reboot the computer, log in, and run the `setup.sh` script:

```
~/.dotfiles/install-scripts/arch/setup.sh
```

## Post-installation

Reboot the computer (again), log in, and extract any backups that might have
been made onto the new machine.
