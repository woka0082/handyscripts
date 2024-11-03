#!/bin/bash

echo "This is script 1/2 to install Timeshift on an Arch Linux or Arch-based system with Btrfs support and GRUB bootloader."

# Check if the system uses pacman
if ! command -v pacman &> /dev/null; then
  echo "This script requires an Arch-based system with pacman as the package manager."
  echo "Aborting..."
  exit 1
fi

# Check if the filesystem is Btrfs
if ! findmnt -t btrfs / &> /dev/null; then
  echo "The root filesystem is not Btrfs. The upcoming script (2/2) will require Btrfs for GRUB snapshot support."
  echo "Aborting..."
  exit 1
fi

# Check if GRUB is installed
if ! ls /boot/grub/grub.cfg &> /dev/null; then
  echo "GRUB bootloader not detected. This script requires GRUB as the bootloader for snapshot support."
  echo "Aborting..."
  exit 1
fi

# Check if Timeshift is already installed
if pacman -Qi timeshift &> /dev/null; then
  echo "Timeshift is already installed."
else
  echo "Installing Timeshift..."
  sudo pacman -Sy --noconfirm timeshift
fi

# Install xorg-xhost
echo "Installing xorg-xhost..."
sudo pacman -Sy --noconfirm xorg-xhost

# Retrieve UUID of root device
UUID=$(sudo findmnt -n -o UUID /)
if [ -z "$UUID" ]; then
  echo "Failed to retrieve the UUID of the root device. Aborting..."
  exit 1
fi

# Configure Timeshift for Btrfs snapshots
echo "Configuring Timeshift to use Btrfs snapshots..."
sudo mkdir -p /etc/timeshift
cat <<EOF | sudo tee /etc/timeshift/timeshift.json > /dev/null
{
  "backup_device_uuid": "$UUID",
  "parent_device_uuid": "",
  "do_first_run": false,
  "btrfs_mode": "true",
  "snapshot_type": "BTRFS",
  "schedule_monthly": false,
  "schedule_weekly": false,
  "schedule_daily": false,
  "schedule_hourly": false,
  "schedule_boot": false,
  "count_monthly": 2,
  "count_weekly": 4,
  "count_daily": 7,
  "count_hourly": 0,
  "count_boot": 5,
  "exclude": [
    "+ /var/log/**",
    "+ /var/cache/pacman/pkg/**",
    "- **"
  ]
}
EOF

# Check if cronie is installed and enabled, start if necessary
if ! pacman -Qi cronie &> /dev/null; then
  echo "Installing cronie for scheduled snapshots..."
  sudo pacman -Sy --noconfirm cronie
fi

if ! systemctl is-enabled cronie &> /dev/null; then
  echo "Enabling cronie service..."
  sudo systemctl enable --now cronie
fi

# Create the first on-demand snapshot
echo "Creating the first on-demand snapshot with Timeshift..."
sudo timeshift --create --comments "Initial setup snapshot"

echo "Timeshift installation and initial configuration complete."
echo "You may later re-launch Timeshift to adjust settings if desired."
echo "Now you can proceed with the second script, 'enable_btrfs_grub.sh' (2/2), to configure GRUB for Btrfs snapshot support."
