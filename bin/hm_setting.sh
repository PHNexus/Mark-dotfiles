#!/bin/bash

spawn() { ( "$@" & ) >/dev/null 2>&1; disown; }

if [[ $# -eq 0 ]]; then
    cat <<'EOF'
󰖩  Wifi
󰂯  Bluetooth
  Disk Manager
󰋊  Storage Manager
󰓃  Audio Control
  MarkMenu General Tab
  MarkMenu Theme Tab
  MarkMenu Setting Tab
EOF
    exit 0
fi

chosen="$*"
case "$chosen" in
    *"Wifi"*) spawn nm-connection-editor ;;
    *"Bluetooth"*) spawn blueman-manager ;;
    *"Disk Manager"*) spawn gparted ;;
    *"Storage Manager"*) spawn kitty --class ncdu -e sudo ncdu / ;;
    *"Audio Control"*) spawn pavucontrol ;;
    *"MarkMenu General Tab"*) spawn code $HOME/.local/bin/hm_general.sh ;;
    *"MarkMenu Theme Tab"*) spawn code $HOME/.local/bin/hm_theme.sh ;;
    *"MarkMenu Setting Tab"*) spawn code $HOME/.local/bin/hm_setting.sh ;;
esac

exit 0