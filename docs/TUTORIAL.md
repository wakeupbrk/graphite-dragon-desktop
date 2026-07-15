# Full setup tutorial

This walks through the whole desktop from a fresh Fedora Asahi (KDE Plasma 6 / Wayland) install. Skim §1–§2 if you only want the panels; §5 is the part everyone gets wrong.

## Layout at a glance

```
┌──────────────────────────┬──────────────────────────────┐
│                          │  btop  (interactive)         │
│  fastfetch + dragon      │                              │
│  (static, in-place       ├──────────┬───────────────────┤
│   text refresh)          │          │ vinylctl player   │
├──────────────────────────┤ unimatrix│ (interactive)     │
│                          │  rain    ├───────────────────┤
│  cava bars               │          │ starwars battle   │
└──────────────────────────┴──────────┴───────────────────┘
        + auto-hiding krema dock at bottom-center
```

Reference geometry (logical px, 1789×1112 screen at 1.7× scale — **adapt to yours**, §5):

| panel | class | position | size | focusable |
|---|---|---|---|---|
| fastfetch | `fastfetch-panel` | 0,30 | 889×600 | no |
| cava | `cava-panel` | 0,650 | 889×462 | no |
| btop | `btop-panel` | 929,45 | 860×511 | yes |
| unimatrix | `unimatrix-panel` | 889,571 | 355×541 | no |
| media | `media-panel` | 1244,571 | 534×290 | yes |
| starwars | `starwars-panel` | 1244,861 | 534×251 | no |

## 1. Packages

```bash
sudo dnf install kitty btop cava fastfetch playerctl quickshell inotify-tools
pipx install git+https://github.com/will8211/unimatrix
```

Install a Nerd Font (the configs use JetBrains Mono Nerd Font) and select it in kitty.

Optional extras:

```bash
# krema dock (COPR)
sudo dnf copr enable isac322/krema && sudo dnf install krema
# local-library music player backend (vinylctl works without this)
sudo dnf install mpd mpc yt-dlp
```

## 2. Theme

