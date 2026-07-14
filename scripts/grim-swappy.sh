#!/usr/bin/env bash

stamp=$(date +%Y%m%d-%H%M%S)
whole_screen=$(mktemp "/tmp/grim-swappy-${stamp}.XXXX.png")
output=$HOME/Sync/Screenshots/$stamp.png

# "Freeze" the screen by first capturing it, then showing it in fullscreen.
grim -c -l 1 "$whole_screen"
imv -f "$whole_screen" &
imv_pid=$!

sleep 0.2

# Let user select capture area.
if area=$(slurp -d -f '{"w":%W,"h":%H,"x":%X,"y":%Y}'); then
  # Calculate crop spec string, handling high-DPI outputs.
  scale=$( (swaymsg -t get_outputs || hyprctl monitors -j) | jq '.[0].scale')
  x=$(echo "$area" | jq ".x * $scale")
  y=$(echo "$area" | jq ".y * $scale")
  w=$(echo "$area" | jq ".w * $scale")
  h=$(echo "$area" | jq ".h * $scale")
  crop="${w}x${h}+${x}+${y}"

  imv-msg $imv_pid quit
  rm "$whole_screen"
  magick "$whole_screen" -crop "$crop" +repage "$output"
  notify-send --transient -t 2000 "Saved: $output"

  exec swappy -f "$output" --output-file "$output"
else
  notify-send --transient -t 2000 "Canceled screenshot"
  imv-msg $imv_pid quit
  rm "$whole_screen"
fi
