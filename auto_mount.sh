## This is intend to auto mount the secondary drive or partition

#!/bin/bash

# List all partitions
echo "Available partitions:"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep part

# Prompt for the partition to mount
read -p "Enter the partition you want to auto-mount (e.g., /dev/sda1): " partition

# Validate partition
if [[ ! -b "$partition" ]]; then
    echo "Invalid partition specified."
    exit 1
fi

# Get the UUID of the partition
uuid=$(blkid -s UUID -o value "$partition")
if [[ -z "$uuid" ]]; then
    echo "Could not determine UUID for the partition."
    exit 1
fi

# Detect filesystem type
fs_type=$(lsblk -f "$partition" | awk 'NR==2 {print $2}')
if [[ -z "$fs_type" ]]; then
    echo "Could not determine filesystem type. Please specify it manually."
    read -p "Enter the filesystem type (e.g., ext4, ntfs, etc.): " fs_type
fi

# Prompt for mount point name
read -p "Enter the name for the mount point in your home directory: " mount_point_name
mount_point="$HOME/$mount_point_name"


# Backup /etc/fstab
sudo cp /etc/fstab /etc/fstab.bak
echo "Backup of /etc/fstab created as /etc/fstab.bak."

# Create the mount point directory
mkdir -p "$mount_point"

# Add entry to /etc/fstab using UUID
echo "UUID=$uuid $mount_point $fs_type defaults 0 2" | sudo tee -a /etc/fstab

# Mount the partition immediately
sudo mount -a

echo "The partition with UUID $uuid is now set to auto-mount at $mount_point and has been mounted."
