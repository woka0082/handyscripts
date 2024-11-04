#!/bin/bash

# Prompt the user for confirmation with "No" as the default
echo "This script will install Plymouth and configure it for your Arch Linux system."
echo "It may overwrite any existing Plymouth configuration and modify GRUB settings."
echo "Do you want to continue? (y/N)"
read -r -p "Your choice: " choice

# Convert the input to lowercase for flexibility and check if it's "yes" or "y"
if [[ ! "$choice" =~ ^(yes|y)$ ]]; then
  echo "Installation aborted by the user."
  exit 0
fi

# Ensure the user has sudo privileges
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

# Install Plymouth if not already installed
if ! pacman -Qi plymouth &> /dev/null; then
  echo "Installing Plymouth..."
  pacman -Sy --needed plymouth || { echo "Failed to install Plymouth."; exit 1; }
else
  echo "Plymouth is already installed."
fi

# Configure Plymouth only if not already configured
PLYMOUTH_CONFIG="/etc/plymouth/plymouth.conf"
if [[ ! -f "$PLYMOUTH_CONFIG" ]]; then
  echo "Creating plymouth.conf with default settings..."
  cat <<EOF > "$PLYMOUTH_CONFIG"
[Daemon]
Theme=fade-in
ShowDelay=5
EOF
  echo "Plymouth configuration created with 'fade-in' theme."
else
  echo "Plymouth configuration already exists at $PLYMOUTH_CONFIG."
fi

# Modify GRUB configuration
echo "Configuring GRUB for Plymouth..."
GRUB_CONFIG="/etc/default/grub"
if [[ -f $GRUB_CONFIG ]]; then
  # Backup the original GRUB config
  cp "$GRUB_CONFIG" "${GRUB_CONFIG}.bak"
  echo "Backup of GRUB configuration created at ${GRUB_CONFIG}.bak."

  # Check if "quiet splash" is already present
  if grep -q 'quiet splash' "$GRUB_CONFIG"; then
    echo "'quiet splash' is already present in GRUB_CMDLINE_LINUX. No changes made."
  else
    # Append "quiet splash" to the GRUB_CMDLINE_LINUX line
    sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ quiet splash"/' "$GRUB_CONFIG"
    echo "Added 'quiet splash' to GRUB_CMDLINE_LINUX."
  fi
else
  echo "GRUB configuration file not found at $GRUB_CONFIG."
  exit 1
fi

# Update GRUB
echo "Updating GRUB configuration..."
grub-mkconfig -o /boot/grub/grub.cfg || { echo "Failed to update GRUB."; exit 1; }

# Ask the user what to do next
echo "Plymouth installation and setup complete."
echo "What would you like to do next?"
echo "1) Reboot now"
echo "2) Install additional themes"
echo "3) Finish"
read -r -p "Your choice (1/2/3): " next_choice

case "$next_choice" in
  1)
    echo "Rebooting system..."
    reboot
    ;;
  2)
    echo "Launching Plymouth theme manager..."
    ./set_theme.sh
    ;;
  *)
    echo "Installation complete. Please reboot manually to apply the changes."
    ;;
esac
