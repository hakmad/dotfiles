#!/bin/bash

# Script for installing Arch Linux.

# Colours.
C="\033[1m"
NC="\033[0m"

# Logfile.
install_logfile="install_$(date '+%Y-%m-%d_%H-%M-%S').log"

# Defaults.
efi_size="1G"
swap_size="20G"
root_size="250G"
home_size="100%FREE"
user="hakmad"
locale="GB"
keyboard="uk"
timezone="Europe/London" 
hostname="laptop" 
ntp=true
packages=(base base-devel linux linux-firmware intel-ucode lvm2 networkmanager man-pages man-db texinfo vim git openssh acpi efibootmgr)

# Secrets.
luks_password=""
root_password=""
user_password=""

# Helper function to echo something and log it to the logfile.
echo_log() {
    echo "$1"
    log "$1"
}

# Helper function to log something.
log () {
    echo "[$(date '+%Y/%m/%d %T')] $1" >> $install_logfile
}

# Helper function for setting secrets (e.g. passwords).
set_secret() {
    description=$1

    # Loop until user has created a password with at least one character
    # and confirmed it by entering it twice.
    while true; do
        if [[ -z $secret ]]; then
            read -e -s -p "Enter $description: " secret 
        else
            read -e -s -p "Re-enter $description: " confirm_secret 
        
            if [[ $secret == $confirm_secret ]]; then
                echo $secret
                break
            else
                echo "$description does not match!" >&2
                secret=""
            fi
        fi
    done
}

set_device_settings() {
    echo -e "${C}Device Settings${NC}"

    # Loop until user is satisfied with device (and made sure!).
    while true; do
        # Select a device.
    	echo "Select device to install to: "
    	select device in $(lsblk -nd --output NAME); do
    		echo "Selected device: /dev/$device"
    		break
    	done

        # Ask user to confirm choice.
    	read -e -p "Are you sure? (type 'yes' in capital letters) "
    	if [[ $REPLY == "YES" ]]; then
    		break
    	fi
    done
}

set_luks_settings() {
    echo -e "\n${C}LUKS Settings${NC}"

    # Ask user for LUKS password.
    luks_password=$(set_secret "LUKS password")
}

set_partition_layout() {
    echo -e "\n${C}Partition Layout${NC}"

    # Loop until user is satisfied with layout.
    while true; do
        # Display layout.
        echo -e "This script installs Arch Linux with the following partition layout:\n"
        echo -e "EFI\tLVM/LUKS"
        echo -e ":swap:root:home\n$efi_size:$swap_size:$root_size:$home_size" | column -t -s ":"
        echo

        # Ask user to confirm.
        read -e -p "Use this layout? (Y/n) " -i "y"
        case $REPLY in
            [Nn]*)
                # Ask user to set new partition sizes.
                read -e -p "Enter EFI partition size: " -i $efi_size efi_size
                read -e -p "Enter swap partition size: " -i $swap_size swap_size
                read -e -p "Enter root partition size: " -i $root_size root_size
                read -e -p "Enter home partition size: " -i $home_size home_size
                break
                ;;
            [Yy]*)
                break
                ;;
            *)
                ;;
        esac
    done
}

set_user_details() {
    echo -e "\n${C}Users${NC}"

    # Ask user for root password.
    root_password=$(set_secret "root password")

    # Ask user for standard user details.
    read -e -p "Enter username: " -i $user user 
    user_password=$(set_secret "user password")
}

set_locale_settings() {
    echo -e "\n${C}Locale Settings${NC}"

    # Ask user for locale settings.
    read -e -p "Enter locale: " -i $locale locale 
    read -e -p "Enter keyboard layout: " -i $keyboard keyboard 
    read -e -p "Enter timezone: " -i $timezone timezone 
}

set_network_settings() {
    echo -e "\n${C}Network Settings${NC}"

    # Ask user for network settings.
    read -e -p "Enter hostname: " -i $hostname hostname
}

set_packages() {
    echo -e "\n${C}Packages${NC}"

    # Ask user for packages.
    read -e -p "Packages to install: " -i "${packages[*]}" packages
}

