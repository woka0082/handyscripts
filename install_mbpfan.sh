## This is to install mbpfan for my old iMac

#!/bin/bash

# Function to install mbpfan
install_mbpfan() {
    echo "Installing mbpfan..."
    yay -Syu mbpfan --noconfirm
}

# Function to open the configuration file
edit_config() {
    config_file="/etc/mbpfan.conf"
    echo "Opening the configuration file at $config_file for editing..."
    sudo nano "$config_file"
}

# Function to enable and start the mbpfan service
enable_service() {
    echo "Enabling and starting the mbpfan service..."
    sudo systemctl enable mbpfan
    sudo systemctl start mbpfan
}

# Main script execution
install_mbpfan
edit_config
enable_service

echo "mbpfan installation and configuration complete. The service is now running."
