#!/bin/bash

# Function to list available partitions
list_partitions() {
    echo "Available partitions:"
    lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT | grep -v '^$' | grep -v 'loop'
}

# Create a new directory under the user's home
read -p "Enter a name for the new directory (under your home): " dir_name
user_home=$(eval echo ~$USER)
new_dir="$user_home/$dir_name"

mkdir -p "$new_dir"
echo "Created directory: $new_dir"

# List partitions and get user choice
list_partitions
read -p "Choose a partition (e.g., /dev/sda5): " selected_partition

# Check if the selected partition exists
if [ ! -b "$selected_partition" ]; then
    echo "Invalid partition selected. Exiting."
    exit 1
fi

# Get the filesystem type and UUID of the selected partition using sudo
filesystem_type=$(sudo lsblk -no FSTYPE "$selected_partition")
uuid=$(sudo blkid -s UUID -o value "$selected_partition")

if [ -z "$filesystem_type" ]; then
    echo "No filesystem found on $selected_partition. Exiting."
    exit 1
fi

# Mount the selected partition
sudo mount -t "$filesystem_type" "$selected_partition" "$new_dir"
if [ $? -ne 0 ]; then
    echo "Failed to mount $selected_partition to $new_dir. Exiting."
    exit 1
fi

echo "Successfully mounted $selected_partition to $new_dir."

# Update /etc/fstab
echo "Updating /etc/fstab..."
echo "UUID=$uuid $new_dir $filesystem_type defaults 0 2" | sudo tee -a /etc/fstab

if [ $? -eq 0 ]; then
    echo "Successfully updated /etc/fstab. The partition will be mounted on boot."
else
    echo "Failed to update /etc/fstab."
    exit 1
fi

echo "Script completed successfully."
