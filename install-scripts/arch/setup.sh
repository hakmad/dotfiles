#!/bin/bash

# Script for Arch Linux.

# Colours.
C="\033[1m"
NC="\033[0m"

# Logfile.
setup_logfile="setup_$(date '+%Y-%m-%d_%H-%M-%S').log"

# Variables.
user="hakmad"
user_home="/home/$user"
dotfiles_location="$user_home/.dotfiles"
dotfiles_remote_url="git@github.com:hakmad/dotfiles"
keymap="uk"
timezone="Europe/London"
ssh_type="ed25519"
wifi_ssid=""
wifi_password=""

# Packages.
xorg_packages=(xorg xorg-xinit mesa vulkan-intel)
audio_packages=(alsa-utils alsa-lib pulseaudio pulseaudio-alsa)
font_packages=(noto-fonts noto-fonts-extra noto-fonts-emoji noto-fonts-cjk gnu-free-fonts ttf-liberation)
desktop_utilities=(bspwm sxhkd scrot picom slock xss-lock)
desktop_applications=(emacs alacritty qutebrowser firefox zathura zathura-pdf-mupdf feh mpv keepassxc vlc obs-studio shotcut gimp krita blender steam audacity virtualbox virtualbox-guest-utils virtualbox-guest-iso virtualbox-host-modules-arch wireshark-qt libreoffice-fresh)
misc_utilities=(tree ntfs-3g htop wireless_tools yt-dlp jq bash-completion xclip zip unzip p7zip mediainfo brightnessctl rclone poppler imagemagick)
programming_packages=(python python-pip go)
aur_packages=(dina-font-otb pod2man dmenu2 lemonbar-xft-git visual-studio-code-bin pandoc-bin)

# Helper function to log something.
log() {
    echo "[$(date '+%Y/%m/%d %T')] $1" >> $setup_logfile
}

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

# Helper function for installing packages from the AUR.
install_aur() {
    package=$1

    # Clone the repo.
	runuser -u $user -- git clone https://aur.archlinux.org/$package >> $setup_logfile 2>&1

	cd $package

    # Make package and install.
    runuser -u $user -- makepkg -s --noconfirm >> $setup_logfile 2>&1
    pacman -U $package*.zst --noconfirm >> $setup_logfile 2>&1

	cd - > /dev/null 2>&1
    rm -rf $package
}

check_root() {
    if [[ $(id -u) -ne 0 ]]; then
        echo "Please run this script as root!"
        exit
    fi
}

set_user() {
    echo -e "\n${C}User${NC}"

    read -e -p "Enter username: " -i $user user
}

set_dotfiles() {
    echo -e "\n${C}Dotfiles${NC}"

    read -e -p "Enter dotfiles location: " -i $dotfiles_location dotfiles_location
    read -e -p "Enter dotfiles remote URL: " -i $dotfiles_remote_url dotfiles_remote_url
}

set_locale() {
    echo -e "\n${C}Locale${NC}"

    read -e -p "Enter keymap: " -i $keymap keymap
    read -e -p "Enter timezone: " -i $timezone timezone
}

set_ssh_settings() {
    echo -e "\n${C}SSH Settings${NC}"

    read -e -p "Enter SSH key type: " -i $ssh_type ssh_type
}

set_network() {
    echo -e "\n${C}Network Settings${NC}"

    read -e -p "Enter Wi-Fi network SSID: " wifi_ssid
    wifi_password=$(set_secret "Wi-Fi network password")
}

set_packages() {
    echo -e "\n${C}Packages${NC}"

    # Ask user for packages.
    read -e -a xorg_packages -p "xorg packages to install: " -i "${xorg_packages[*]}"
    read -e -a audio_packages -p "Audio packages to install: " -i "${audio_packages[*]}"
    read -e -a font_packages -p "Font packages to install: " -i "${font_packages[*]}"
    read -e -a desktop_utilities -p "Desktop utilities to install: " -i "${desktop_utilities[*]}"
    read -e -a desktop_applications -p "Desktop applications to install: " -i "${desktop_applications[*]}"
    read -e -a misc_utilities -p "Misc utilities to install: " -i "${misc_utilities[*]}"
    read -e -a programming_packages -p "Programming packages to install: " -i "${programming_packages[*]}"
    read -e -a aur_packages -p "AUR packages to install: " -i "${aur_packages[*]}"
}

show_user() {
    echo -e "\n${C}User${NC}"

    echo -e "\tUser: $user"
}

show_dotfiles() {
    echo -e "\n${C}Dotfiles${NC}"

    echo -e "\tDotfiles location: $dotfiles_location"
    echo -e "\tDotfiles remote URL: $dotfiles_remote_url"
}

show_locale() {
    echo -e "\n${C}Locale${NC}"

    echo -e "\tKeymap: $keymap"
    echo -e "\tTimezone: $timezone"
}

show_ssh_settings() {
    echo -e "\n${C}SSH Settings${NC}"

    echo -e "\tSSH Key Type: $ssh_type"
}

show_network() {
    echo -e "\n${C}Network Settings${NC}"

    echo -e "\tWi-Fi network SSID: $wifi_ssid"
    echo -e "\tWi-Fi network Password: ***"
}