- **Wallpaper**: `wallpaper/graphite-steel.png` → right-click desktop → Configure.
- **Icons**: [WhiteSur-dark](https://github.com/vinceliuice/WhiteSur-icon-theme) (macOS Big Sur style), user-level install, then apply in System Settings.
- **Top bar**: the quickshell bar (see §10) replaces the old 30 px Plasma panel — delete any top Plasma panel or the two will stack.
- **Terminal palette**: `config/kitty/panels/graphite-theme.conf` — steel/ice colors, `background_opacity 0` so panels float directly on the wallpaper. All six panel configs include it.
- **btop**: theme `graphite` (included). **cava**: chunky 4-wide bars, Monstercat smoothing, 8-step gradient from deep steel to bright ice tips (included).

## 3. The panels

Each panel is a plain kitty window with a unique `--class`, launched by an autostart entry:

```
kitty --class fastfetch-panel --config ~/.config/kitty/panels/fastfetch.conf ~/.local/bin/panel-fastfetch.sh
kitty --class cava-panel      --config ~/.config/kitty/panels/cava.conf      cava
kitty --class btop-panel      --config ~/.config/kitty/panels/btop.conf      btop
kitty --class unimatrix-panel --config ~/.config/kitty/panels/unimatrix.conf unimatrix
kitty --class media-panel     --config ~/.config/kitty/panels/media.conf     ~/.local/bin/vinylctl
kitty --class starwars-panel  --config ~/.config/kitty/panels/starwars.conf  ~/.local/bin/starwars-scene
```

`install.sh` sets up the `~/.config/autostart/panel-*.desktop` files for you. To (re)start one by hand without logging out:

```bash
systemd-run --user --unit=panel-media -- kitty --class media-panel --config ~/.config/kitty/panels/media.conf ~/.local/bin/vinylctl
```

## 4. Panel gotchas we hit so you don't have to

- **Ligature fonts eat ASCII art.** JetBrains Mono renders the X-wing `>=o=>` as `≥o⇒`. The starwars kitty config sets `disable_ligatures always`.
- **Flicker-free fastfetch.** Don't loop `clear; fastfetch`. `panel-fastfetch.sh` draws the logo image once, hides the cursor (`\e[?25l` — a visible cursor shows up as a stray dot on the desktop), and thereafter repaints only the text lines in place with `fastfetch --logo none` + cursor addressing.
- **fastfetch image logos must be PNG32.** Palette PNGs get silently dropped. Clear `~/.cache/fastfetch` after swapping the logo.
- **Window sizes matter.** Give fastfetch a window that ends where its content ends — an oversized transparent window will sit behind the panel below it and tall cava bars will overlap its text.

## 5. KWin window rules (the load-bearing part)

Panels stay put thanks to per-class KWin rules: `kwin/kwinrulesrc` is the reference. For each `*-panel` class:

- **Position / Size: Force** (`positionrule=2` / `sizerule=2`). *Apply initially* is not enough — Meta+arrow tiling will happily resize your panels.
- **No titlebar and frame: Force**, **Skip taskbar / Skip pager: Apply initially**, **Keep below: Apply initially**.
- Display-only panels additionally get **Accept focus: Force off** (`acceptfocus=false`) so clicks can't land in them. The interactive ones (btop, media) must NOT have that.

Import: if you have no rules yet, `install.sh` copies the file; otherwise merge sections by hand (each `[uuid]` block is one rule, and the `[General]` `rules=` list + `count=` must include every block). Recalculate the position/size values for your screen's logical resolution, then:

```bash
qdbus org.kde.KWin /KWin reconfigure
```

Forced geometry applies live — windows snap into place without restarting.

## 6. vinylctl — the media deck

`bin/vinylctl`, pure Python 3 + `playerctl` + `wpctl`. It auto-selects whichever MPRIS player is *Playing* (Firefox/Chromium tabs, mpv, mpd via mpd-mpris, ...), draws a spinning vinyl in half-block pixels, and gives you:

| input | action |
|---|---|
| `space` / click the disc | play/pause |
| `n` / `b` | next / previous |
| `←` `→` / click progress bar | seek |
| `↑` `↓` / scroll / click volume bar | system volume (PipeWire default sink) |
| `m` | mute |
| `tab` | cycle between players |
| `q` | quit |

Notes: seek/skip depend on what the player exposes over MPRIS (YouTube: everything; some sites: pause only). Volume is always the system sink, so it works even for players with no MPRIS volume. Colors are hardcoded near the top of the script — one palette block to re-skin it.

## 7. starwars-scene — the battle

`bin/starwars-scene`. Three X-wings vs four TIE fighters, sinusoidal flight paths, cooldown-based laser fire, hit detection, 6-frame explosions, respawns; parallax starfield behind. Tunables at the top of `main()`: fleet sizes, `FPS`, fire cooldown ranges. It's display-only — pair it with the no-focus KWin rule.

## 8. krema dock (optional)

`config/kremarc` is the reference config: bottom edge, auto-hide (`VisibilityMode=1`), zoom 1.4 / spacing 16 (the max overlap-free combo at IconSize 34 — krema scales icons in place, bigger zoom overlaps), tint `#14161a`.

Upstream krema had a vertical-dock hit-test bug, fixed in [PR #11](https://github.com/isac322/krema/pull/11). This setup also runs a personal patch (a small dragon "peek button" at bottom-center while the dock is hidden — hover it to reveal the dock; implemented in the dock's `main.qml` plus a 72×40 peek rect in `inputregion.cpp`'s hidden input region). That patch is decorative and not required for anything else here.

If you replace the running krema binary: plain `cp` fails silently with ETXTBSY. `sudo rm` the file first, then copy, and verify with `md5sum`.

## 9. Minimize animation (kremadive)

KDE's squash/magic-lamp minimize effects need the *taskbar icon geometry* of each window, which taskbars publish via the Plasma window-management protocol. krema (and many standalone docks) don't publish it — the effects then silently do nothing and windows vanish instantly.

`kwin/effects/kwin4_effect_kremadive` is a scripted KWin effect that animates scale + fade + position toward the bottom-center of the screen (where the dock lives) with cubic easing, minimize and restore. `install.sh` installs and enables it, and disables squash/magiclamp so they don't fight.

Plasma 6 API note if you hack on it: `effects.windowMinimized` no longer exists — connect to each window's `minimizedChanged` signal from `effects.windowAdded` (and walk `effects.stackingOrder` for pre-existing windows).

Verify a window's icon geometry yourself (helps debug *any* dock):
run a KWin script that reads `window.iconGeometry` — `0,0 0x0` means your dock doesn't publish it.

## 10. Quickshell top bar (KWin port)

`install.sh` clones [ilyamiro/nixos-configuration](https://github.com/ilyamiro/nixos-configuration) (pinned commit), copies its `scripts/` tree to `~/.config/hypr/scripts/` (paths are hardcoded in the QML — don't rename), applies `topbar/kwin-port.patch`, and drops in our KWin-native replacements:

- `workspaces.sh` — desktops from `org.kde.KWin /VirtualDesktopManager` (busctl + dbus-monitor), same JSON contract as upstream
- `kb_fetch.sh` — keyboard layout from `org.kde.keyboard`
- `qs_palette.sh <1-4>` — writes `/tmp/qs_colors.json` (the bar polls it every 1 s); per-desktop palettes: 1 ice / 2 mint / 3 violet / 4 amber
- `topbar-launch.sh` + `qs-topbar.service` — autostart via systemd user unit
- `qs_wallpaper.sh <1-4>` — per-desktop wallpapers (hue-shifted variants of graphite-steel: mint/violet/amber); Plasma has no per-virtual-desktop wallpaper, so the switch daemon swaps it as you move
- App routing: `kwin/kwinrulesrc` ends with a rule sending media apps (`spotify|spotube|noutube`, regex wmclass) to the Fun desktop. **Desktop UUIDs are machine-specific** — after creating your 4 desktops, replace the `desktops=` value with your Fun desktop's UUID from `busctl --user get-property org.kde.KWin /VirtualDesktopManager org.kde.KWin.VirtualDesktopManager desktops`

Gotchas we hit:
- The bar's `exclusiveZone` must be `barHeight + margins`, or windows tuck under the floating bar (patched).
- Writing KWin's `current` desktop property over D-Bus emits **no signal** — switch via `qdbus org.kde.kglobalaccel /component/kwin invokeShortcut "Switch to Desktop N"` instead, or nothing that listens for `currentChanged` will notice.
- Never `pkill -f quickshell` from a script — it self-matches the invoking shell. Use `pkill -x quickshell`.
- The upstream zombie-killer in `workspaces.sh` kills any process whose cmdline contains "workspaces.sh", including your terminal; our version skips the ancestor PID chain.
- Window animations that fit the vibe: `fallapart` and `wobblywindows` **off**, `scale` + `maximize` + `fadingpopups` **on** (install.sh sets these).

## 11. Troubleshooting

- **Panels in the wrong place after a resolution/scale change** → recalc rule geometry (§5), `qdbus org.kde.KWin /KWin reconfigure`.
- **A stray bright dot on the desktop** → some panel's terminal cursor is visible; make the panel app hide it (`\e[?25l`).
- **vinylctl shows "nothing playing"** → `playerctl -l` must list a player; browsers only register MPRIS while a tab has media.
- **Album-art/battle glyphs look wrong** → Nerd Font missing or ligatures enabled (§4).
- **Effect didn't load** → `journalctl -b | grep kremadive` shows JS errors with line numbers; `qdbus org.kde.KWin /Effects org.kde.kwin.Effects.loadEffect kwin4_effect_kremadive` returns `true`/`false`.
