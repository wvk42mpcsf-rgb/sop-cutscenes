# tools/

## CutsceneService (by bstummer, MIT)

Source: https://github.com/bstummer/CutsceneService. The license is in `CutsceneService/LICENSE` (kept as-is).

It moves the camera along smooth multi-point Bezier paths with easing, for **in-engine camera cutscenes** (camera moves through the 3D world). Bots can use it for camera moves.

- `CutsceneService/src/CutsceneService.lua`: the module (it needs `EasingFunctions` as a child ModuleScript).
- `CutsceneService/src/EasingFunctions.lua`: the easing curves.

Notes:
- The blessing roll cutscenes in this game are **2D image-frame cutscenes** (see `../STYLE-GUIDE.md`), so this is for other camera moves, or for planning shots for a mockup.
- Checked: no require-by-id, no HttpService, no loadstring.
- Nothing goes into the game without Nguyen's OK.