show_packages() {
    echo -e "\n${C}Packages${NC}"

    echo -e "\txorg packages to install: ${xorg_packages[@]}"
    echo -e "\tAudio packages to install: ${audio_packages[@]}" 
    echo -e "\tFont packages to install: ${font_packages[@]}"
    echo -e "\tDesktop utilities to install: ${desktop_utilities[@]}"
    echo -e "\tDesktop applications to install: ${desktop_applications[@]}"
    echo -e "\tMisc utilities to install: ${misc_utilities[@]}"
    echo -e "\tProgramming packages to install: ${programming_packages[@]}"
    echo -e "\tAUR packages to install: ${aur_packages[@]}"
}

connect_to_internet() {
    echo_log "Connecting to the internet..."

    systemctl enable --now NetworkManager.service >> $setup_logfile 2>&1

    sleep 5

    nmcli connection delete "$wifi_ssid" >> $setup_logfile 2>&1
    nmcli device wifi connect "$wifi_ssid" password "$wifi_password" >> $setup_logfile 2>&1

    sleep 5

    ping -c 4 archlinux.org >> $setup_logfile 2>&1

    if [[ $? -ne 0 ]]; then
        echo_log "Could not connect to internet, aborting installation :("
        exit
    fi
}

update_dotfiles_remote() {
    echo_log "Updating dotfiles remote..."

    cd $dotfiles_location

    # Update dotfiles remote.
    git remote set-url origin $dotfiles_remote_url

    cd - > /dev/null 2>&1
}

push_dotfiles() {
    echo_log "Pushing dotfiles..."

    user_dotfiles=$(find $dotfiles_location -mindepth 1 -maxdepth 1 -type d \
        -not \( -name .git -or -name install-scripts \
        -or -name etc -or -name xorg \))

    for dir in $user_dotfiles; do
        package=${dir#$dotfiles_location/}
    	runuser -u $user -- $dotfiles_location/bin/push-dotfiles.sh $package >> $setup_logfile 2>&1
    done

    system_dotfiles=(etc xorg)
    for package in $system_dotfiles; do
        $dotfiles_location/bin/push-dotfiles.sh $package $dotfiles_location >> $setup_logfile 2>&1
    done
}

install_packages() {
    echo_log "Installing packages..."

    echo_log "Updating pacman databases..."
    pacman -Sy >> $setup_logfile 2>&1

    echo_log "Installing xorg packages..."
    pacman -S --noconfirm ${xorg_packages[@]} >> $setup_logfile 2>&1

    echo_log "Installing audio packages..."
    pacman -S --noconfirm ${audio_packages[@]} >> $setup_logfile 2>&1

    echo_log "Installing font packages..."
    pacman -S --noconfirm ${font_packages[@]} >> $setup_logfile 2>&1

    echo_log "Installing desktop utilities..."
    pacman -S --noconfirm ${desktop_utilities[@]} >> $setup_logfile 2>&1

    echo_log "Installing desktop applications..."
    pacman -S --noconfirm ${desktop_applications[@]} >> $setup_logfile 2>&1

    echo_log "Installing misc utilities..."
    pacman -S --noconfirm ${misc_utilities[@]} >> $setup_logfile 2>&1

    echo_log "Installing programming packages..."
    pacman -S --noconfirm ${programming_packages[@]} >> $setup_logfile 2>&1

    echo_log "Installing AUR packages..."
    for package in ${aur_packages[@]}; do
        log "Installing $package from the AUR..."
        install_aur $package
    done
}

setup_misc() {
    echo_log "Running miscellaneous tasks..."
    
    # Set keymap.
    localectl set-keymap uk >> $setup_logfile 2>&1
    
    # Set time zone.
    timedatectl set-timezone $timezone  >> $setup_logfile 2>&1
    
    # Start alsa.
    alsactl init >> $setup_logfile 2>&1
    
    # Add user to groups.
    usermod -a -G video $user >> $setup_logfile 2>&1
    usermod -a -G wireshark $user >> $setup_logfile 2>&1
    
    # Generate SSH keys for this machine.
    rm -rf $user_home/.ssh
    runuser -u $user -- ssh-keygen -q -N '' -t $ssh_type -f $user_home/.ssh/id_$ssh_type >> $setup_logfile 2>&1
    
    # Set qutebrowser as the default browser.
    runuser -u $user -- xdg-settings set default-web-browser org.qutebrowser.qutebrowser.desktop >> $setup_logfile 2>&1
}

setup_setup() {
    set_user
    set_dotfiles
    set_locale
    set_ssh_settings
    set_network
    set_packages
}

show_setup_settings() {
    # Display setup settings.
    clear
    echo -e "\n${C}Setup Summary${NC}\n"

    show_user
    show_dotfiles
    show_locale
    show_ssh_settings
    show_network
    show_packages
    
    echo
}

run_setup() {
    clear

    echo_log "Setup started!"

    connect_to_internet
    update_dotfiles_remote
    push_dotfiles
    install_packages
    setup_misc
}

main() {
    check_root

    log "Setup script started"

    # Clear the screen and display initial prompt.
    clear
    echo -e "${C}Welcome to hakmad's Arch Linux setup script!${NC}\n"

    # Setup setup.
    log "Setting up setup..."
    setup_setup

    # Show setup settings.
    show_setup_settings

    # Ask user to confirm they want to start the setup.
    read -e -p "Start setup? (type 'yes' in capital letters) "
    case $REPLY in
        "YES") ;;
        *) echo_log "Setup aborted :("; exit;;
    esac

    run_setup

    # Setup complete.
    echo_log "Setup complete, please reboot! :)"
}

main
