#!/bin/bash

# Script for installing Arch Linux.

# Colours.
C="\033[1m"
NC="\033[0m"

# Defaults.
user="hakmad"
locale="GB"
keyboard="uk"
timezone="Europe/London" 
hostname="laptop" 
ntp=true
packages=(base base-devel linux linux-firmware intel-ucode lvm2 networkmanager man-pages man-db texinfo vim git openssh acpi efibootmgr)

# Setup NTP.
timedatectl set-ntp true

# Clear the screen and display initial prompt.
clear
echo -e "\n${C}Welcome to hakmad's Arch Linux installation script!${NC}\n"

# Ask user to select device.
echo -e "${C}Device Settings${NC}"
while true; do
	echo "Select device to install to: "
	select device in $(lsblk -nd --output NAME); do
		echo "Selected device: /dev/$device"
		break
	done
	read -e -p "Are you sure? (type 'yes' in capital letters) "
	if [[ $REPLY == "YES" ]]; then
		break
	fi
done
read -e -s -p "Enter LUKS password: " luks_password 
while [[ -z $luks_password ]]; do
	read -e -s -p "Enter LUKS password: " luks_password
done

# Ask user for user details.
echo -e "\n${C}User Details${NC}"
read -e -s -p "Enter root password: " root_password
while [[ -z $root_password ]]; do
	read -e -s -p "Enter root password: " root_password
done
read -e -p "Enter username: " -i $user user 
while [[ -z $user_password ]]; do
	read -e -s -p "Enter password for user $user: " user_password
done

# Ask user for locale settings.
echo -e "\n${C}Locale Settings${NC}"
read -e -p "Enter locale: " -i $locale locale 
read -e -p "Enter keyboard layout: " -i $keyboard keyboard 
read -e -p "Enter timezone: " -i $timezone timezone 

# Ask user for network settings.
echo -e "\n${C}Network Settings${NC}"
read -e -p "Enter hostname: " -i $hostname hostname

echo -e "\n${C}Packages${NC}"
read -e -p "Packages to install: " -i "${packages[*]}" packages

echo -e "\n${C}Device Settings${NC}"
echo -e "\tDevice: $device"
echo -e "\tLUKS password: ***"

echo -e "\n${C}User Details${NC}"
echo -e "\tRoot password: ***"
echo -e "\tUser: $user"
echo -e "\tUser password: ***"

echo -e "\n${C}Locale Settings${NC}"
echo -e "\tLocale: $locale"
echo -e "\tKeyboard: $keyboard"

echo -e "\n${C}Network Settings${NC}"
echo -e "\tHostname: $hostname"

echo -e "\n${C}Packages${NC}"
echo -e "\t${packages[*]}\n"

read -e -p "Start installation? (type 'yes' in capital letters) "
case $REPLY in
	"YES") ;;
	*) echo "Installation aborted."; exit;;
esac

clear

rm -f install.log 
echo "Installation started!"

# Partition device.
printf "Partitioning device... "

sfdisk --delete /dev/$device >> install.log 2>&1
cat << EOF > partition-scheme
label: gpt
device: /dev/$device

size=1G, type=uefi
type=lvm
EOF

sfdisk /dev/$device < partition-scheme >> install.log 2>&1
rm partition-scheme
echo "Done!"

# Setup LUKS.
printf "Configuring LUKS... "

root_container=$(fdisk /dev/$device -l | awk '/LVM/ {print $1}')
luks_mapper="cryptlvm"
cryptsetup luksFormat $root_container <<< $luks_password >> install.log 2>&1
cryptsetup open $root_container $luks_mapper <<< $luks_password >> install.log 2>&1

echo "Done!"

# Setup LVM.
printf "Configuring LVM... "

lvm_group="volume"

pvcreate /dev/mapper/$luks_mapper >> install.log 2>&1

vgcreate $lvm_group /dev/mapper/$luks_mapper >> install.log 2>&1

lvcreate -L 20G $lvm_group -n swap >> install.log 2>&1
lvcreate -L 250G $lvm_group -n root >> install.log 2>&1
lvcreate -l 100%FREE $lvm_group -n home >> install.log 2>&1

lvreduce -L -256M $lvm_group/home >> install.log 2>&1

echo "Done!"

# Format partitions.
printf "Formatting partitions... "

boot=$(fdisk /dev/$device -l | awk '/EFI/ {print $1}')
root=/dev/$lvm_group/root
home=/dev/$lvm_group/home
swap=/dev/$lvm_group/swap

mkfs.fat -F 32 $boot >> install.log 2>&1

mkfs.ext4 -F $root >> install.log 2>&1
mkfs.ext4 -F $home >> install.log 2>&1

