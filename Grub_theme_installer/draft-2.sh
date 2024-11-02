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
THEME_LIST=()
index=1
for theme in "$THEMES_DIR"/*/; do
    theme_name=$(basename "$theme")
    echo "$index) $theme_name"
    THEME_LIST+=("$theme_name")
    ((index++))
done
echo "0) Quit"

# Prompt user for selection
while true; do
    read -p "Select a theme by number (0 to quit): " choice
    if [[ $choice =~ ^[0-9]+$ ]]; then
        if [[ $choice -eq 0 ]]; then
            echo "Exiting..."
            exit 0
        elif [[ $choice -gt 0 && $choice -le ${#THEME_LIST[@]} ]]; then
            selected_theme=${THEME_LIST[$((choice - 1))]}
            echo "You selected theme: $selected_theme"
            break
        else
            echo "Invalid selection. Please try again."
        fi
    else
        echo "Invalid input. Please enter a number."
    fi
done

# Install the selected theme
THEME_PATH="$THEMES_DIR/$selected_theme"
if [[ ! -d $THEME_PATH ]]; then
    echo "Theme directory not found: $THEME_PATH"
    exit 1
fi

# Copy the theme to the GRUB themes directory
GRUB_THEME_DIR="/boot/grub/themes/$selected_theme"
mkdir -p "$GRUB_THEME_DIR"
cp -r "$THEME_PATH/"* "$GRUB_THEME_DIR"

# Set the theme in the grub configuration
echo "Setting GRUB theme to $selected_theme..."
echo "GRUB_THEME=\"/boot/grub/themes/$selected_theme/theme.txt\"" >> /etc/default/grub

# Update GRUB
echo "Updating GRUB..."
grub-mkconfig -o /boot/grub/grub.cfg

echo "GRUB theme '$selected_theme' installed and GRUB updated successfully."
