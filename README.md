# 🐉 graphite-dragon-desktop

A graphite-steel terminal-panel desktop for **Fedora Asahi Linux (KDE Plasma / Wayland)** on Apple Silicon — six transparent kitty TUI panels floating on the wallpaper, a custom spinning-vinyl media controller, and an endless ASCII space battle.

![Desktop overview](screenshots/desktop.png)

## What you get

| Corner | Panel | What it is |
|---|---|---|
| top-left | **fastfetch** | System info beside a steel dragon, live-refreshing *without* flicker |
| top-right | **btop** | Full system monitor (interactive) |
| bottom-left | **cava** | Audio spectrum bars with a steel gradient |
| bottom-center-right | **unimatrix** | Matrix rain, katakana glyphs |
| right | **vinylctl** ★ | Custom MPRIS "now playing" deck — a vinyl record that actually spins |
| bottom-right | **starwars-scene** ★ | Custom looped X-wing vs TIE fighter battle |

★ = purpose-built for this setup, included in [`bin/`](bin/).

Everything is pinned into place by forced KWin window rules — panels never move, never take focus (except the interactive ones), never appear in the taskbar. A patched [krema](https://github.com/isac322/krema) dock with auto-hide and a custom KWin minimize animation (`kremadive`) round it out.

## Highlights

### 🎵 vinylctl — the media deck
![Media corner](screenshots/media-corner.png)

A ~350-line zero-dependency Python TUI that controls **whatever is playing anywhere** (browser tabs included) via MPRIS/playerctl:
- half-block-pixel vinyl that spins while music plays, stops on pause
- full mouse support: click the disc to pause, click the progress bar to seek, click/scroll the volume bar
- keyboard: `space` pause · `n`/`b` skip · `←`/`→` seek · `↑`/`↓` system volume (PipeWire) · `m` mute · `tab` cycle players

### ⚔️ starwars-scene — the forever war
X-wings vs TIE fighters over a drifting parallax starfield: lasers, explosions, respawns. Runs forever at 12 fps in its own non-focusable panel. (Requires `disable_ligatures always` in the kitty config — ship ASCII gets eaten by font ligatures otherwise. Included.)

### 🐲 fastfetch without the glitch
![Fastfetch dragon](screenshots/fastfetch-dragon.png)

The usual `watch fastfetch` loop re-transmits the logo image every cycle and flashes. [`bin/panel-fastfetch.sh`](bin/panel-fastfetch.sh) draws the image **once**, then repaints only the text lines in place every 5 s — live stats, zero flicker, hidden cursor.

### 🪟 kremadive — minimize animation without icon geometry
Docks that don't publish taskbar icon geometry (krema, many standalone docks) silently break KDE's squash/magic-lamp effects — windows just blink out. [`kwin/effects/kwin4_effect_kremadive`](kwin/effects/kwin4_effect_kremadive) is a scripted KWin effect that dives windows to the bottom-center dock instead, no icon geometry needed.

### More shots

| | |
|---|---|
| ![btop](screenshots/btop-corner.png) | ![cava](screenshots/cava-bars.png) |

## Install

```bash
git clone https://github.com/wakeupbrk/graphite-dragon-desktop
cd graphite-dragon-desktop
./install.sh
```

Then follow the manual steps it prints (packages, dock, wallpaper). **Read [docs/TUTORIAL.md](docs/TUTORIAL.md)** for the full walkthrough — including how to adapt the KWin panel geometry to your own screen resolution (the included rules are for a 1789×1112-logical / 3024×1890-physical display at 1.7× scale).

### Requirements

- KDE Plasma 6 on Wayland (tested on Fedora Asahi Remix 44, MacBook Pro M1 Pro)
- `kitty`, `btop`, `cava`, `fastfetch`, `playerctl`, PipeWire (`wpctl`)
- [`unimatrix`](https://github.com/will8211/unimatrix), a Nerd Font (JetBrains Mono NF)
- optional: [krema](https://github.com/isac322/krema) dock, `mpd`+[`rmpc`](https://github.com/mierak/rmpc) for a local-library player (configs in [`config/rmpc/`](config/rmpc/))

## License

MIT — see [LICENSE](LICENSE). The dragon artwork and wallpaper are personal assets; replace them with your own spirit animal if you fork the vibe.
