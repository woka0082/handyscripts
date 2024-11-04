#!/bin/bash

while true; do
    # Get the current volume level of the first RUNNING sink
    current_volume=$(pactl list sinks | awk '/State: RUNNING/{f=1} f && /Volume:/{print $5; exit}')

    if [ -z "$current_volume" ]; then
        echo "No running sinks found."
        exit 1
    fi

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
        pactl set-sink-volume @DEFAULT_SINK@ +5%
        continue
    elif [[ "$user_input" == "-" ]]; then
        pactl set-sink-volume @DEFAULT_SINK@ -5%
        continue
    fi

    # Check if the input is a valid percentage (0-100)
    if [[ "$user_input" =~ ^[0-9]+$ ]] && [ "$user_input" -ge 0 ] && [ "$user_input" -le 100 ]; then
        pactl set-sink-volume @DEFAULT_SINK@ "$user_input%"
    else
        echo "Invalid input. Please enter a number between 0-100, '+' to increase, or '-' to decrease."
    fi
done
