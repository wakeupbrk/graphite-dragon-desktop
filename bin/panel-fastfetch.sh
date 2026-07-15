#!/bin/bash
# Draw the full fastfetch (dragon logo image) ONCE, then every 5s repaint only
# the text block in place — no clear, no image retransmission (that caused a
# visible flash), and the cursor stays hidden (it showed as a dot on the left).
# Text column = logo width 30 + right padding 2 + 1 (fastfetch config.jsonc).
COL=33

printf '\e[?25l'
trap 'printf "\e[?25h"' EXIT
clear
fastfetch

while sleep 5; do
    i=1
    while IFS= read -r line; do
        printf '\e[%d;%dH%s\e[K' "$i" "$COL" "$line"
        ((i++))
    done < <(fastfetch --logo none)
    # wipe a few rows below in case the text block got shorter
    for j in 0 1 2; do printf '\e[%d;%dH\e[K' "$((i + j))" "$COL"; done
done
