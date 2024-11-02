#!/bin/bash

echo "This is script 2/2 to enable GRUB support for Btrfs snapshots on an Arch Linux or Arch-based system."

# Check if Timeshift is installed
if ! command -v timeshift &> /dev/null; then
  echo "Timeshift is not installed. Please run the first script 'install_timeshift.sh' "
  echo "Aborting..."
  exit 1
fi

# Check if the filesystem is Btrfs
if ! df / | grep -q "btrfs"; then
  echo "The root filesystem is not Btrfs. This script requires Btrfs to enable snapshot support in GRUB."
  echo "Aborting..."
  exit 1
fi

# Check if GRUB is the bootloader
if ! grep -q "GRUB" /boot/grub/grub.cfg 2>/dev/null; then
  echo "GRUB bootloader not detected. This script requires GRUB as the bootloader."
  echo "Aborting..."
  exit 1
fi

# Check if grub-btrfs is installed; if not, attempt to install
if ! pacman -Qi grub-btrfs &> /dev/null; then
  echo "grub-btrfs is not installed. Installing it now..."
  sudo pacman -Sy --noconfirm grub-btrfs
else
  echo "grub-btrfs is already installed."
fi

# Update GRUB configuration for Btrfs snapshots
echo "Updating GRUB configuration for Btrfs snapshots..."
sudo /etc/grub.d/41_snapshots-btrfs
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Install inotify-tools
echo "Installing inotify-tools..."
sudo pacman -Sy --noconfirm inotify-tools

# Enable grub-btrfsd.service
echo "Enabling grub-btrfsd.service..."
sudo systemctl enable --now grub-btrfsd.service

# Modify grub-btrfsd.service to include --syslog --timeshift-auto
echo "Editing /etc/systemd/system/grub-btrfsd.service to use --timeshift-auto option..."
sudo sed -i 's|^ExecStart=/usr/bin/grub-btrfsd|#&|' /etc/systemd/system/grub-btrfsd.service
echo "ExecStart=/usr/bin/grub-btrfsd --syslog --timeshift-auto" | sudo tee -a /etc/systemd/system/grub-btrfsd.service > /dev/null

# Restart grub-btrfsd.service
echo "Restarting grub-btrfsd.service..."
sudo systemctl restart grub-btrfsd.service

echo "GRUB has been configured to detect Btrfs snapshots."
echo "From now on, any snapshots created or removed by Timeshift will be available in the GRUB menu under the 'Snapshots' submenu at boot."

echo "You can test this by rebooting your system and accessing the GRUB menu."
echo "For rollback to a previous snapshot, simply select a snapshot from the GRUB 'Snapshots' submenu."
