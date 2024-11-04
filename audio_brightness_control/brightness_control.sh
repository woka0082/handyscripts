#!/bin/bash

while true; do
    # Get the current brightness level
    current_brightness=$(brightnessctl get)
    max_brightness=$(brightnessctl max)
    
    # Calculate the percentage
    brightness_percentage=$(( 100 * current_brightness / max_brightness ))

    echo "Current brightness: $brightness_percentage%"
    echo "Enter new brightness percentage (0-100), '+' to increase by 5%, '-' to decrease by 5%, or press Enter to quit:"

    read -r user_input

    # Check if the user wants to quit
    if [[ -z "$user_input" ]]; then
        echo "Exiting..."
        break
    fi

    # Check for '+' or '-' inputs
    if [[ "$user_input" == "+" ]]; then
        brightnessctl set +5%
        continue
    elif [[ "$user_input" == "-" ]]; then
        brightnessctl set 5%-
        continue
    fi

    # Check if the input is a valid percentage (0-100)
    if [[ "$user_input" =~ ^[0-9]+$ ]] && [ "$user_input" -ge 0 ] && [ "$user_input" -le 100 ]; then
        brightnessctl set "$user_input%"
    else
        echo "Invalid input. Please enter a number between 0-100, '+' to increase, or '-' to decrease."
    fi
done
