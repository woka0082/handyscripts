## Install favorite apps

# Define the list of favorite apps, change at will, 
# but make sure they do exist and match the names in official repo and AUR exactly

apps=(
    "loupe"
    "vlc"
    "mpv"
    "librewolf-bin"
    "obs-studio"
    "vidcutter"
    "geany"
    "gparted"
    "joplin-appimage"
    "signal-desktop"
    "localsend-bin"
    "libreoffice-still"
    "bat"
    "fzf"
    "tldr"
    "backintime"
    #"code"  # Visual Studio Code
    # Add more packages as needed
     
)
#!/bin/bash

# Function to install yay
install_yay() {
    echo "Installing yay..."
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay || exit
    makepkg -si --noconfirm
    cd .. && rm -rf yay
}

# Function to install paru
install_paru() {
    echo "Installing paru..."
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/paru.git
    cd paru || exit
    makepkg -si --noconfirm
    cd .. && rm -rf paru
}

# Check for yay or paru
if ! command -v yay &> /dev/null && ! command -v paru &> /dev/null; then
    echo "Neither yay nor paru is installed."
    echo "Please choose an option to install one (default is yay):"
    echo "1) Install yay"
    echo "2) Install paru"
    read -rp "Enter your choice (1 or 2): " choice
    choice=${choice:-1}  # Default to 1 if no input

    case $choice in
        1)
            install_yay
            ;;
        2)
            install_paru
            ;;
        *)
            echo "Invalid option. Exiting."
            exit 1
            ;;
    esac
fi

# Define the list of favorite apps
apps=(
    "vlc"
    "git"
    "neofetch"
    "htop"
    "firefox"
    "code"  # Visual Studio Code
    # Add more packages as needed
)

# Check if the packages are valid
echo "Checking package validity..."
invalid_packages=()

for app in "${apps[@]}"; do
    if ! pacman -Si "$app" &> /dev/null && ! yay -Si "$app" &> /dev/null && ! paru -Si "$app" &> /dev/null; then
        invalid_packages+=("$app")
    fi
done

# If there are invalid packages, notify the user and exit
if [ ${#invalid_packages[@]} -ne 0 ]; then
    echo "The following package(s) do not exist: ${invalid_packages[*]}"
    echo "Please check the list and edit the script."
    exit 1
fi

# Confirm installation
echo "All packages are valid: ${apps[*]}"
read -rp "Do you want to install these packages? (y/N, default is y): " confirm
confirm=${confirm,,}  # Convert to lowercase
confirm=${confirm:-y}  # Default to "y" if no input

if [[ "$confirm" != "y" ]]; then
    echo "Aborting installation."
    exit 0
fi

# Install the packages
echo "Installing favorite apps..."
for app in "${apps[@]}"; do
    if pacman -Qi "$app" &> /dev/null; then
        echo "$app is already installed. Skipping."
    else
        if command -v yay &> /dev/null; then
            yay -S --noconfirm "$app"
        else
            paru -S --noconfirm "$app"
        fi
    fi
done

echo "All favorite apps have been processed."
