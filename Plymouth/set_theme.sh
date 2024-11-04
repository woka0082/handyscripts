#!/bin/bash

# Ensure the user is root
if [[ $EUID -ne 0 ]]; then
  echo "Please run this script as root."
  exit 1
fi

# Display currently available themes
echo "Available Plymouth themes:"
themes=($(ls /usr/share/plymouth/themes/))
for i in "${!themes[@]}"; do
  echo "$i) ${themes[i]}"
done

# Prompt the user to choose a theme
read -r -p "Select a theme by number: " theme_choice

# Validate selection
if [[ ! "$theme_choice" =~ ^[0-9]+$ ]] || (( theme_choice < 0 || theme_choice >= ${#themes[@]} )); then
  echo "Invalid choice. Exiting."
  exit 1
fi

selected_theme="${themes[theme_choice]}"

# Update Plymouth configuration to use the selected theme
echo "Updating Plymouth configuration to use theme: $selected_theme..."
sed -i "s/^Theme=.*$/Theme=$selected_theme/" /etc/plymouth/plymouth.conf
echo "Plymouth theme updated to '$selected_theme'."

# Provide hint for installing additional themes
echo "To download new Plymouth themes, you can use the 'get_new_themes.sh' script."

# Ask if the user wants to reboot
echo "Would you like to reboot now to apply the new theme? (y/N)"
read -r -p "Your choice: " reboot_choice

if [[ "$reboot_choice" =~ ^(yes|y)$ ]]; then
  echo "Rebooting system..."
  reboot
else
  echo "Please reboot manually to apply the new theme."
fi
