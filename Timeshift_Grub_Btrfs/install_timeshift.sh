#!/bin/bash

echo "This is script 1/2 to install and configure Timeshift on an Arch Linux or Arch-based system with Btrfs and GRUB."
echo "Please ensure your system meets these requirements before proceeding."
echo "Note: Although Timeshift can run on other filesystems, script 2/2 will require Btrfs."

# Check if pacman is installed (confirming Arch or Arch-based)
if ! command -v pacman &> /dev/null; then
  echo "This script is designed for Arch Linux or Arch-based systems only."
  echo "pacman package manager not found."
  echo "Aborting..."
  exit 1
fi

# Check if the filesystem is Btrfs
if ! df / | grep -q "btrfs"; then
  echo "The root filesystem is not Btrfs."
  echo "Script 2/2 will require Btrfs, so this setup is not compatible."
  echo "Aborting..."
  exit 1
fi

# Check if GRUB is the bootloader
if ! grep -q "GRUB" /boot/grub/grub.cfg 2>/dev/null; then
  echo "GRUB bootloader not detected."
  echo "This setup is not compatible without GRUB."
  echo "Aborting..."
  exit 1
fi

# Check if Timeshift is already installed
if command -v timeshift &> /dev/null; then
  echo "Timeshift is already installed."

  # Check if Timeshift is using Btrfs mode
  if grep -q '"btrfs_mode" : "true"' /etc/timeshift/timeshift.json 2>/dev/null; then
    echo "Timeshift is already configured to use Btrfs for snapshots."
  else
    # Prompt user to change configuration to Btrfs
    echo "Timeshift is not currently configured to use Btrfs for snapshots."
    read -p "Do you want to change Timeshift to use Btrfs snapshots? (y/N): " change_to_btrfs
    change_to_btrfs=${change_to_btrfs:-N}
    if [[ "$change_to_btrfs" != "y" ]]; then
      echo "Aborting..."
      exit 1
    fi

    # Modify Timeshift configuration to use Btrfs
    echo "Updating Timeshift configuration to use Btrfs for snapshots..."
    sudo sed -i 's/"btrfs_mode" : "false"/"btrfs_mode" : "true"/' /etc/timeshift/timeshift.json
    echo "Timeshift has been reconfigured to use Btrfs snapshots."
  fi
else
  # Install Timeshift and xorg-xhost if Timeshift is not installed
  echo "Timeshift is not installed. Proceeding with installation..."
  sudo pacman -Sy --noconfirm timeshift xorg-xhost

  # Set up Timeshift configuration file
  CONFIG_DIR="/etc/timeshift"
  CONFIG_FILE="$CONFIG_DIR/timeshift.json"

  sudo mkdir -p "$CONFIG_DIR"
  sudo tee "$CONFIG_FILE" > /dev/null <<EOL
{
  "backup_device_uuid" : "$(blkid -s UUID -o value $(mount | grep 'on / ' | awk '{print $1}'))",
  "parent_device_uuid" : "",
  "do_first_run" : "false",
  "btrfs_mode" : "true",
  "schedule_monthly" : "false",
  "schedule_weekly" : "false",
  "schedule_daily" : "false",
  "schedule_hourly" : "false",
  "schedule_boot" : "true",
  "count_monthly" : "2",
  "count_weekly" : "3",
  "count_daily" : "5",
  "count_hourly" : "6",
  "count_boot" : "10",
  "snapshot_size" : "0",
  "exclude" : [
    "+ /home",
    "- /var/cache/pacman/pkg/*",
    "- /var/log/*"
  ]
}
EOL
  echo "Timeshift has been installed and configured to use Btrfs for snapshots on your root device."
fi

# Check if cronie is installed and running
if ! command -v crond &> /dev/null; then
  echo "Cronie is not installed. Installing cronie..."
  sudo pacman -Sy --noconfirm cronie
fi

# Enable and start cronie service
echo "Ensuring cronie service is enabled and started..."
sudo systemctl enable --now cronie

# Create the first on-demand snapshot
sudo timeshift --create --comments "Initial on-demand snapshot" --tags O

echo "First on-demand snapshot created successfully."
echo "You can now proceed with script 2/2: enable_grub_snapshots.sh"
echo "Note: If you would like to customize your Timeshift configuration further, you can re-launch Timeshift later with the command 'timeshift-launcher'."
