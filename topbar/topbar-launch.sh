#!/usr/bin/env bash
# Launches the quickshell top bar with the graphite-ice palette
# (matches kitty panels: pure black bg + icy blue monochrome text).

# Palette now lives in qs_palette.sh (per-desktop variants); default to Main
"$(dirname "${BASH_SOURCE[0]}")/qs_palette.sh" 1

pkill -x quickshell 2>/dev/null
sleep 0.3
exec quickshell -p "$HOME/.config/hypr/scripts/quickshell/Shell.qml"
