#!/bin/bash

# Check if Plymouth is installed
if ! pacman -Qi plymouth &> /dev/null; then
  echo "Plymouth is not installed. Please run the Plymouth installation script first."
  exit 1
fi

# Ensure `yay` is installed for the current user
if ! command -v yay &> /dev/null; then
  echo "Installing AUR helper 'yay'..."
  sudo pacman -S --needed yay || { echo "Failed to install yay. Aborting."; exit 1; }
fi

# Prompt user to enter the theme name
while true; do
  echo "Enter the name of the Plymouth theme you wish to install (leave empty to abort):"
  echo "Hint: Do not include 'plymouth-theme' in the name."
  read -r theme_name

  # Abort if the input is empty
  if [[ -z "$theme_name" ]]; then
    echo "No theme selected. Aborting."
    exit 0
  fi

  # Search for an exact match
  package="plymouth-theme-$theme_name"
  if yay -Si "$package" &> /dev/null; then
    echo "Exact match found: $package"
    yay -S --needed "$package" || { echo "Failed to install theme. Aborting."; exit 1; }
    selected_theme="$theme_name"
    break
  else
    echo "No exact match found for '$theme_name'. Searching AUR..."

    # Search AUR for possible matches and format output
    results=$(yay -Ss "plymouth-theme-$theme_name" | awk -F '  ' '/aur\// {print $1, $3, $4}')
    
    if [[ -z "$results" ]]; then
      echo "No results found. Try a different theme name."
      continue
    fi

    # Display search results with vote and popularity info
    echo -e "\nAvailable themes:"

    # Display results as needed
    echo "$results" | while read -r line; do
      # Print the output as needed
      echo "${line#aur/}" # Remove 'aur/' prefix from each line
    done

    echo "0 Try a new name"
    echo "The (+3.1 1.1) beside the name represents Votes and Popularity. "
	echo "Votes indicate user recommendation; popularity reflects recent usage."
	
    # Get user selection
    read -r -p "Select a theme by entering its name or 0 to try a different name: " selection

    if [[ "$selection" == "0" ]]; then
      continue
    elif [[ "$results" == *"$selection"* ]]; then
      selected_theme="$selection"
      yay -S --needed "plymouth-theme-$selected_theme" || { echo "Failed to install theme. Aborting."; exit 1; }
      break
    else
      echo "Invalid selection. Please try again."
    fi
  fi
done

# Update Plymouth configuration with the selected theme
echo "Updating Plymouth configuration to use theme: $selected_theme..."
sudo sed -i "s/^Theme=.*$/Theme=$selected_theme/" /etc/plymouth/plymouth.conf
echo "Plymouth theme updated to '$selected_theme'."

# Prompt to reboot
echo "Would you like to reboot now to apply the new theme? (y/N)"
read -r -p "Your choice: " reboot_choice

if [[ "$reboot_choice" =~ ^(yes|y)$ ]]; then
  echo "Rebooting system..."
  sudo reboot
else
  echo "Please reboot manually to apply the new theme."
fi
