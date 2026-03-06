#!/bin/bash

# Script for installing Arch Linux.

# Colours.
C="\033[1m"
NC="\033[0m"

# Logfile.
install_logfile="install_$(date '+%Y-%m-%d_%H-%M-%S').log"

# Defaults.
hostname="laptop"
user="hakmad"
efi_size="1G"
swap_size="20G"
root_size="100%FREE"
shrink_size="256M"
locale="GB"
keyboard="uk"
timezone="Europe/London" 
packages=(base base-devel linux linux-firmware intel-ucode nvidia-open lvm2 networkmanager man-pages man-db texinfo vim git openssh acpi efibootmgr)

# User set variables (secrets, etc.).
luks_password=""
root_password=""
user_password=""

# Helper function to log something.
log() {
    echo "[$(date '+%Y/%m/%d %T')] $1" >> $install_logfile
}

# Helper function to echo something and log it to the logfile.
echo_log() {
    echo "$1"
    log "$1"
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

set_user_details() {
    echo -e "\n${C}Users${NC}"

    # Ask user for root password.
    root_password=$(set_secret "root password")

    # Ask user for standard user password.
    user_password=$(set_secret "user password")
}

partition_device() {
    echo_log "Partitioning device"
    
    sfdisk --delete /dev/$device >> $install_logfile 2>&1
    cat << EOF > partition-scheme
label: gpt
device: /dev/$device

size=$efi_size, type=uefi
type=lvm
EOF
    
    sfdisk /dev/$device < partition-scheme >> $install_logfile 2>&1
    rm partition-scheme
}

setup_luks() {
    echo_log "Configuring LUKS... "
    
    root_container=$(fdisk /dev/$device -l | awk '/LVM/ {print $1}')
    luks_mapper="cryptlvm"
    cryptsetup luksFormat $root_container <<< $luks_password >> $install_logfile 2>&1
    cryptsetup open $root_container $luks_mapper <<< $luks_password >> $install_logfile 2>&1
}

setup_lvm() {
    echo_log "Configuring LVM... "

    lvm_group="volume"

    pvcreate /dev/mapper/$luks_mapper >> $install_logfile 2>&1

    vgcreate $lvm_group /dev/mapper/$luks_mapper >> $install_logfile 2>&1

    lvcreate -L $efi_size $lvm_group -n swap >> $install_logfile 2>&1
    lvcreate -l $root_size $lvm_group -n root >> $install_logfile 2>&1

    lvreduce -L -$shrink_size $lvm_group/root >> $install_logfile 2>&1
}

format_partitions() { 
    echo_log "Formatting partitions... "

    boot=$(fdisk /dev/$device -l | awk '/EFI/ {print $1}')
    root=/dev/$lvm_group/root
    swap=/dev/$lvm_group/swap

    mkfs.fat -F 32 $boot >> $install_logfile 2>&1

    mkfs.ext4 -F $root >> $install_logfile 2>&1

    mkswap $swap >> $install_logfile 2>&1
}

mount_partitions() {
    echo_log "Mounting partitions... "

    mount $root /mnt >> $install_logfile 2>&1
    mount --mkdir $boot /mnt/boot >> $install_logfile 2>&1
}

enable_swap() {
    echo_log "Enabling swap... "

    swapon $swap >> $install_logfile 2>&1
}

update_keyring() {
    echo_log "Downloading latest keyring... "

    pacman -Sy --noconfirm >> $install_logfile 2>&1
    pacman -S --noconfirm archlinux-keyring >> $install_logfile 2>&1
}

download_mirror_list() {
    echo_log "Downloading mirror list... "
    
    curl -L https://www.archlinux.org/mirrorlist/?country=${locale} > /etc/pacman.d/mirrorlist 2>> $install_logfile
    sed -i "s/^#Server/Server/" /etc/pacman.d/mirrorlist
}

run_pacstrap() {
    echo_log "Installing Arch Linux base... "
    
    pacstrap /mnt ${packages[@]} >> $install_logfile 2>&1
}

generate_fstab() {
    echo_log "Generating fstab file... "
    
    genfstab -U /mnt >> /mnt/etc/fstab
}

setup_timezone() {
    echo_log "Setting timezone... "
    
    arch-chroot /mnt ln -sf /usr/share/${timezone} /etc/localtime >> $install_logfile 2>&1
}

generate_locales(){
    echo_log "Generating locales... "
    
    sed -i "s/^#en_US.UTF-8/en_US.UTF-8/" /mnt/etc/locale.gen
    sed -i "s/^#en_${locale}.UTF-8/en_${locale}.UTF-8/" /mnt/etc/locale.gen
    
    arch-chroot /mnt locale-gen >> $install_logfile 2>&1
    
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
    
    hooks="HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block sd-encrypt lvm2 filesystems fsck)"
    sed -i "s/^HOOKS.*$/${hooks}/g" /mnt/etc/mkinitcpio.conf
    arch-chroot /mnt mkinitcpio -p linux >> $install_logfile 2>&1
}

setup_users() {
    echo_log "Setting up users... "
    
    arch-chroot /mnt useradd -m -G wheel $user >> $install_logfile 2>&1
    
    echo $root_password | arch-chroot /mnt passwd --stdin
    echo $user_password | arch-chroot /mnt passwd $user --stdin
    
    echo "%wheel ALL=(ALL:ALL) ALL" | EDITOR="tee -a" arch-chroot /mnt visudo >> $install_logfile 2>&1
}    

clone_dotfiles() {
    echo_log "Cloning dotfiles... "
    
    arch-chroot /mnt git clone https://github.com/$user/dotfiles /home/$user/.dotfiles >> $install_logfile 2>&1
    arch-chroot /mnt chown -R $user:$user /home/$user/.dotfiles >> $install_logfile 2>&1
}

install_bootloader() {
    echo_log "Installing bootloader... "
    
    while [[ $(efibootmgr | grep "Linux") ]]; do
    	bootnum=$(efibootmgr | grep "Linux" | head -n 1 | cut -d " " -f 1 | tr -d A-Za-z | tr -d "*")
    	efibootmgr --bootnum $bootnum --delete-bootnum >> $install_logfile 2&>1
    done
    
    arch-chroot /mnt bootctl install --path=/boot >> $install_logfile 2>&1
    cat > /mnt/boot/loader/loader.conf << EOL
default	arch
timeout	0
editor  false
auto-entries    false
auto-firmware   false
EOL
    
    uuid=$(blkid $root_container -s UUID -o value)
    
    rm -f /mnt/boot/loader/entries/arch.conf
    cat > /mnt/boot/loader/entries/arch.conf << EOL
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options rd.luks.name=${uuid}=cryptlvm root=/dev/$lvm_group/root rd.luks.options=password-echo=no rw quiet
EOL
    
    efibootmgr -c -d /dev/$device -l "\EFI\systemd\systemd-bootx64.efi" -L "Linux Boot Manager" --u >> $install_logfile 2>&1
}

setup_installation() {
    set_device_settings
    set_luks_settings
    set_user_details
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

main() {
    log "Install script started"

    # Clear the screen and display initial prompt.
    clear

    # Display start up messages
    echo -e "\n${C}Welcome to hakmad's Arch Linux installation script!${NC}\n"

    # Setup installation.
    log "Setting up installation..."
    setup_installation
    log "Installation setup complete"
    
    # Ask user to confirm they want to start the installation.
    echo -e "\n${C}Setup Complete${NC}"
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