show_device_settings() {
    echo -e "\n${C}Device Settings${NC}"
    echo -e "\tDevice: $device"
}

show_luks_settings() {
    echo -e "\n${C}LUKS Settings${NC}"
    echo -e "\tLUKS password: ***"
}

show_partition_layout() {
    echo -e "\n${C}Partition Layout${NC}"
    echo -e "\tEFI\tLVM/LUKS"
    echo -e "\t:swap:root:home\n\t$efi_size:$swap_size:$root_size:$home_size" | column -t -s ":"
}

show_user_details() {
    echo -e "\n${C}User Details${NC}"
    echo -e "\tRoot password: ***"
    echo -e "\tUser: $user"
    echo -e "\tUser password: ***"
}

show_locale_settings() {
    echo -e "\n${C}Locale Settings${NC}"
    echo -e "\tLocale: $locale"
    echo -e "\tKeyboard: $keyboard"
}

show_network_settings() {
    echo -e "\n${C}Network Settings${NC}"
    echo -e "\tHostname: $hostname"
}

show_packages() {
    echo -e "\n${C}Packages${NC}"
    echo -e "\t${packages}\n"
}
j
partition_device() {
    echo_log "Partitioning device"
    
    sfdisk --delete /dev/$device >> install.log 2>&1
    cat << EOF > partition-scheme
label: gpt
device: /dev/$device

size=1G, type=uefi
type=lvm
EOF
    
    sfdisk /dev/$device < partition-scheme >> $install_logfile 2>&1
    rm partition-scheme
}

setup_luks() {
    echo_log "Configuring LUKS... "
    
    root_container=$(fdisk /dev/$device -l | awk '/LVM/ {print $1}')
    luks_mapper="cryptlvm"
    cryptsetup luksFormat $root_container <<< $luks_password >> install.log 2>&1
    cryptsetup open $root_container $luks_mapper <<< $luks_password >> install.log 2>&1
}

setup_lvm() {
    echo_log "Configuring LVM... "

    lvm_group="volume"

    pvcreate /dev/mapper/$luks_mapper >> install.log 2>&1

    vgcreate $lvm_group /dev/mapper/$luks_mapper >> install.log 2>&1

    lvcreate -L 20G $lvm_group -n swap >> install.log 2>&1
    lvcreate -L 250G $lvm_group -n root >> install.log 2>&1
    lvcreate -l 100%FREE $lvm_group -n home >> install.log 2>&1

    lvreduce -L -256M $lvm_group/home >> install.log 2>&1
}

format_partitions() { 
    echo_log "Formatting partitions... "

    boot=$(fdisk /dev/$device -l | awk '/EFI/ {print $1}')
    root=/dev/$lvm_group/root
    home=/dev/$lvm_group/home
    swap=/dev/$lvm_group/swap

    mkfs.fat -F 32 $boot >> install.log 2>&1

    mkfs.ext4 -F $root >> install.log 2>&1
    mkfs.ext4 -F $home >> install.log 2>&1

    mkswap $swap >> install.log 2>&1
}

mount_partitions() {
    echo_log "Mounting partitions... "

    mount $root /mnt >> install.log 2>&1
    mount --mkdir $boot /mnt/boot >> install.log 2>&1
    mount --mkdir $home /mnt/home >> install.log 2>&1
}

enable_swap() {
    echo_log "Enabling swap... "

    swapon $swap >> install.log 2>&1
}

update_keyring() {
    echo_log "Downloading latest keyring... "

    pacman -Sy --noconfirm >> install.log 2>&1
    pacman -S --noconfirm archlinux-keyring >> install.log 2>&1
}

download_mirror_list() {
    echo_log "Downloading mirror list... "
    
    curl -L https://www.archlinux.org/mirrorlist/?country=${locale} > /etc/pacman.d/mirrorlist 2>> install.log
    sed -i "s/^#Server/Server/" /etc/pacman.d/mirrorlist
}

run_pacstrap() {
    echo_log "Installing Arch Linux base... "
    
    pacstrap /mnt ${packages[*]} >> install.log 2>&1
}

