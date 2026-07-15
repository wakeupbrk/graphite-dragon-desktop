#!/usr/bin/env bash
# Sets the wallpaper for the active desktop (1-4). Plasma has no native
# per-virtual-desktop wallpaper, so workspaces.sh calls this on every
# desktop switch — the wallpaper follows you around.

n="${1:-1}"
case "$n" in
    2) img="$HOME/.local/share/wallpapers/graphite-steel-mint.png" ;;
    3) img="$HOME/.local/share/wallpapers/graphite-steel-violet.png" ;;
    4) img="$HOME/.local/share/wallpapers/graphite-steel-amber.png" ;;
    *) img="$HOME/.local/share/wallpapers/graphite-steel.png" ;;
esac

# Skip the (slow) plasmashell call when nothing would change
STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/quickshell"
mkdir -p "$STATE_DIR"
[ "$(cat "$STATE_DIR/current_wallpaper" 2>/dev/null)" = "$img" ] && exit 0
echo "$img" > "$STATE_DIR/current_wallpaper"

qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
for (var i in desktops()) {
    var d = desktops()[i];
    d.wallpaperPlugin = 'org.kde.image';
    d.currentConfigGroup = ['Wallpaper', 'org.kde.image', 'General'];
    d.writeConfig('Image', 'file://$img');
}" >/dev/null 2>&1
