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

# Backup the original grub configuration
GRUB_CFG="/boot/grub/grub.cfg"
GRUB_CFG_BACKUP="/boot/grub/grub.cfg.bak"
cp "$GRUB_CFG" "$GRUB_CFG_BACKUP"
echo "Backup of original GRUB configuration created at $GRUB_CFG_BACKUP."

# List available themes
echo "Available themes:"
THEME_LIST=()
index=1
for theme in "$THEMES_DIR"/*/; do
    theme_name=$(basename "$theme")
    echo "$index) $theme_name"
    THEME_LIST+=("$theme_name")
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

# Check if the theme already exists in /boot/grub/themes
GRUB_THEME_DIR="/boot/grub/themes/$selected_theme"
if [[ -d $GRUB_THEME_DIR ]]; then
    echo "Warning: Theme '$selected_theme' already exists in $GRUB_THEME_DIR. It will be replaced."
    read -p "Do you want to proceed? (y/n): " confirm
    if [[ $confirm != "y" ]]; then
        echo "Operation canceled."
        exit 0
    fi
    # Remove the old theme
    rm -rf "$GRUB_THEME_DIR"
fi

# Copy the new theme to the GRUB themes directory
mkdir -p "$GRUB_THEME_DIR"
cp -r "$THEME_PATH/"* "$GRUB_THEME_DIR"

# Check and modify the GRUB configuration
echo "Checking GRUB configuration..."
GRUB_CONFIG="/etc/default/grub"
GRUB_TIMEOUT_STYLE=$(grep -E '^GRUB_TIMEOUT_STYLE=' "$GRUB_CONFIG" | cut -d'=' -f2 | tr -d '\"')
GRUB_GFXMODE=$(grep -E '^GRUB_GFXMODE=' "$GRUB_CONFIG" | cut -d'=' -f2 | tr -d '\"')
GRUB_TIMEOUT=$(grep -E '^GRUB_TIMEOUT=' "$GRUB_CONFIG" | cut -d'=' -f2)

# Check GRUB_TIMEOUT_STYLE
if [[ "$GRUB_TIMEOUT_STYLE" != "menu" ]]; then
    echo "Warning: GRUB_TIMEOUT_STYLE is set to '$GRUB_TIMEOUT_STYLE'. It should be set to 'menu' for themes to work properly."
fi

# Check GRUB_GFXMODE
if [[ "$GRUB_GFXMODE" != "auto" ]]; then
    echo "Warning: GRUB_GFXMODE is set to '$GRUB_GFXMODE'. It is recommended to set it to 'auto' for best compatibility."
fi

# Prompt to change GRUB_TIMEOUT
echo "Current GRUB_TIMEOUT is set to: $GRUB_TIMEOUT seconds."
read -p "Do you want to change the GRUB_TIMEOUT? (y/n): " change_timeout
if [[ $change_timeout == "y" ]]; then
    read -p "Enter new GRUB_TIMEOUT value (in seconds): " new_timeout
    if [[ $new_timeout =~ ^[0-9]+$ ]]; then
        sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=\"$new_timeout\"/" "$GRUB_CONFIG"
        echo "GRUB_TIMEOUT has been updated to $new_timeout seconds."
    else
        echo "Invalid input. Keeping the current GRUB_TIMEOUT."
    fi
fi

# Check if a theme is already set in grub configuration
if grep -q "GRUB_THEME=" "$GRUB_CONFIG"; then
    echo "Removing previous theme from GRUB configuration."
    sed -i "/^GRUB_THEME=/d" "$GRUB_CONFIG"
fi

# Set the new theme in the grub configuration
echo "Setting GRUB theme to $selected_theme..."
echo "GRUB_THEME=\"/boot/grub/themes/$selected_theme/theme.txt\"" >> "$GRUB_CONFIG"

# Update GRUB
echo "Updating GRUB..."
grub-mkconfig -o /boot/grub/grub.cfg

echo "GRUB theme '$selected_theme' installed and GRUB updated successfully."
