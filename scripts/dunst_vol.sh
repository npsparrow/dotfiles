#!/usr/bin/env bash

# See README.md for usage instructions
volume_step=5
brightness_step=5
max_volume=100
notification_timeout=1000
download_album_art=true
show_album_art=true
show_music_in_volume_indicator=true

function get_volume {
    wpctl get-volume @DEFAULT_SINK@ | awk '{s=$2*100} {print s}'
}

function get_mute {
    wpctl get-volume @DEFAULT_SINK@ | grep '[MUTED]' -q && echo Muted || echo Unmuted
}

# Returns a mute icon, a volume-low icon, or a volume-high icon, depending on the volume
function get_volume_icon {
    volume=$(get_volume)
    mute=$(get_mute)
    if [ "$volume" -eq 0 ] || [ $mute = 'Muted' ] ; then
        volume_icon="󰝟"
    elif [ "$volume" -lt 50 ]; then
        volume_icon=""
    else
        volume_icon=""
    fi
}

# Displays a volume notification
function show_volume_notif {
    # Get vol icon
    get_volume_icon
    # Make the bar with the special character ─ (it's not dash -)
    # https://en.wikipedia.org/wiki/Box-drawing_character
    bar=$(seq -s "─" $(($volume / 5)) | sed 's/[0-9]//g')

    # notify-send -t $notification_timeout -h string:x-dunst-stack-tag:volume_notif -h int:value:$volume "$volume_icon $volume%"
    # dunstify -h string:x-dunst-stack-tag:vol-ind "" ""
    dunstify -t $notification_timeout -h string:x-dunst-stack-tag:volume_notif -h int:value:$volume "$volume_icon $volume%"
}

case $1 in
    volume_up)
        wpctl set-mute @DEFAULT_SINK@ 0
        volume=$(get_volume)
        if [ $(( "$volume" + "$volume_step" )) -gt $max_volume ]; then
            wpctl set-volume @DEFAULT_SINK@ $max_volume%
        else
            wpctl set-volume @DEFAULT_SINK@ 2%+
        fi
        show_volume_notif
    ;;

    volume_down)
        wpctl set-mute @DEFAULT_SINK@ 0
        wpctl set-volume @DEFAULT_SINK@ 2%-
        show_volume_notif
    ;;

    volume_mute)
        wpctl set-mute @DEFAULT_SINK@ toggle
        show_volume_notif
    ;;
esac
