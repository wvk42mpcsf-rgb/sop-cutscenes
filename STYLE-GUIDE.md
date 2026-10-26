# Survive On Pillars: cutscene style guide

Read all of this before you make anything.

## When cutscenes play

A cutscene plays only when a player rolls a **Legendary or higher** blessing:

| Rarity | Blessings |
|---|---|
| Legendary | Keyboard Warrior, Phoenix, Judas |
| Mythical | Berserker, Infinity, Necromancer |
| Celestial | Seraph, Chronos |

Common, Rare and Epic blessings get no cutscene.

## Hard rules

1. **No skip button.** "Tap to continue" is the only exit, and it appears only after the reveal.
2. **No white-out longer than 2 frames.** A bright flash is fine for 1 or 2 frames, never a held white screen.
3. **Frozen final frame.** The last frame holds still (with the card and "Tap to continue") until the player taps.
4. **Length: 25 to 35 seconds**, including the reveal.
5. **Show the R6 character at the reveal.**
6. **A cause of death must never read as self-harm.** If a character dies in the story, someone or something else did it, and it must be clear.
7. **Words:** always say "blessing", never "power". Never use "kit" in player-facing text.

## Format: mockup first, then the port

1. **Mockup video.** Make the whole cutscene as a normal video first (1280x720, 30 fps is fine). Send it to Nguyen. Nothing gets ported until he OKs it.
2. **Port.** The approved video is rebuilt in game as **pre-rendered image frames in a 2D ScreenGui**: sprite sheets and image layers played back at 30 fps, synced to the soundtrack. Glows and bloom are baked into the images, because lighting doesn't affect UI. The players in `scripts/` already do this, so a new cutscene is mostly new images + a data module.

## THE BAR: copy this quality

Nguyen's two favourite cutscenes. Everything new should feel at least this good: a custom mini-story, hype pacing, clean motion graphics, one strong colour idea, and a reveal that lands.

### Chronos Part 1 (Celestial), Nguyen's favourite. About 34.6 s.

Stills: `reference/chronos-part1-*.jpg`. Video: `reference/chronos-part1-v7.mp4`.

- **Mood:** a rainy thunderstorm at night. Deep navy and indigo darks with a soft blue glow. Quiet and eerie at first, then a violent colour takeover. The inspiration was a Sol's RNG aura cutscene (big faint clock, hub star, sparkle stars).
- **Background:** a huge, faint Roman-numeral clock face (about 30% opacity) with a star sparkle at its hub. Its hands tick slowly. Small glowing blue hourglasses with flowing sand float around it.
- **The words:** "Time waits for no one, not even me..." types in letter by letter in classic engraved Roman capitals (Cinzel style), on slow, speeding-up ticks.
- **Stasis:** at the ellipsis, everything freezes for about half a second, in silence, with a small camera push.
- **The flip:** the clock hits XII and turns **RED**, and the hands spin backwards faster and faster. The scene rewinds on the ticks: the text un-types backwards and the letters crumble into red sand.
- **The eye:** the hands fold into a slit at XII and open into a **cyan eye** with a clock/hourglass iris. It blinks, and that blink triggers the impact.
- **Impact:** a 2-frame negative impact frame. The Roman numerals shear off and fly past the camera. The hourglasses shatter (only a little glass on screen), and a red burst shaped like a dial/hourglass blows out.
- **Ending:** a sand vortex, the clock explodes, a huge glass shard flies at the camera (jump scare), a small cyan ember drifts in the dust, then black. Part 2 continues the story later.
- **Why it works:** one clear motif (the clock/hourglass), only 2 to 3 colours per phase, the text is part of the action, and every big moment has a beat of silence before it.

### Keyboard Warrior v7 (Legendary). About 37.7 s plus the frozen final frame.

Stills: `reference/kw-v7-*.jpg`. Video: `reference/keyboard-warrior-v7.mp4`.

- **Story:** a sweaty gamer gets eliminated and rage-types his way into a blessing. Funny, loud, and fast.
- **Open:** "ELIMINATED" over his screen. The toxic chat floods in.
- **Rant:** he types back. A WPM gauge climbs to **999 / OVERCLOCK** and stays pinned there (needle buzzing) through the backspacing, the reply, CAPS LOCK and ENTER.
- **Crash:** the game crashes. The **CAPS LOCK** key pops out of the desk keyboard (its socket glows empty), floats up shaking and grows as a RAGE meter fills, then launches onto his fist.
- **Punch:** the second punch, led by the CAPS LOCK key, smashes through the monitor (glass shatter, ink/flash frames, 1 frame bright at most).
- **Title:** "KEYBOARD WARRIOR" slams in as green keycaps, one at a time. Gold appears only on the LEGENDARY tag.
- **Reveal:** he climbs floating keycap stairs (each key presses down and lights up under his feet) to a pedestal key. Grey R6 character: a slow smug head tilt, he folds his arms, then one impatient foot-tap that presses the key down, and "✓ SENT" pops.
- **Ending:** the other player replies with a big "???". After a short pause "✓ SENT" flips to "✓ READ". **Frozen final frame:** READ, the big ???, the ability card (big readable text), and "Tap to continue".
- **Why it works:** a relatable mini-story, a running joke paid off at the end, a prop (the CAPS LOCK key) that carries the whole story, and big readable UI.

## REJECTED: don't repeat these

| Style | Examples | What went wrong |
|---|---|---|
| 3D story scene | Seraph v3, Phoenix v1 to v5 | Too slow and boring, custom character designs looked bad, lighting/textures/quality poor, text hard to read. Phoenix v1 was "not innovative enough, too boring". Even on the default R6 (Phoenix v5) the quality was far below Chronos / KW. |
| Plain motion graphics | Judas v3 | "Boring and ugly ... not good enough at all". Clean shapes and text, but no story he cared about and no hype. |

Note: Chronos Part 1 and KW v7 are also 2D motion graphics. What made them work was the **story, the pacing and one strong motif**, not the technique.

**The lesson:** get a reference clip from Nguyen before building anything. Most rejected work came from guessing his taste. One clip of the vibe he wants saves hours of rebuilding.

## Checklist before you send anything

- [ ] I have Nguyen's reference clip, and my brief (`TEMPLATE/cutscene-brief.md`) matches it
- [ ] 25 to 35 s, with no skip button and "Tap to continue" only after the reveal
- [ ] No white frame held longer than 2 frames
- [ ] R6 character shown at the reveal; frozen final frame
- [ ] No death that could read as self-harm
- [ ] "blessing", never "power"; no "kit" on screen
- [ ] Sent as a mockup video (plus a few test frames) to Nguyen; nothing put into the game

## Visual references

Our library of Roblox reference images: https://github.com/wvk42mpcsf-rgb/sop-visual-refs

Useful folders there:
- `cutscenes/`
- `previews/cinematic/`
- `previews/cutscene/`
- `vfx/`
- `animations/`

Link to it, don't copy from it. Many of those images belong to other creators, and the library is huge. Use them as references only: nothing from it gets copied into this repo or put in the game.
