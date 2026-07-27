#!/bin/bash
set -euo pipefail

# This script is used to show the Mark Menu
# Need script: hm-general.sh, hm-theme.sh, hm-setting.sh

# Change markimaku to your username if you want to access quickly in VS Code
# Access: file:///home/markimaku/.local/bin/hm-general.sh
# Access: file:///home/markimaku/.local/bin/hm-theme.sh
# Access: file:///home/markimaku/.local/bin/hm-setting.sh

rofi -show "󰮫 General" \
  -p "Mark Menu - Search" \
  -i \
  -modes "󰮫 General:~/.local/bin/hm_general.sh, Theme:~/.local/bin/hm_theme.sh, Setting:~/.local/bin/hm_setting.sh"