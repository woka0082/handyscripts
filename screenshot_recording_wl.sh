#!/bin/bash
# Wayland Media Tool v7.1w - Pure Terminal Version
# Dependencies: grim, slurp, swappy, wf-recorder, maybe jq as well for sway and Hyprland

shot_dir=~/Pictures/Screenshots
vid_dir=~/Videos/Screen_Recordings
mkdir -p "$shot_dir" "$vid_dir"

get_shot_name() { echo "$shot_dir/screenshot-$(date +'%Y-%m-%d-%H-%M-%S').png"; }
get_vid_name() { echo "$vid_dir/record-$(date +'%Y-%m-%d-%H-%M-%S').mp4"; }

countdown() {
    echo -n "Starting in: "
    for i in {3..1}; do
        echo -n "$i... "
        sleep 1
    done
    echo "GO!"
}

while true; do
    clear
    echo "--- WAYLAND MEDIA TOOL ---"
    echo "1) Full Screen (Clean)    4) Full Screen (Swappy)"
    echo "2) Selected Area (Clean)  5) Selected Area (Swappy)"
    echo "3) Active Window (Clean)  6) Active Window (Swappy)"
    echo "----------------------------------------------------"
    echo "7) Record Full Screen     8) Record Selected Area"
    echo "0) Quit"
    echo "-----------------------"
    read -p "Choice [0-8]: " choice

    case $choice in
        1) # Full Clean
           file=$(get_shot_name)
           grim "$file"
           # grim "$file" && viewnior "$file" # <-- OPTION FOR VIEWNIOR
           echo "Saved: $file"; sleep 1 ;;
        
        2) # Area Clean
           file=$(get_shot_name)
           grim -g "$(slurp)" "$(get_shot_name)"
           echo "Saved: $file"; sleep 1 ;;
        
        3) # Active Clean (Wayland specific logic)
           file=$(get_shot_name)
           # Note: Requires 'jq' to parse window geometry on Sway/Hyprland
           if [ "$XDG_CURRENT_DESKTOP" = "sway" ]; then
               GEOM=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
           else
               # Fallback for Hyprland or others
               GEOM=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
           fi
           grim -g "$GEOM" "$file"
           echo "Saved: $file"; sleep 1 ;;

        4) # Full Swappy
           grim - | swappy -f - ;;

        5) # Area Swappy
           grim -g "$(slurp)" - | swappy -f - ;;

        6) # Active Swappy
           if [ "$XDG_CURRENT_DESKTOP" = "sway" ]; then
               GEOM=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
           else
               GEOM=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
           fi
           grim -g "$GEOM" - | swappy -f - ;;

        7|8) # Video Recording
            vid_file=$(get_vid_name)
            if [ "$choice" == "7" ]; then
                ARG="" # wf-recorder defaults to full screen
            else
                echo "Select area with mouse..."
                GEOM=$(slurp)
                [ -z "$GEOM" ] && continue
                ARG="-g $GEOM"
            fi

            countdown
            echo ">> RECORDING... Press 'q' or Ctrl+C in this terminal to stop <<"
            
            # --- AUDIO OPTION ---
            # To record audio, add: --audio=alsa_output.pci-0000_00_1f.3.analog-stereo.monitor
            # (Use 'pactl list sources' to find your Wayland audio node name)
            
            wf-recorder $ARG -f "$vid_file"
            
            echo "Video saved to $vid_dir"
            xdg-open "$vid_dir"
            sleep 2 ;;

        0) exit 0 ;;
        *) echo "Invalid option"; sleep 1 ;;
    esac
done
