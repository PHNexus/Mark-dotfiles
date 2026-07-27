#!/bin/bash
set -euo pipefail

REPO_DIR="$HOME/mark-dotfiles"
CONFIG_DIR="$REPO_DIR/config"
SCRIPTS_DIR="$REPO_DIR/bin"

CONFIG_FOLDERS=(
    "icons" "themes"
    "btop" "cava" "fastfetch" "gtk-3.0" "gtk-4.0"
    "hypr" "kitty" "mpv" "rofi"
    "swaync" "waybar" "xdg-desktop-portal" "xfce4"
)

msg()  { echo -e "\033[1;34m[INFO]\033[0m $1"; }
ok()   { echo -e "\033[1;32m[ OK ]\033[0m $1"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $1"; }
err()  { echo -e "\033[1;31m[ERR ]\033[0m $1"; exit 1; }

shopt -s nullglob

[[ -d "$REPO_DIR" ]] || err "Directory $REPO_DIR not found."
cd "$REPO_DIR" || err "Cannot access $REPO_DIR."

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    err "Not a valid Git repository."
fi

msg "Copying configurations..."
if [[ -d "$HOME/Pictures/Wallpapers" ]]; then
    mkdir -p "$REPO_DIR/wallpapers"
    rsync -a --delete "$HOME/Pictures/Wallpapers/" "$REPO_DIR/wallpapers/"
    ok "Wallpapers: synced"
fi
if [[ -d "$HOME/.icons" ]]; then
    mkdir -p "$REPO_DIR/icons"
    rsync -a --delete "$HOME/.icons/" "$REPO_DIR/icons/"
    ok "Icons: synced"
fi

if [[ -d "$HOME/.themes" ]]; then
    mkdir -p "$REPO_DIR/themes"
    rsync -a --delete "$HOME/.themes/" "$REPO_DIR/themes/"
    ok "Themes: synced"
fi
for folder in "${CONFIG_FOLDERS[@]}"; do
    if [[ -d "$HOME/.config/$folder" ]]; then
        mkdir -p "$CONFIG_DIR/$folder"
        if [[ -n "$(ls -A "$HOME/.config/$folder" 2>/dev/null)" ]]; then
            rsync -a --delete "$HOME/.config/$folder/" "$CONFIG_DIR/$folder/"
            ok "Config: $folder"
        else
            warn "Folder $folder is empty, copying without --delete"
            rsync -a "$HOME/.config/$folder/" "$CONFIG_DIR/$folder/"
        fi
    else
        warn "Folder not found: $folder"
    fi
done

if [[ -d "$HOME/.config/niri" ]]; then
    mkdir -p "$REPO_DIR/niri/config/niri"
    if [[ -n "$(ls -A "$HOME/.config/niri" 2>/dev/null)" ]]; then
        rsync -a --delete "$HOME/.config/niri/" "$REPO_DIR/niri/config/niri/"
        ok "Config: niri"
    else
        warn "Niri config is empty, copying without --delete"
        rsync -a "$HOME/.config/niri/" "$REPO_DIR/niri/config/niri/"
    fi
else
    warn "Folder not found: niri"
fi

if [[ -d "$SCRIPTS_DIR" ]]; then
    msg "Updating scripts..."
    for script in "$SCRIPTS_DIR"/*; do
        [[ -f "$script" ]] || continue
        name="$(basename "$script")"
        if [[ -f "$HOME/.local/bin/$name" ]]; then
            cp -f "$HOME/.local/bin/$name" "$script"
            ok "Script: $name"
        else
            warn "Script not found in system: $name"
        fi
    done
fi

msg "Copying home files..."
for file in .bashrc .zshrc .gitconfig; do
    if [[ -f "$HOME/$file" ]]; then
        cp -f "$HOME/$file" "$REPO_DIR/"
        ok "File: $file"
    fi
done

msg "Pushing to GitHub..."
if git diff --quiet && git diff --cached --quiet; then
    warn "No changes to commit."
else
    git add .
    git commit -m "Sync: $(date '+%Y-%m-%d %H:%M')" || warn "Empty commit."
fi

if git pull --rebase origin main 2>/dev/null; then
    git push origin main && ok "Push successful."
else
    git rebase --abort 2>/dev/null || true
    err "Pull/push failed. Rebase aborted. Check your connection."
fi

ok "Sync complete."
