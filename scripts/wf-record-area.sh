#!/bin/sh

if pgrep wf-recorder; then
    killall wf-recorder
    exit 0
fi

if area=$(slurp -d -f '{"w":%W,"h":%H,"x":%X,"y":%Y}'); then
    info=$(swaymsg -t get_outputs | jq '.[0]')
    scale=$(echo $info | jq .scale)
    output_x=$(echo $info | jq .rect.x)
    output_y=$(echo $info | jq .rect.y)
    output_name=$(echo $info | jq -r .name)
    x=$(echo $area | jq .x*$scale+$output_x)
    y=$(echo $area | jq .y*$scale+$output_y)
    w=$(echo $area | jq .w*$scale)
    h=$(echo $area | jq .h*$scale)
    area="${x},${y} ${w}x${h}"
    echo $area
    echo $output_x, $output_y, $output_name
    notify-send --transient -t 500 "Recording" "2"
    sleep 1
    notify-send --transient -t 500 "Recording" "1"
    sleep 1
    notify-send --transient -t 300 "Recording" "NOW"
    sleep 0.350
    stamp=$(date +%Y%m%d-%H%M%S)
    target="$HOME/Sync/GIFs/$stamp-screen.gif"
    exec sh -c "wf-recorder -o \"$output_name\" --codec gif -g \"$area\" -r 12 -f \"$target\"; \
        notify-send -t 4000 'Saved screen recording' \"$target - putting in clipboard\"; \
        wl-copy \"$target\""
else
    notify-send --transient -t 2000 "Aborted screen recording"
fi
