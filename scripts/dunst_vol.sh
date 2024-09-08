#!/usr/bin/env bash

# See README.md for usage instructions
volume_step=2
brightness_step=5
max_volume=100
notification_timeout=1000
download_album_art=true
show_album_art=true
show_music_in_volume_indicator=true
brightness_file="$HOME/.config/sparrow/.brightness"

function get_brightness {
    if [ -f "$brightness_file" ] ; then
        cat "$brightness_file"
    else
        echo 50
    fi
}

# Returns a mute icon, a volume-low icon, or a volume-high icon, depending on the volume
function get_brightness_icon {
    brightness=$(get_brightness)
    if [ "$brightness" -lt 50 ]; then
        brightness_icon="🔅"
    else
        brightness_icon="🔆"
    fi
}

# Displays a brightness notification
function show_brightness_notif {
    # Get brightness icon
    get_brightness_icon
    # Make the bar with the special character ─ (it's not dash -)
    # https://en.wikipedia.org/wiki/Box-drawing_character
    bar=$(seq -s "─" $(($brightness / 5)) | sed 's/[0-9]//g')

    # notify-send -t $notification_timeout -h string:x-dunst-stack-tag:volume_notif -h int:value:$volume "$volume_icon $volume%"
    # dunstify -h string:x-dunst-stack-tag:vol-ind "" ""
    dunstify -t $notification_timeout -h string:x-dunst-stack-tag:brightness_notif -h int:value:$brightness "$brightness_icon $brightness%"
}

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
    brightness_up)
        light -s sysfs/backlight/amdgpu_bl2 -N 0
        new_brightness=$(($(get_brightness) + brightness_step))
        light -s sysfs/backlight/amdgpu_bl2 -S $new_brightness
        echo $new_brightness > $brightness_file
        show_brightness_notif
    ;;

    brightness_down)
        light -s sysfs/backlight/amdgpu_bl2 -N 0
        new_brightness=$(($(get_brightness) - brightness_step))
        light -s sysfs/backlight/amdgpu_bl2 -S $new_brightness
        echo $new_brightness > $brightness_file
        show_brightness_notif
    ;;
        
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
