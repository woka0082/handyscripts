#!/bin/bash
# Screenshot Script v3
# Features:
# - Options:
#   1. Full Screen Screenshot
#   2. Selected Area Screenshot
#   3. Full Screen Screenshot (Swappy)
#   4. Selected Area Screenshot (Swappy)
#   5. Active Window Screenshot (Sway only, experimental)
#   6. Active Window Screenshot (Hyprland only, experimental)
#
# Dependencies:
# - Options 1-4:
#   - `zenity`: For the graphical dialog interface.
#   - `grim`: For taking screenshots.
#   - `slurp`: For selecting areas interactively.
#   - `swappy`: For editing screenshots.
# - Option 5 (Sway, experimental):
#   - `jq`: For parsing JSON output from `swaymsg`.
#   - `swaymsg`: For retrieving active window geometry.
# - Option 6 (Hyprland, experimental):
#   - `jq`: For parsing JSON output from `hyprctl`.
#   - `hyprctl`: Part of Hyprland, for retrieving active window geometry.

# Default save location and filename
# If swappy is used, the default save location and filename will be decided by ~/.config/swappy/config. Change that file accordingly!
#
default_save_dir=~/Pictures/screenshot
default_filename="screenshot-$(date +'%Y-%m-%d-%H-%M-%S').png"
mkdir -p "$default_save_dir"

# Function for full screen screenshot
take_full_screenshot() {
    file_path="$default_save_dir/$default_filename"
    grim "$file_path"
    echo "Screenshot saved to $file_path"
}

# Function for selected area screenshot
take_region_screenshot() {
    file_path="$default_save_dir/$default_filename"
    grim -g "$(slurp)" "$file_path"
    echo "Screenshot saved to $file_path"
}

# Function for full screen screenshot with Swappy
take_full_screenshot_swappy() {
    grim - | swappy -f -
}

# Function for selected area screenshot with Swappy
take_region_screenshot_swappy() {
    grim -g "$(slurp)" - | swappy -f -
}

# Function for active window screenshot (Sway)
take_active_window_screenshot_sway() {
    grim -g "$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | slurp)" - | swappy -f -
}

# Function for active window screenshot (Hyprland)
take_active_window_screenshot_hyprland() {
    rect=$(hyprctl activewindow -j | jq -r '.at | "\(.[0]),\(.[1]) \(.size[0])x\(.size[1])"')
    grim -g "$rect" - | swappy -f -
}

# Main zenity dialog for options
screenshot_type=$(zenity --height=500 --list --radiolist --title="Screenshot Tool" --text="Select an option" \
    --column="" --column="Screenshot Type" \
    TRUE "Full Screen Screenshot" \
    FALSE "Selected Area Screenshot" \
    FALSE "Full Screen Screenshot (Swappy)" \
    FALSE "Selected Area Screenshot (Swappy)" \
    FALSE "Active Window Screenshot (Sway)" \
    FALSE "Active Window Screenshot (Hyprland)")

# Execute based on user selection
case "$screenshot_type" in
    "Full Screen Screenshot")
        take_full_screenshot
        ;;
    "Selected Area Screenshot")
        take_region_screenshot
        ;;
    "Full Screen Screenshot (Swappy)")
        take_full_screenshot_swappy
        ;;
    "Selected Area Screenshot (Swappy)")
        take_region_screenshot_swappy
        ;;
    "Active Window Screenshot (Sway)")
        take_active_window_screenshot_sway
        ;;
    "Active Window Screenshot (Hyprland)")
        take_active_window_screenshot_hyprland
        ;;
    *)
        echo "No valid option selected."
        exit 1
        ;;
esac
