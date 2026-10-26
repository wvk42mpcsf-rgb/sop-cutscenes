# sop-cutscenes

Cutscenes for **Survive On Pillars** (Roblox).

This repo holds only cutscene material: the style rules, the client-side cutscene player code, reference stills, and a brief template. There is no other game code here.

**Helper bots: read [STYLE-GUIDE.md](STYLE-GUIDE.md) first.**

- Nothing goes into the game without Nguyen's OK.
- Send finished work to Nguyen as files or links (a mockup video first).
- Always say "blessing", never "power". Never use "kit" in player-facing text.

## What's here

| Path | What it is |
|---|---|
| `STYLE-GUIDE.md` | The rules, the quality bar (Chronos Part 1 and Keyboard Warrior v7), and the styles that were rejected |
| `TEMPLATE/cutscene-brief.md` | Fill this in before you build a new cutscene |
| `reference/` | Stills and short mockup videos of the two best cutscenes |
| `scripts/` | The client-side cutscene player code (read [scripts/README.md](scripts/README.md)) |
| `tools/CutsceneService/` | A third-party MIT module for smooth Bezier camera paths (credit: bstummer) |

## How to start a new cutscene

1. Ask Nguyen for a reference clip (a video of the vibe he wants). Don't build anything until you have one.
2. Fill in `TEMPLATE/cutscene-brief.md` and send it to him.
3. Make the mockup video. Send test frames early.
4. After he OKs the mockup, port it as pre-rendered image frames in a 2D ScreenGui (see `scripts/`).

## Visual references

Our library of Roblox reference images: https://github.com/wvk42mpcsf-rgb/sop-visual-refs

Useful folders there:
- `cutscenes/`
- `previews/cinematic/`
- `previews/cutscene/`
- `vfx/`
- `animations/`

Link to it, don't copy from it. Many of those images belong to other creators, and the library is huge. Use them as references only: nothing from it gets copied into this repo or put in the game.
