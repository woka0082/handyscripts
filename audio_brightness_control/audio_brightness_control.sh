#!/bin/bash

# Check for ALSA and PulseAudio
ALSA_INSTALLED=$(command -v amixer)
PULSEAUDIO_INSTALLED=$(command -v pactl)

# Function to control volume using ALSA
control_volume_alsa() {
    while true; do
        current_volume=$(amixer get Master | grep -o '[0-9]*%' | head -n 1)

        echo "Current volume: $current_volume"
        echo "Enter new volume percentage (0-100), '+' to increase by 5%, '-' to decrease by 5%, or press Enter to quit:"

        read -r user_input

        if [[ -z "$user_input" ]]; then
            echo "Exiting volume control..."
            break
        fi

        if [[ "$user_input" == "+" ]]; then
            amixer set Master 5%+
            continue
        elif [[ "$user_input" == "-" ]]; then
            amixer set Master 5%-
            continue
        fi

        if [[ "$user_input" =~ ^[0-9]+$ ]] && [ "$user_input" -ge 0 ] && [ "$user_input" -le 100 ]; then
            amixer set Master "$user_input%"
        else
            echo "Invalid input. Please enter a number between 0-100, '+' to increase, or '-' to decrease."
        fi
    done
}

# Function to control volume using PulseAudio
control_volume_pulse() {
    while true; do
        current_volume=$(pactl list sinks | awk '/State: RUNNING/{f=1} f && /Volume:/{print $5; exit}')

        echo "Current volume: $current_volume"
        echo "Enter new volume percentage (0-100), '+' to increase by 5%, '-' to decrease by 5%, or press Enter to quit:"

        read -r user_input

        if [[ -z "$user_input" ]]; then
            echo "Exiting volume control..."
            break
        fi

        if [[ "$user_input" == "+" ]]; then
            pactl set-sink-volume @DEFAULT_SINK@ +5%
            continue
        elif [[ "$user_input" == "-" ]]; then
            pactl set-sink-volume @DEFAULT_SINK@ -5%
            continue
        fi

        if [[ "$user_input" =~ ^[0-9]+$ ]] && [ "$user_input" -ge 0 ] && [ "$user_input" -le 100 ]; then
            pactl set-sink-volume @DEFAULT_SINK@ "$user_input%"
        else
            echo "Invalid input. Please enter a number between 0-100, '+' to increase, or '-' to decrease."
        fi
    done
}

# Function to control brightness
control_brightness() {
    while true; do
        current_brightness=$(brightnessctl get)
        max_brightness=$(brightnessctl max)
        brightness_percentage=$(( 100 * current_brightness / max_brightness ))

        echo "Current brightness: $brightness_percentage%"
        echo "Enter new brightness percentage (0-100), '+' to increase by 5%, '-' to decrease by 5%, or press Enter to quit:"

        read -r user_input

        if [[ -z "$user_input" ]]; then
            echo "Exiting brightness control..."
            break
        fi

        if [[ "$user_input" == "+" ]]; then
            brightnessctl set +5%
            continue
        elif [[ "$user_input" == "-" ]]; then
            brightnessctl set 5%-
            continue
        fi

        if [[ "$user_input" =~ ^[0-9]+$ ]] && [ "$user_input" -ge 0 ] && [ "$user_input" -le 100 ]; then
            brightnessctl set "$user_input%"
        else
            echo "Invalid input. Please enter a number between 0-100, '+' to increase, or '-' to decrease."
        fi
    done
}

# Choose audio control method
if [[ -n $ALSA_INSTALLED ]] && [[ -n $PULSEAUDIO_INSTALLED ]]; then
    echo "Both ALSA and PulseAudio are installed."
    echo "Choose audio control method:"
    echo "1) ALSA (default)"
    echo "2) PulseAudio"
    read -r choice

    case $choice in
        1|"" ) control_volume_alsa ;;
        2 ) control_volume_pulse ;;
        * ) echo "Invalid choice. Defaulting to ALSA."; control_volume_alsa ;;
    esac
elif [[ -n $ALSA_INSTALLED ]]; then
    echo "ALSA is installed."
    control_volume_alsa
elif [[ -n $PULSEAUDIO_INSTALLED ]]; then
    echo "PulseAudio is installed."
    control_volume_pulse
else
    echo "No audio control found. Exiting..."
    exit 1
fi

# After volume control, proceed to brightness control
control_brightness
