#!/bin/bash

# Ensure the script is running as root
if [[ "$EUID" -ne 0 ]]; then
  echo "Please run this script as root."
  exit 1
fi

# Display available themes with numbers for easy selection
echo "Available Plymouth themes:"
plymouth-set-default-theme --list | nl -w2 -s') '

# Prompt user to select a theme
read -r -p "Enter the number corresponding to your chosen theme: " theme_choice

# Get the theme name based on the selection
theme_name=$(plymouth-set-default-theme --list | sed -n "${theme_choice}p")

# Check if the selection was valid
if [[ -z "$theme_name" ]]; then
  echo "Invalid selection. Aborting."
  exit 1
fi

# Check if mkinitcpio is installed; if not, install it
if ! command -v mkinitcpio &> /dev/null; then
  echo "mkinitcpio not found. Installing it..."
  pacman -Sy --needed mkinitcpio
fi

# Set the theme and regenerate initramfs
echo "Setting Plymouth theme and regenerating initramfs..."
plymouth-set-default-theme -R "$theme_name"

echo "Plymouth theme successfully updated to '$theme_name'."
echo "Reboot to apply the new theme."
