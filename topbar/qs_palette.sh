#!/usr/bin/env bash
# Writes the top-bar palette for a given desktop (1-4) to /tmp/qs_colors.json.
# MatugenColors.qml polls that file every second, so the bar recolors live.
# Same graphite-black base everywhere; the accent family shifts per desktop:
#   1 Main = ice blue, 2 Work = steel mint, 3 Fun = violet, 4 Lab = amber.

n="${1:-1}"

case "$n" in
    2) # Work — steel mint
        text="#b0ffd8"; sub0="#6fc8a0"; sub1="#8fe8c0"
        ov0="#3aa87c";  ov1="#4ad89c";  ov2="#6fe8b8"
        blue="#7fffc8"; sapphire="#3fbf8f"; peach="#9fffd8"
        mauve="#b0ffd8"; pink="#c0ffe8"; yellow="#e0fff0"
        maroon="#9fffd8"; teal="#a0ffe0"
        ;;
    3) # Fun — violet
        text="#ddc8ff"; sub0="#9f88d8"; sub1="#bfa8e8"
        ov0="#7a5ac8";  ov1="#9a7ae8";  ov2="#b89fff"
        blue="#c9a8ff"; sapphire="#8f6fd8"; peach="#dfc0ff"
        mauve="#ddc8ff"; pink="#eed8ff"; yellow="#f7f0ff"
        maroon="#dfc0ff"; teal="#e0d0ff"
        ;;
    4) # Lab — amber
        text="#ffe8c0"; sub0="#c8a86f"; sub1="#e8c88f"
        ov0="#a87c3a";  ov1="#d89c4a";  ov2="#e8b86f"
        blue="#ffcf7f"; sapphire="#bf8f3f"; peach="#ffdf9f"
        mauve="#ffe8c0"; pink="#ffeed8"; yellow="#fff7e0"
        maroon="#ffdf9f"; teal="#ffe0a0"
        ;;
    *) # Main — ice blue
        text="#b0e0ff"; sub0="#6fa8c8"; sub1="#8fc8e8"
        ov0="#3a7ca8";  ov1="#4a9fd8";  ov2="#6fbfe8"
        blue="#7fcfff"; sapphire="#4a9fd8"; peach="#9fdfff"
        mauve="#b0e0ff"; pink="#c0eeff"; yellow="#e0f7ff"
        maroon="#9fdfff"; teal="#a0e0ff"
        ;;
esac

cat > /tmp/qs_colors.json.tmp <<EOF
{
  "base":     "#050a0e",
  "mantle":   "#020507",
  "crust":    "#000000",
  "text":     "$text",
  "subtext0": "$sub0",
  "subtext1": "$sub1",
  "surface0": "#0e1a24",
  "surface1": "#16293a",
  "surface2": "#204058",
  "overlay0": "$ov0",
  "overlay1": "$ov1",
  "overlay2": "$ov2",
  "blue":     "$blue",
  "sapphire": "$sapphire",
  "peach":    "$peach",
  "green":    "#a8f0d0",
  "red":      "#ff9fb0",
  "mauve":    "$mauve",
  "pink":     "$pink",
  "yellow":   "$yellow",
  "maroon":   "$maroon",
  "teal":     "$teal"
}
EOF
mv /tmp/qs_colors.json.tmp /tmp/qs_colors.json
