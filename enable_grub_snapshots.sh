# To enable grub to update the boot entries
# everythime a new timeshift entries is created or removed
# run the first script "setup_timeshift.sh" before this one

#!/bin/bash

# Manually run the same function first
echo "initiate the snapshots entries to Grub menu..."
sudo /etc/grub.d/41_snapshots-btrfs && sudo grub-mkconfig -o /boot/grub/grub.cfg

# Edit grub-btrfs service
echo "Editing grub-btrfs service..."

# sudo systemctl edit --full grub-btrfs , # to change the line of
# "ExecStart= ..." to the next line here

# Modify the ExecStart line
sudo sed -i 's|ExecStart=/usr/bin/grub-btrfsd/.snapshots --syslog|ExecStart=/usr/bin/grub-btrfsd --syslog --timeshift-auto|' /etc/systemd/system/grub-btrfsd.service

# Start and enable the grub-btrfsd service
echo "Starting and enabling grub-btrfsd service..."
sudo systemctl start grub-btrfsd
sudo systemctl enable grub-btrfsd

echo "Setup complete!"
