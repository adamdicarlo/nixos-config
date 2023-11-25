#!/bin/sh

if pgrep wf-recorder; then
	killall wf-recorder
	exit 0
fi

if area=$(slurp -d -f '{"w":%W,"h":%H,"x":%X,"y":%Y}'); then
	if info=$(swaymsg -t get_outputs); then
		output_x=$(echo $info | jq '.[0].rect.x')
		output_y=$(echo $info | jq '.[0].rect.y')
	elif info=$(hyprctl monitors -j); then
		output_x=$(echo $info | jq '.[0].x')
		output_y=$(echo $info | jq '.[0].y')
	else
		notify-send --transient -t 3000 "Failed to get screen info from swaymsg and hyprctl"
		exit 1
	fi
	scale=$(echo $info | jq '.[0].scale')
	output_name=$(echo $info | jq -r '.[0].name')
	x=$(echo $area | jq .x*$scale+$output_x)
	y=$(echo $area | jq .y*$scale+$output_y)
	w=$(echo $area | jq .w*$scale)
	h=$(echo $area | jq .h*$scale)
	area="${x},${y} ${w}x${h}"
	notify-send --transient -t 500 "Recording $output_name" "2"
	sleep 1
	notify-send --transient -t 500 "Recording $output_name" "1"
	sleep 1
	notify-send --transient -t 300 "Recording $output_name" "NOW"
	sleep 0.350
	stamp=$(date +%Y%m%d-%H%M%S)
	target="$HOME/Sync/GIFs/$stamp-screen.gif"
	exec sh -c "wf-recorder -o \"$output_name\" --codec gif -g \"$area\" -r 12 -f \"$target\"; \
        notify-send -t 4000 'Saved screen recording' \"$target - putting in clipboard\"; \
        wl-copy \"$target\""
else
	notify-send --transient -t 2000 "Canceled screen recording"
fi
