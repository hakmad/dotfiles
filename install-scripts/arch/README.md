# Install Scripts

This directory contains installation scripts for making a fresh install of Arch
Linux.

## Pre-installation

To get started, read the Arch Wiki page
[here](https://wiki.archlinux.org/title/Installation_guide) to understand the
installation process and setup a live installation medium.

### Setup Installation Media

Arch Linux provides a live ISO image which is used to install the OS. The ISO
image can be applied to a USB flash drive; read the Arch Wiki page
[here](https://wiki.archlinux.org/title/USB_flash_installation_medium) for more
details. A USB flash drive is preferable, as they are easier to boot from, are
relatively inexpensive and are readily available.

A copy of the ISO can be found from the [Arch Linux Downloads
page](https://archlinux.org/download/). If on Windows, use
[Rufus](http://rufus.ie/en/) to create a bootable USB drive. If on Linux, make
sure the USB is not mounted before running the following:

```
# cat archlinux.iso > /dev/disk/by-id/usb-USB_flash_drive
```

Note: if following the Linux method, use the path for the USB stick, *not* the
path to a partition (e.g. do not use `/dev/disk/by-id/usb-[UUID]-0:0-part1`,
instead use `/dev/disk/by-id/usb-[UUID]-0:0`).

To use the installation media, ensure that the target device has USB booting
enabled. Boot the device with the USB flash drive plugged in and select the
USB from the boot menu where appliable.

### Connect to the Internet

An installation of Arch Linux requires an active internet connection. The
installation medium comes with a host of utilities to connect to the internet.
If using an Ethernet connection, these utilities should connect automatically.
If using a WiFi connection, use `iwctl` to connect to the internet. `iwctl`
offers an interactive prompt, which can be used to connect to local networks as
follows:

```
$ iwctl
[iwd]# device list # get a list of devices - typically wlan0 is used
[iwd]# station [device] scan # scan for networks
[iwd]# station [device] get-networks # list the networks available
[iwd]# station [device] connect [SSID] # connect to network
```

If necessary, `iwctl` will prompt for a password. Alternatively, the
device, network and password can be provided as command line arguments as
follows:

```
$ iwctl --passphrase [password] station [device] connect [SSID]
```

## Download

To download the main installer script on a live installation medium, run the
following:

```
# curl -O https://raw.githubusercontent.com/hakmad/dotfiles/main/install-scripts/arch/install.sh
```

## Install

To begin an installation, run the following:

```
# chmod +x install.sh
# ./install.sh
```

Note: when setting passwords, it is recommended to use simple passwords and
change them at a later stage. This is because the keyboard layout may not
always be set correctly, which can lead to issues with logging in.

## Setup

To setup, reboot the computer, log in, and run the following:

```
$ sudo ~/.dotfiles/install-scripts/arch/setup.sh
```

Please note that this may take a while due to the larger sizes of the packages
to install.

## Post-installation

Reboot the computer (again), log in, and extract any backups that might have
been made onto the new machine.
