#!/usr/bin/env bash

whole_screen=$(mktemp /tmp/grim-swappy-whole.XXXXXXXX.png)
cropped=$(mktemp /tmp/grim-swappy-cropped.XXXXXXXX.png)
grim -c -l 1 "$whole_screen"
imv -f "$whole_screen" &
imv_pid=$!

sleep 0.2

if area=$(slurp -d -f '{"w":%W,"h":%H,"x":%X,"y":%Y}'); then
    scale=$((swaymsg -t get_outputs || hyprctl monitors -j) | jq '.[0].scale')
    x=$(echo $area | jq .x*$scale)
    y=$(echo $area | jq .y*$scale)
    w=$(echo $area | jq .w*$scale)
    h=$(echo $area | jq .h*$scale)
    imv_area="${w}x${h}+${x}+${y}"
    imv-msg $imv_pid quit
    convert $whole_screen -crop "$imv_area" +repage "$cropped"
    stamp=$(date +%Y%m%d-%H%M%S)
    swappy -f $cropped --output-file $HOME/Sync/Screenshots/$stamp.png &!
else
    notify-send --transient -t 2000 "Canceled screenshot"
    imv-msg $imv_pid quit
fi
