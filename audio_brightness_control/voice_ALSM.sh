#!/bin/bash

while true; do
    # Get current volume level
    current_volume=$(amixer get Master | grep -o '[0-9]*%' | head -n 1)

    echo "Current volume: $current_volume"
    echo "Enter new volume percentage (0-100), '+' to increase by 5%, '-' to decrease by 5%, or press Enter to quit:"

    read -r user_input

    # Check if the user wants to quit
    if [[ -z "$user_input" ]]; then
        echo "Exiting..."
        break
    fi

    # Check for '+' or '-' inputs
    if [[ "$user_input" == "+" ]]; then
        amixer set Master 5%+
        continue
    elif [[ "$user_input" == "-" ]]; then
        amixer set Master 5%-
        continue
    fi

    # Check if the input is a valid percentage (0-100)
    if [[ "$user_input" =~ ^[0-9]+$ ]] && [ "$user_input" -ge 0 ] && [ "$user_input" -le 100 ]; then
        amixer set Master "$user_input%"
    else
        echo "Invalid input. Please enter a number between 0-100, '+' to increase, or '-' to decrease."
    fi
done
