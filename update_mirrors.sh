#!/bin/bash

# Check if pacman is installed
if ! command -v pacman &> /dev/null; then
    echo "Pacman is not installed. Aborting."
    exit 1
fi

# Part 2: Backup and configure pacman for improved performance
PACMAN_CONF="/etc/pacman.conf"
PACMAN_CONF_BAK="/etc/pacman.conf.bak"

# Backup pacman.conf if not already backed up
if [ ! -f "$PACMAN_CONF_BAK" ]; then
    echo "Backing up the original pacman.conf to pacman.conf.bak..."
    sudo cp $PACMAN_CONF $PACMAN_CONF_BAK
fi

echo "Configuring pacman settings..."

# Append settings to pacman.conf if they do not already exist
sudo sed -i '/Color/!s/#Color/Color/' $PACMAN_CONF
sudo sed -i '/VerbosePkgLists/!s/#VerbosePkgLists/VerbosePkgLists/' $PACMAN_CONF
sudo sed -i '/ParallelDownloads/!s/#ParallelDownloads/ParallelDownloads = 5/' $PACMAN_CONF
sudo sed -i '/ILoveCandy/!s/#ILoveCandy/ILoveCandy/' $PACMAN_CONF

echo "Pacman configuration updated."

# Part 3: Get user preferences for reflector
read -p "Enter the country or countries (comma-separated) for mirrors (leave blank for worldwide): " country
read -p "Enter the number of mirrors to use (suggested 5-30): " num_mirrors

# Validate number of mirrors
if ! [[ $num_mirrors =~ ^[0-9]+$ ]] || [ "$num_mirrors" -lt 5 ] || [ "$num_mirrors" -gt 30 ]; then
    echo "Invalid input. Setting number of mirrors to 15."
    num_mirrors=15
fi

# Part 4: Install reflector
if ! pacman -Qi reflector &> /dev/null; then
    echo "Installing reflector..."
    sudo pacman -Syu --noconfirm reflector
fi

# Start reflector service
sudo systemctl start reflector.service

# Part 5: Enable reflector timer and update reflector configuration
sudo systemctl enable reflector.timer
REFLECTOR_CONF="/etc/xdg/reflector/reflector.conf"
echo "Configuring reflector with the selected parameters..."

# Update reflector.conf with user settings, including --save option
if [ -n "$country" ]; then
    echo "--country $country" | sudo tee $REFLECTOR_CONF > /dev/null
else
    echo "# No specific country selected; using worldwide mirrors" | sudo tee $REFLECTOR_CONF > /dev/null
fi
echo "--latest $num_mirrors" | sudo tee -a $REFLECTOR_CONF > /dev/null
echo "--protocol https" | sudo tee -a $REFLECTOR_CONF > /dev/null
echo "--sort rate" | sudo tee -a $REFLECTOR_CONF > /dev/null
echo "--save /etc/pacman.d/mirrorlist" | sudo tee -a $REFLECTOR_CONF > /dev/null

# Backup and update mirror list
MIRRORLIST="/etc/pacman.d/mirrorlist"
sudo cp $MIRRORLIST ${MIRRORLIST}.bak
echo "Updating mirror list with $num_mirrors mirrors from ${country:-worldwide}..."

# Use reflector command with or without --country option based on user input
if [ -n "$country" ]; then
    sudo reflector --country "$country" --latest "$num_mirrors" --protocol https --sort rate --save $MIRRORLIST
else
    sudo reflector --latest "$num_mirrors" --protocol https --sort rate --save $MIRRORLIST
fi

# Part 6: Run a full system update
echo "Running a full system update..."
sudo pacman -Syu

echo "Pacman performance optimization complete."
