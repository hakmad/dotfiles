#!/bin/bash

loadkeys uk

timedatectl set-ntp true

fdisk /dev/sda
ESP=$(fdisk /dev/sda -l | awk '/EFI/ {print $1}')
ROOT=$(fdisk /dev/sda -l | awk '/Linux/ {print $1}')
mkfs.ext4 $ROOT
mount $ROOT /mnt
mkdir /mnt/boot
mount $ESP /mnt/boot

curl -L https://www.archlinux.org/mirrorlist/?country=GB > \
	/etc/pacman.d/mirrorlist
sed -i "s/^#Server/Server/" /etc/pacman.d/mirrorlist

pacstrap /mnt base base-devel linux linux-firmware vi vim git man-pages \
	man-db networkmanager

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt ln -sf /usr/share/Europe/London /etc/localtime

sed -i "s/^#en_US.UTF-8/en_US.UTF-8/" /mnt/etc/locale.gen
sed -i "s/^#en_GB.UTF-8/en_GB.UTF-8/" /mnt/etc/locale.gen
arch-chroot /mnt locale-gen

echo "LANG=en_US.UTF-8" >> /mnt/etc/locale.conf
echo "KEYMAP=uk" >> /mnt/etc/vconsole.conf
echo "FONT=ter-112n" >> /mnt/etc/vconsole.conf

echo "e5450" >> /mnt/etc/hostname
echo -e "127.0.0.1\tlocalhost" >> /mnt/etc/hosts
echo -e "::1\tlocalhost" >> /mnt/etc/hosts

arch-chroot /mnt passwd
arch-chroot /mnt useradd -m -G wheel hakmad
arch-chroot /mnt passwd hakmad
arch-chroot /mnt sed -i "s/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel \
ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers

arch-chroot /mnt git clone https://github.com/hakmad/dotfiles \
	/home/hakmad/.dotfiles
arch-chroot /mnt chown -R hakmad:hakmad /home/hakmad/.dotfiles

arch-chroot /mnt bootctl install --path=/boot
echo -e "default\tarch.conf" > /mnt/boot/loader/loader.conf
echo -e "title\tTemporary" >> /mnt/boot/loader/entries/arch.conf
echo -e "linux\t/vmlinuz-linux" >> /mnt/boot/loader/entries/arch.conf
echo -e "initrd\t/initramfs-linux.img" >> /mnt/boot/loader/entries/arch.conf
echo -e "options\troot=$ROOT rw" >> /mnt/boot/loader/entries/arch.conf
