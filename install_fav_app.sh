#!/bin/bash

# Define your package list
packages=(
  "neofetch"
  "htop"
  "vim"
  # Add more packages here
)

# Step 2: Check if pacman is installed
if ! command -v pacman &> /dev/null; then
  echo "This script is designed for Arch Linux or Arch-based distros with pacman installed."
  exit 1
fi

# Step 3: Check if yay or paru is installed
if command -v yay &> /dev/null; then
  installer="yay"
elif command -v paru &> /dev/null; then
  installer="paru"
else
  # Neither yay nor paru is installed, prompt to install one
  read -p "Neither yay nor paru is installed. Do you want to install yay as the AUR helper? (Y/n): " choice
  choice=${choice:-Y}
  if [[ "$choice" =~ ^[Yy]$ ]]; then
    installer="yay"
    sudo pacman -S --needed --noconfirm git
    git clone https://aur.archlinux.org/yay.git
    cd yay || exit
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
  else
    installer="paru"
    sudo pacman -S --needed --noconfirm git
    git clone https://aur.archlinux.org/paru.git
    cd paru || exit
    makepkg -si --noconfirm
    cd ..
    rm -rf paru
  fi
fi

# Step 4: Validate the packages in the list
invalid_packages=()
for package in "${packages[@]}"; do
  if ! $installer -Si "$package" &> /dev/null; then
    invalid_packages+=("$package")
  fi
done

if [ "${#invalid_packages[@]}" -ne 0 ]; then
  echo "The following packages are invalid or not found in repositories: ${invalid_packages[*]}"
  echo "Please check the package list and try again."
  exit 1
fi

# Step 5: Install packages not already installed
to_install=()
for package in "${packages[@]}"; do
  if ! pacman -Qi "$package" &> /dev/null; then
    to_install+=("$package")
  fi
done

if [ "${#to_install[@]}" -eq 0 ]; then
  echo "All packages are already installed."
  exit 0
fi

echo "The following packages will be installed: ${to_install[*]}"
read -p "Do you want to proceed with installation? (Y/n): " proceed
proceed=${proceed:-Y}

if [[ "$proceed" =~ ^[Yy]$ ]]; then
  sudo $installer -S --needed "${to_install[@]}"
  echo "Installation complete."
else
  echo "Installation aborted."
  exit 0
fi

