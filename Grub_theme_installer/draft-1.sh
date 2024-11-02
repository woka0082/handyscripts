#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root or with sudo." 
    exit 1
fi

# Define the themes directory
THEMES_DIR="./themes"

# Check if the themes directory exists
if [[ ! -d $THEMES_DIR ]]; then
    echo "Themes directory not found: $THEMES_DIR"
    exit 1
fi

# List available themes
echo "Available themes:"
select theme in $(ls -d "$THEMES_DIR"/*/ | xargs -n 1 basename); do
    if [[ -n $theme ]]; then
        echo "You selected theme: $theme"
        break
    else
        echo "Invalid selection."
    fi
done

# Install the selected theme
THEME_PATH="$THEMES_DIR/$theme"
if [[ ! -d $THEME_PATH ]]; then
    echo "Theme directory not found: $THEME_PATH"
    exit 1
fi

# Copy the theme to the GRUB themes directory
GRUB_THEME_DIR="/boot/grub/themes/$theme"
mkdir -p "$GRUB_THEME_DIR"
cp -r "$THEME_PATH/"* "$GRUB_THEME_DIR"

# Set the theme in the grub configuration
echo "Setting GRUB theme to $theme..."
echo "GRUB_THEME=\"/boot/grub/themes/$theme/theme.txt\"" >> /etc/default/grub

# Update GRUB
echo "Updating GRUB..."
grub-mkconfig -o /boot/grub/grub.cfg

echo "GRUB theme '$theme' installed and GRUB updated successfully."
