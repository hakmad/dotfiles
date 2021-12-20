#!/bin/bash

# Script for setting up a USB with Arch Linux.

set -e

echo "Available devices: "
lsblk -dno path

read -p "Enter device to work on: " DEVICE
read -p "Working on $DEVICE. Are you sure? [Y/n] " CONFIRM

if [[ $CONFIRM != [yY] ]]; then
	echo "Exiting..."
	exit 1
fi

echo "Paritioning $DEVICE with fdisk"
fdisk $DEVICE

echo "Formatting $DEVICE"1" as FAT32..."
mkfs.fat -F 32 $DEVICE"1"

echo "Mounting $DEVICE"1" at /mnt..."
mount $DEVICE"1" /mnt

echo "Formatting $DEVICE"2" as exFAT..."
mkfs.exfat $DEVICE"2"

read -p "Enter URL for Arch Linux ISO: " URL
echo "Downloading Arch Linux ISO..."
curl -o archlinux.iso $URL

echo "Extracting ISO to mount point..."
bsdtar -x -f archlinux.iso -C /mnt

echo "Modifying file system label..."
UUID=$(lsblk -dno UUID $DEVICE"1")
sed -i -E "s/(archisolabel=ARCH_)([0-9]{6})/archisodevice=\/dev\/disk\/by-uuid\/$UUID/" /mnt/loader/entries/*
sed -i -E "s/(archisolabel=ARCH_)([0-9]{6})/archisodevice=\/dev\/disk\/by-uuid\/$UUID/" /mnt/syslinux/archiso_sys-linux.cfg

echo "Unmounting /mnt..."
umount /mnt

echo "Installing syslinux files..."
syslinux --directory syslinux --install $DEVICE"1"
dd bs=440 count=1 conv=notrunc if=/usr/lib/syslinux/bios/mbr.bin of=$DEVICE

echo "Cleaning up..."
rm archlinux.iso

echo "Installation complete!"