mkswap $swap >> install.log 2>&1

echo "Done!"

# Mount partitions.
printf "Mounting partitions... "

mount $root /mnt >> install.log 2>&1
mount --mkdir $boot /mnt/boot >> install.log 2>&1
mount --mkdir $home /mnt/home >> install.log 2>&1

echo "Done!"

# Enable swap.
printf "Enabling swap... "

swapon $swap >> install.log 2>&1

echo "Done!"

# Update and add new keyring.
printf "Downloading latest keyring... "

pacman -Sy --noconfirm >> install.log 2>&1
pacman -S --noconfirm archlinux-keyring >> install.log 2>&1

echo "Done!"

# Get mirrorlist.
printf "Downloading mirror list... "

curl -L https://www.archlinux.org/mirrorlist/?country=${locale} > /etc/pacman.d/mirrorlist 2>> install.log
sed -i "s/^#Server/Server/" /etc/pacman.d/mirrorlist

echo "Done!"

read -e -p "Continue? (type 'yes' in capital letters) "
case $REPLY in
	"YES") ;;
	*) echo "Installation aborted."; exit;;
esac

# Install Arch base onto mountpoint.
printf "Installing Arch Linux base... "

pacstrap /mnt ${packages[*]} >> install.log 2>&1

echo "Done!"

# Generate fstab file.
printf "Generating fstab file... "

genfstab -U /mnt >> /mnt/etc/fstab

echo "Done!"

# Set time zone.
printf "Setting timezone... "

arch-chroot /mnt ln -sf /usr/share/${timezone} /etc/localtime >> install.log 2>&1

echo "Done!"

# Generate locales.
printf "Generating locales... "

sed -i "s/^#en_US.UTF-8/en_US.UTF-8/" /mnt/etc/locale.gen
sed -i "s/^#en_${locale}.UTF-8/en_${locale}.UTF-8/" /mnt/etc/locale.gen

arch-chroot /mnt locale-gen >> install.log 2>&1

echo "LANG=en_US.UTF-8" >> /mnt/etc/locale.conf
echo "KEYMAP=$keyboard" >> /mnt/etc/vconsole.conf

echo "Done!"

# Set hostname and hosts.
printf "Setting hostname and hosts... "

echo $hostname >> /mnt/etc/hostname
echo -e "127.0.0.1\tlocalhost" >> /mnt/etc/hosts
echo -e "::1\tlocalhost" >> /mnt/etc/hosts

echo "Done!"

# Regenerate initramfs.
printf "Regenerating initramfs..."

hooks="HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt lvm2 filesystems fsck)"
sed -i "s/^HOOKS.*$/${hooks}/g" /mnt/etc/mkinitcpio.conf
arch-chroot /mnt mkinitcpio -p linux >> install.log 2>&1

echo "Done!"

# Create users, set passwords and setup sudoers file.
printf "Setting up users... "

arch-chroot /mnt useradd -m -G wheel $user >> install.log 2>&1

echo $root_password | arch-chroot /mnt passwd --stdin
echo $user_password | arch-chroot /mnt passwd $user --stdin

echo "%wheel ALL=(ALL:ALL) ALL" | EDITOR="tee -a" arch-chroot /mnt visudo >> install.log 2>&1

echo "Done!"

# Clone dotfiles onto new system.
printf "Cloning dotfiles... "

arch-chroot /mnt git clone https://github.com/$user/dotfiles /home/$user/.dotfiles >> install.log 2>&1
arch-chroot /mnt chown -R $user:$user /home/$user/.dotfiles >> install.log 2>&1

echo "Done!"

# Install bootloader.
printf "Installing bootloader... "

while [[ $(efibootmgr | grep "Linux") ]]; do
	bootnum=$(efibootmgr | grep "Linux" | head -n 1 | cut -d " " -f 1 | tr -d A-Za-z | tr -d "*")
	efibootmgr --bootnum $bootnum --delete-bootnum >> install.log 2&>1
done

arch-chroot /mnt bootctl install --path=/boot >> install.log 2>&1
cat > /mnt/boot/loader/loader.conf << EOL
default	arch
timeout	10
EOL

uuid=$(blkid $root_container -s UUID -o value)

rm -f /mnt/boot/loader/entries/arch.conf
cat > /mnt/boot/loader/entries/arch.conf << EOL
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options cryptdevice=UUID=${uuid}:cryptlvm root=/dev/$lvm_group/root rw
EOL

efibootmgr -c -d /dev/$device -l "\EFI\systemd\systemd-bootx64.efi" -L "Linux Boot Manager" --u >> install.log 2>&1

# Installation complete.
echo "Installation complete. Please reboot! :)"
