#!/bin/bash
# graphite-dragon-desktop installer
# Copies configs/scripts into place. Existing files are backed up as *.bak-gdd.
set -euo pipefail
cd "$(dirname "$0")"

say() { printf '\033[38;2;127;171;199m==>\033[0m %s\n' "$*"; }

backup() { [ -e "$1" ] && cp -r "$1" "$1.bak-gdd" && say "backed up $1 -> $1.bak-gdd" || true; }

say "Installing scripts to ~/.local/bin"
mkdir -p ~/.local/bin
install -m 755 bin/vinylctl bin/starwars-scene bin/panel-fastfetch.sh ~/.local/bin/

say "Installing PipeWire equalizer sink (vinylctl EQ)"
mkdir -p ~/.config/pipewire/pipewire.conf.d
cp config/pipewire/pipewire.conf.d/vinylctl-eq.conf ~/.config/pipewire/pipewire.conf.d/
systemctl --user restart pipewire wireplumber 2>/dev/null || true
sleep 2
eqid=$(pw-dump 2>/dev/null | python3 -c 'import json,sys
print(next((o["id"] for o in json.load(sys.stdin)
  if ((o.get("info") or {}).get("props") or {}).get("node.name")=="vinylctl_eq"), ""))' || true)
if [ -n "$eqid" ]; then
    wpctl set-default "$eqid" && say "vinylctl_eq set as default sink (audio now routes through the EQ)"
else
    say "note: vinylctl_eq sink not found yet — set it as default sink after next login (wpctl set-default <id>)"
fi

say "Installing kitty panel configs"
mkdir -p ~/.config/kitty/panels
cp config/kitty/panels/*.conf ~/.config/kitty/panels/
if [ ! -e ~/.config/kitty/kitty.conf ]; then
    cp config/kitty/kitty.conf ~/.config/kitty/kitty.conf
else
    cp config/kitty/kitty.conf ~/.config/kitty/kitty.conf.gdd-example
    say "kept your kitty.conf; example saved as kitty.conf.gdd-example"
fi

say "Installing fastfetch / cava / btop configs"
backup ~/.config/fastfetch; mkdir -p ~/.config/fastfetch/assets
cp config/fastfetch/config.jsonc ~/.config/fastfetch/
cp config/fastfetch/assets/dragon.png ~/.config/fastfetch/assets/
sed -i "s|__HOME__|$HOME|g" ~/.config/fastfetch/config.jsonc
backup ~/.config/cava/config; mkdir -p ~/.config/cava
cp config/cava/config ~/.config/cava/
mkdir -p ~/.config/btop/themes
cp config/btop/themes/graphite.theme ~/.config/btop/themes/
[ -e ~/.config/btop/btop.conf ] || cp config/btop/btop.conf ~/.config/btop/

say "Installing autostart entries"
mkdir -p ~/.config/autostart
for f in autostart/panel-*.desktop; do
    sed "s|__HOME__|$HOME|g" "$f" > ~/.config/autostart/"$(basename "$f")"
done

say "Installing KWin minimize effect (kremadive)"
mkdir -p ~/.local/share/kwin/effects
cp -r kwin/effects/kwin4_effect_kremadive ~/.local/share/kwin/effects/
kwriteconfig6 --file kwinrc --group Plugins --key kwin4_effect_kremadiveEnabled true
kwriteconfig6 --file kwinrc --group Plugins --key squashEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key magiclampEnabled false

say "Installing wallpaper"
mkdir -p ~/.local/share/wallpapers
cp wallpaper/graphite-steel.png ~/.local/share/wallpapers/

if [ ! -e ~/.config/kwinrulesrc ]; then
    say "Installing KWin window rules (panel geometry)"
    cp kwin/kwinrulesrc ~/.config/kwinrulesrc
else
    say "SKIPPED KWin rules: you already have ~/.config/kwinrulesrc."
    say "  Merge the rules from kwin/kwinrulesrc manually (see docs/TUTORIAL.md §5)"
    say "  and adapt the geometry to your screen resolution."
fi

qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true

say "Done. Remaining manual steps (see docs/TUTORIAL.md):"
echo "  1. Install packages:  sudo dnf install kitty btop cava fastfetch playerctl"
echo "  2. Install unimatrix: pipx install git+https://github.com/will8211/unimatrix"
echo "  3. Optional dock:     sudo dnf copr enable isac322/krema && sudo dnf install krema"
echo "  4. Optional player backend extras: sudo dnf install mpd mpc yt-dlp  (for rmpc)"
echo "  5. Set the wallpaper, icon theme (WhiteSur-dark) and top panel per the tutorial."
echo "  6. Log out/in (or start the panels once by hand) to see it come alive."
