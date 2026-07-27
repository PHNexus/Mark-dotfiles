#!/usr/bin/env bash

WALL_DIR="$HOME/Pictures/Wallpapers"
CACHE_FILE="$HOME/.cache/current_wallpaper"

list_walls() {
    cd "$WALL_DIR" || exit
    for file in *.{jpg,jpeg,png,gif}; do
        [[ -e "$file" ]] || continue
        echo -en "$file\0icon\x1f$WALL_DIR/$file\n"
    done
}

set_wallpaper() {
    local wall="$1"
    echo "$wall" > "$CACHE_FILE"
    awww img "$wall" \
        --transition-type random \
        --transition-step 90 \
        --transition-fps 60
}

# Menu Rofi configurado para miniaturas maiores em formato de grade
CHOICE=$(list_walls | rofi -dmenu -i -p "Select Wallpaper" \
    -theme-str '
        window { width: 60%; }
        listview { columns: 4; lines: 3; spacing: 10px; }
        element { orientation: vertical; padding: 10px; }
        element-icon { size: 120px; horizontal-align: 0.5; }
        element-text { horizontal-align: 0.5; }
        entry { placeholder: "Search..."; }
    ')

[[ -z "$CHOICE" ]] && exit 0

set_wallpaper "$WALL_DIR/$CHOICE"
