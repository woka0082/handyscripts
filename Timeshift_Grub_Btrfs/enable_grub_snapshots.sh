#!/bin/bash

echo "This is script 2/2 to enable GRUB support for Btrfs snapshots on an Arch Linux or Arch-based system."

# Check if Timeshift is installed
if ! command -v timeshift &> /dev/null; then
  echo "Timeshift is not installed. Please run the first script 'install_timeshift.sh' "
  echo "Aborting..."
  exit 1
fi

# Check if the filesystem is Btrfs
if ! findmnt -t btrfs / &> /dev/null; then
  echo "The root filesystem is not Btrfs."
  echo "Script 2/2 will require Btrfs, so this setup is not compatible."
  echo "Aborting..."
  exit 1
fi

# Check if GRUB is the bootloader
if ! ls /boot/grub/grub.cfg &> /dev/null; then
  echo "GRUB bootloader not detected."
  echo "This setup is not compatible without GRUB."
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
#!/bin/bash

# Enable and start grub-btrfsd.service
echo "Enabling and starting grub-btrfsd.service..."
sudo systemctl enable --now grub-btrfsd.service

# Copy the default grub-btrfsd.service to the editable location
echo "Creating a local copy of grub-btrfsd.service for customization..."
sudo cp /usr/lib/systemd/system/grub-btrfsd.service /etc/systemd/system/

# Modify grub-btrfsd.service to include --syslog --timeshift-auto
echo "Configuring grub-btrfsd to recognize Timeshift snapshots..."
sudo sed -i 's|^ExecStart=/usr/bin/grub-btrfsd|#&|' /etc/systemd/system/grub-btrfsd.service
echo "ExecStart=/usr/bin/grub-btrfsd --syslog --timeshift-auto" | sudo tee -a /etc/systemd/system/grub-btrfsd.service > /dev/null

# Reload systemd and restart grub-btrfsd.service to apply changes
echo "Restarting grub-btrfsd.service to apply new configuration..."
sudo systemctl daemon-reload
sudo systemctl restart grub-btrfsd.service

echo "Configuration complete. GRUB is now set up to detect Btrfs snapshots created or removed by Timeshift."
echo "Reboot your system to test that Timeshift snapshots appear under the 'Snapshots' submenu in the GRUB menu."
