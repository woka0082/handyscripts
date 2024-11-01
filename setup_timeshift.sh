#!/bin/bash

# Function to check and install a package
check_and_install() {
    if ! pacman -Qi "$1" &> /dev/null; then
        echo "Installing $1..."
        sudo pacman -S --noconfirm "$1"
    else
        echo "$1 is already installed."
    fi
}

# Function to check and enable cronie.service
check_and_enable_cronie() {
    if ! systemctl is-enabled cronie.service &> /dev/null; then
        echo "Enabling and starting cronie.service..."
        sudo systemctl enable cronie.service
        sudo systemctl start cronie.service
    else
        echo "cronie.service is already enabled."
    fi
}

# Check and install required packages
check_and_install timeshift
check_and_install grub-btrfs
check_and_install xorg-xhost
check_and_install inotify-tools

# Check and enable cronie.service so that timeshift can work on schedule
check_and_enable_cronie

# ask the user to run timeshift for the first time and config it. 
echo "Now run timeshift and finish config it. "
echo "then come back to run the second script to enable grub update snapshots"
