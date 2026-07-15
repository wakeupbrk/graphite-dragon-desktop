#!/usr/bin/env bash

# KWin (Plasma 6 / Wayland) port of the original Hyprland workspaces daemon.
# Emits the same JSON the TopBar expects: [{id, state, tooltip}, ...]
# States: "active" | "empty" ("occupied" needs KWin scripting; not tracked yet).

source "$(dirname "${BASH_SOURCE[0]}")/caching.sh"
qs_ensure_cache "workspaces"

# Zombie prevention: kill older instances left behind by Quickshell reloads.
# Skip our own ancestor chain so invoking shells aren't murdered.
ancestors=" $$ "
p=$PPID
while [ "$p" -gt 1 ] 2>/dev/null; do
    ancestors="$ancestors$p "
    p=$(awk '{print $4}' "/proc/$p/stat" 2>/dev/null) || break
done
for pid in $(pgrep -f "workspaces.sh"); do
    case "$ancestors" in
        *" $pid "*) ;;
        *) kill -9 "$pid" 2>/dev/null ;;
    esac
done

cleanup() {
    pkill -P $$ 2>/dev/null
}
trap cleanup EXIT SIGTERM SIGINT

VDM_DEST="org.kde.KWin"
VDM_PATH="/VirtualDesktopManager"
VDM_IFACE="org.kde.KWin.VirtualDesktopManager"

print_workspaces() {
    # desktops property: a(uss) -> position, uuid, name
    local raw current
    raw=$(timeout 2 busctl --user get-property "$VDM_DEST" "$VDM_PATH" "$VDM_IFACE" desktops 2>/dev/null)
    current=$(timeout 2 busctl --user get-property "$VDM_DEST" "$VDM_PATH" "$VDM_IFACE" current 2>/dev/null | awk -F'"' '{print $2}')
    if [ -z "$raw" ] || [ -z "$current" ]; then return; fi

    # raw looks like: a(uss) 2 0 "uuid1" "Desktop 1" 1 "uuid2" "Desktop 2"
    echo "$raw" | awk -F'"' -v cur="$current" '
    {
        n = 0
        # quoted fields alternate: uuid, name, uuid, name, ...
        for (i = 2; i <= NF; i += 2) q[++n] = $i
    }
    END {
        printf "["
        for (j = 1; j <= n; j += 2) {
            uuid = q[j]; name = q[j+1]
            id = (j + 1) / 2
            state = (uuid == cur) ? "active" : "empty"
            printf "%s{\"id\":%d,\"state\":\"%s\",\"tooltip\":\"%s\"}", (j>1?",":""), id, state, name
        }
        printf "]\n"
    }' > "$QS_RUN_WORKSPACES/workspaces.tmp"

    mv "$QS_RUN_WORKSPACES/workspaces.tmp" "$QS_RUN_WORKSPACES/workspaces.json"

    # Recolor the bar for the active desktop (1 ice / 2 mint / 3 violet / 4 amber)
    local pos
    pos=$(echo "$raw" | awk -F'"' -v cur="$current" \
        '{ c=0; for (i=2;i<=NF;i+=2) { c++; if (c%2==1 && $i==cur) { print (c+1)/2; exit } } }')
    if [ -n "$pos" ]; then
        "$(dirname "${BASH_SOURCE[0]}")/qs_palette.sh" "$pos"
        "$(dirname "${BASH_SOURCE[0]}")/qs_wallpaper.sh" "$pos"
    fi
}

print_workspaces

# Event loop: react to KWin virtual-desktop signals, debounced
while true; do
    dbus-monitor --session "type='signal',interface='$VDM_IFACE'" 2>/dev/null | while read -r line; do
        case "$line" in
            *currentChanged*|*countChanged*|*desktopCreated*|*desktopRemoved*|*desktopDataChanged*)
                while read -t 0.05 -r _; do continue; done
                print_workspaces
                ;;
        esac
    done
    sleep 1
done
