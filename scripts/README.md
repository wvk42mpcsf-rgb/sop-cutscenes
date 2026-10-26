# scripts/: the client-side cutscene player

These are **client-side scripts only** (LocalScripts and ModuleScripts), copied from the live game export for reference. Server scripts are not included.

Every number that looked like a Roblox asset id was replaced with `<ASSET_ID>`, so these files will **not** run as-is. They show how the player works and how a new cutscene plugs in.

## Files

| File | Where it lives in the game | What it does |
|---|---|---|
| `SOPBlessingCutscenes.client.lua` | `StarterPlayer/StarterPlayerScripts/SOPBlessingCutscenes` (LocalScript) | The shared engine for the Legendary / Mythical / Celestial cutscenes: builds the ScreenGui, hides the HUD and core UI, saves and restores camera / lighting / controls, letterbox, the reveal card and "Tap to continue". Scenes with `mode = "2D"` are played by `CS2D` or their own player. |
| `SOPBlessingCutscenes/CS2D.module.lua` | ModuleScript under the engine | The generic **2D image-frame player**: decodes a scene's baked keyframes and draws sprite layers at 30 fps, synced to the soundtrack. |
| `SOPBlessingCutscenes/KeyboardWarrior.module.lua` | ModuleScript under the engine | Keyboard Warrior v7 scene: timing + texture list (`M.TEX`), played by `CS2D`. |
| `SOPBlessingCutscenes/Chronos.module.lua` | ModuleScript under the engine | Chronos Part 1 scene with its own 2D player (draw list + flipbooks for the sand, the eye and the words). |
| `SOPRollCutscene.client.lua` | `StarterPlayer/StarterPlayerScripts/SOPRollCutscene` (LocalScript) | The older Infinity roll cutscene (in-engine, letterboxed). Kept as a reference for the reveal and the restore logic. |

## Not included, and why

- **`<Name>DataN` modules** (`ChronosData1-5`, `KeyboardWarriorData1`): about 1 MB of LZ4 + base64 compressed keyframes made by the build script, with image ids baked inside. They can't be cleaned of ids and aren't readable. A new cutscene gets its own data modules from its own build.
- **Judas, Phoenix, Seraph, Berserker and Necromancer scenes:** these are the rejected styles (see `../STYLE-GUIDE.md`). Don't copy them.
- **All server scripts** (the cutscene servers, round system, shop, saves, purchases): game logic, not cutscene material.

## How a cutscene starts (no server code)

The server owns the trigger. When a player rolls a Legendary+ blessing, the server fires a **RemoteEvent in ReplicatedStorage** to that one player:

- **`SOPBlessingCutscene`** (all Legendary+ blessings except Infinity). Server to client, one table:
  - `blessing` (string, e.g. `"Keyboard Warrior"`, `"Chronos"`)
  - `scene` (string, the scene module name, e.g. `"KeyboardWarrior"`, `"Chronos"`)
  - `isNew` (boolean, first time the player got this blessing: shows "NEW!")
  - `source` (string: `"roll"`, or `"test"` for owner test commands)
  - `rarity` (string: `"Legendary"`, `"Mythical"` or `"Celestial"`)
- **`SOPRollCutscene`** (Infinity only). The same table without `scene`.

While a cutscene is on screen, the client sends `SOPBlessingCutscene:FireServer("cs", true)` about every 5 s, and `("cs", false)` when it closes, so the round waits for the player. The client also listens to `RoundUIEvent` and closes the cutscene (restoring everything) if a round starts.

## Adding a new 2D cutscene (the short version)

1. Mockup video approved by Nguyen.
2. Export every frame as layers (image, position, size, rotation, colour, alpha) + sprite sheets.
3. Write a scene module like `KeyboardWarrior.module.lua` (`M.key`, `M.DUR`, `M.FPS`, `M.TEX`, `M.CUES`) + its data modules.
4. Nguyen adds the scene name on the server side. Nothing goes into the game without his OK.