generate_fstab() {
    echo_log "Generating fstab file... "
    
    genfstab -U /mnt >> /mnt/etc/fstab
}

setup_timezone() {
    echo_log "Setting timezone... "
    
    arch-chroot /mnt ln -sf /usr/share/${timezone} /etc/localtime >> install.log 2>&1
}

generate_locales(){
    echo_log "Generating locales... "
    
    sed -i "s/^#en_US.UTF-8/en_US.UTF-8/" /mnt/etc/locale.gen
    sed -i "s/^#en_${locale}.UTF-8/en_${locale}.UTF-8/" /mnt/etc/locale.gen
    
    arch-chroot /mnt locale-gen >> install.log 2>&1
    
    echo "LANG=en_US.UTF-8" >> /mnt/etc/locale.conf
    echo "KEYMAP=$keyboard" >> /mnt/etc/vconsole.conf
}

setup_hostname() {
    echo_log "Setting hostname and hosts... "
    
    echo $hostname >> /mnt/etc/hostname
    echo -e "127.0.0.1\tlocalhost" >> /mnt/etc/hosts
    echo -e "::1\tlocalhost" >> /mnt/etc/hosts
}

regenerate_initramfs() {
    echo_log "Regenerating initramfs..."
    
    hooks="HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt lvm2 filesystems fsck)"
    sed -i "s/^HOOKS.*$/${hooks}/g" /mnt/etc/mkinitcpio.conf
    arch-chroot /mnt mkinitcpio -p linux >> install.log 2>&1
}

setup_users() {
    echo_log "Setting up users... "
    
    arch-chroot /mnt useradd -m -G wheel $user >> install.log 2>&1
    
    echo $root_password | arch-chroot /mnt passwd --stdin
    echo $user_password | arch-chroot /mnt passwd $user --stdin
    
    echo "%wheel ALL=(ALL:ALL) ALL" | EDITOR="tee -a" arch-chroot /mnt visudo >> install.log 2>&1
}    

clone_dotfiles() {
    echo_log "Cloning dotfiles... "
    
    arch-chroot /mnt git clone https://github.com/$user/dotfiles /home/$user/.dotfiles >> install.log 2>&1
    arch-chroot /mnt chown -R $user:$user /home/$user/.dotfiles >> install.log 2>&1
}

install_bootloader() {
    echo_log "Installing bootloader... "
    
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
}

setup_installation() {
    set_device_settings
    set_luks_settings
    set_partition_layout
    set_user_details
    set_locale_settings
    set_network_settings
    set_packages
}

show_installation_settings() {
    # Display installation settings.
    clear
    echo -e "\n${C}Installation Summary${NC}\n"

    # Display individual sections.
    show_device_settings
    show_luks_settings
    show_partition_layout
    show_user_details
    show_locale_settings
    show_network_settings
    show_packages

    # Print newline.
    echo 
}

run_installation() {
    # Clear the screen.
    clear

    echo_log "Installation started!"

    partition_device
    setup_luks
    setup_lvm
    format_partitions
    mount_partitions
    enable_swap
    update_keyring
    download_mirror_list

    read -e -p "Continue? (type 'yes' in capital letters) "
    case $REPLY in
    	"YES") ;;
    	*) echo_log "Installation aborted :("; exit;;
    esac

    run_pacstrap
    generate_fstab
    setup_timezone
    generate_locales
    setup_hostname
    regenerate_initramfs
    setup_users
    clone_dotfiles
    install_bootloader
}

main () {
    log "Install script started"

    # Clear the screen and display initial prompt.
    clear

    # Display start up messages
    echo -e "\n${C}Welcome to hakmad's Arch Linux installation script!${NC}\n"

    # Setup installation.
    log "Setting up installation..."
    setup_installation
    log "Installation setup complete"
    
    # Show installation settings.
    show_installation_settings

    # Ask user to confirm they want to start the installation.
    read -e -p "Start installation? (type 'yes' in capital letters) "
    case $REPLY in
    	"YES") ;;
    	*) echo_log "Installation aborted :("; exit;;
    esac

    run_installation

    # Installation complete.
    echo_log "Installation complete, please reboot! :)"
}

main
