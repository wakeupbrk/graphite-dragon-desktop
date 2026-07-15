#!/usr/bin/env bash
# KDE port: read current layout from org.kde.keyboard instead of hyprctl
idx=$(busctl --user call org.kde.keyboard /Layouts org.kde.KeyboardLayouts getLayout 2>/dev/null | awk '{print $2}')
layout=$(busctl --user call org.kde.keyboard /Layouts org.kde.KeyboardLayouts getLayoutsList 2>/dev/null | \
    awk -F'"' -v n="${idx:-0}" '{ c=0; for (i=2;i<=NF;i+=2) { if (int(c/3) == n && c%3 == 0) { print $i; exit }; c++ } }')
[[ -z "$layout" || "$layout" == "null" ]] && layout="US"
echo "${layout:0:2}" | tr '[:lower:]' '[:upper:]'
