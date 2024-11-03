## This is intend to auto mount the secondary drive or partition

#!/bin/bash

# List all partitions
echo "Available partitions:"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep part

# Prompt for the partition to mount
read -p "Enter the partition you want to auto-mount (e.g., /dev/sda1): " partition

# Ensure the partition has the /dev/ prefix
[[ $partition != /dev/* ]] && partition="/dev/$partition"

# Validate partition
if [[ ! -b "$partition" ]]; then
    echo "Invalid partition specified."
    exit 1
fi

# Prompt for mount point name
read -p "Enter the name for the mount point in your home directory: " mount_point_name
mount_point="$HOME/$mount_point_name"

# Backup /etc/fstab
if sudo cp /etc/fstab /etc/fstab.bak; then
    echo "Backup of /etc/fstab created as /etc/fstab.bak."
else
    echo "Failed to create backup of /etc/fstab."
    exit 1
fi

# Get the UUID of the partition
uuid=$(blkid -s UUID -o value "$partition")
if [[ -z "$uuid" ]]; then
    echo "Could not determine UUID for the partition."
    exit 1
fi

# Detect filesystem type
fs_type=$(blkid -s TYPE -o value "$partition")
if [[ -z "$fs_type" ]]; then
    echo "Could not determine filesystem type. Please specify it manually."
    read -p "Enter the filesystem type (e.g., ext4, ntfs, etc.): " fs_type
fi

# Create the mount point directory
mkdir -p "$mount_point"

# Add entry to /etc/fstab using UUID
if echo "UUID=$uuid $mount_point $fs_type defaults 0 2" | sudo tee -a /etc/fstab; then
    sudo systemctl daemon-reload
    echo "Entry added to /etc/fstab."
else
    echo "Failed to add entry to /etc/fstab."
    exit 1
fi

# Mount the partition immediately
if sudo mount -a; then
    echo "The partition with UUID $uuid is now set to auto-mount at $mount_point and has been mounted."
else
    echo "Failed to mount the partition."
    exit 1
fi
