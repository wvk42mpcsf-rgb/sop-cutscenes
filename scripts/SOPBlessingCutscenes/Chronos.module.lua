-- v491 (a build task): sand sheets (HI centre + OPL outer) re-baked 1.6x brighter; white-hot burst core layers 750-754.
-- v487-v490 (a build task): sharper sand vortex/debris (full-res centre crops at 30 fps + outer flipbook), the white-hot burst frames 750-753 are the
-- video's own frames, the hourglass frame outline drawn (it was an empty sprite in v486), brighter rain + hourglass sand, lighter text backing,
-- eye iris clipped by the lids while they open.
-- Chronos (2D) — Tab, Oct 24 2026, SOP Test v485/v486: PART 1 of the NEW Chronos roll cutscene (owner: "just put it as the Chronos
-- cutscene rn and delete the old one so I can do /chronoscutscene and see it"). The old 3D Chronos scene (v479-v482, "Time waits for no one.
-- Except me.") was replaced; its source is kept in ServerStorage.SOPv485_Removed (Chronos_pre) and in (local backup).
-- HOW IT WORKS: a full-screen 2D replay of the approved v7 video. Every frame of the video's own render script was exported as a draw list
-- (which sprite, where, how big, rotation, colour, brightness) -> the ChronosData modules (LZ4 + base64). This module plays that list back at
-- 30 fps off the soundtrack's TimePosition, so picture and sound stay in sync. Dense sand (explosion debris, vortex, sand wall drain) is a
-- flipbook made from the same render; the eye is a flipbook; the words are the real Cinzel letters as images.
-- Only exit: "Tap to continue" at the end. Played by StarterPlayerScripts.SOPBlessingCutscenes (mode = "2D" -> run2D).
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local M = { mode = "2D", key = "Chronos" }
M.CUES = { { key = "track", id = "<ASSET_ID>", vol = 0.9 } }
local SH = { "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>" }
local EYE = {  }
local PLATE = { "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>" }
local HI = { "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>" }
local OPL = { "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>" }
local HIMAP = { [748]={1,0,0}, [749]={1,414,0}, [750]={1,0,512}, [751]={1,414,512}, [752]={2,0,0}, [753]={2,414,0}, [754]={2,0,512}, [755]={2,414,512}, [756]={3,0,0}, [757]={3,414,0}, [758]={3,0,512}, [759]={3,414,512}, [760]={4,0,0}, [761]={4,414,0}, [762]={4,0,512}, [763]={4,414,512}, [764]={5,0,0}, [765]={5,414,0}, [766]={5,0,512}, [767]={5,414,512}, [768]={6,0,0}, [769]={6,414,0}, [770]={6,0,512}, [771]={6,414,512}, [772]={7,0,0}, [773]={7,414,0}, [774]={7,0,512}, [775]={7,414,512}, [776]={8,0,0}, [777]={8,414,0}, [778]={8,0,512}, [779]={8,414,512}, [780]={9,0,0}, [781]={9,414,0}, [782]={9,0,512}, [783]={9,414,512}, [784]={10,0,0}, [785]={10,414,0}, [786]={10,0,512}, [787]={10,414,512}, [788]={11,0,0}, [789]={11,414,0}, [790]={11,0,512}, [791]={11,414,512}, [792]={12,0,0}, [793]={12,414,0}, [794]={12,0,512}, [795]={12,414,512}, [796]={13,0,0}, [797]={13,414,0}, [798]={13,0,512}, [799]={13,414,512}, [800]={14,0,0}, [801]={14,414,0}, [802]={14,0,512}, [803]={14,414,512}, [804]={15,0,0}, [805]={15,414,0}, [806]={15,0,512}, [807]={15,414,512}, [808]={16,0,0}, [809]={16,414,0}, [810]={16,0,512}, [811]={16,414,512}, [812]={17,0,0}, [813]={17,414,0}, [814]={17,0,512}, [815]={17,414,512}, [816]={18,0,0}, [817]={18,414,0}, [818]={18,0,512}, [819]={18,414,512}, [820]={19,0,0}, [821]={19,414,0}, [822]={19,0,512}, [823]={19,414,512}, [824]={20,0,0}, [825]={20,414,0}, [826]={20,0,512}, [827]={20,414,512}, [828]={21,0,0}, [829]={21,414,0}, [830]={21,0,512}, [831]={21,414,512}, [832]={22,0,0}, [833]={22,414,0}, [834]={22,0,512}, [835]={22,414,512}, [836]={23,0,0}, [837]={23,414,0}, [838]={23,0,512}, [839]={23,414,512}, [840]={24,0,0}, [841]={24,414,0}, [842]={24,0,512}, [843]={24,414,512}, [844]={25,0,0}, [845]={25,414,0}, [846]={25,0,512}, [847]={25,414,512}, [848]={26,0,0}, [849]={26,414,0}, [850]={26,0,512}, [851]={26,414,512}, [852]={27,0,0}, [853]={27,414,0}, [854]={27,0,512}, [855]={27,414,512}, [856]={28,0,0}, [857]={28,414,0}, [858]={28,0,512}, [859]={28,414,512}, [860]={29,0,0}, [861]={29,414,0} }
local OPMAP = { [748]={1,0,0}, [750]={1,512,0}, [752]={1,0,288}, [754]={1,512,288}, [756]={1,0,576}, [758]={1,512,576}, [760]={2,0,0}, [762]={2,512,0}, [764]={2,0,288}, [766]={2,512,288}, [768]={2,0,576}, [770]={2,512,576}, [772]={3,0,0}, [774]={3,512,0}, [776]={3,0,288}, [778]={3,512,288}, [780]={3,0,576}, [782]={3,512,576}, [784]={4,0,0}, [786]={4,512,0}, [788]={4,0,288}, [790]={4,512,288}, [792]={4,0,576}, [794]={4,512,576}, [796]={5,0,0}, [798]={5,512,0}, [800]={5,0,288}, [802]={5,512,288}, [804]={5,0,576}, [806]={5,512,576}, [808]={6,0,0}, [810]={6,512,0}, [812]={6,0,288}, [814]={6,512,288}, [816]={6,0,576}, [818]={6,512,576}, [820]={7,0,0}, [822]={7,512,0}, [824]={7,0,288}, [826]={7,512,288}, [828]={7,0,576}, [830]={7,512,576}, [832]={8,0,0}, [834]={8,512,0}, [836]={8,0,288}, [838]={8,512,288}, [840]={8,0,576}, [842]={8,512,576}, [844]={9,0,0}, [846]={9,512,0}, [848]={9,0,288}, [850]={9,512,288}, [852]={9,0,576}, [854]={9,512,576}, [856]={10,0,0}, [858]={10,512,0}, [860]={10,0,288} }
local WCORE = "rbxassetid://<ASSET_ID>" -- v491: white-hot burst core (soft white radial glow, stacked 3x)
local CORE = { [750] = { 1.0, 1.0 }, [751] = { 1.12, 1.0 }, [752] = { 1.0, 0.9 }, [753] = { 0.75, 0.6 }, [754] = { 0.5, 0.3 } }
local CORED = { 620, 400, 220 }
local BFI = { [750]="rbxassetid://<ASSET_ID>", [751]="rbxassetid://<ASSET_ID>", [752]="rbxassetid://<ASSET_ID>", [753]="rbxassetid://<ASSET_ID>" }
local HGOI = "rbxassetid://<ASSET_ID>"
local HGSET = {} for _, i in ipairs({ 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262 }) do HGSET[i] = true end
local NEG = { "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>" }
local BLOOM = { "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>" }
local EP = { "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>", "rbxassetid://<ASSET_ID>" }
local EPS = { ["slit#e"]={1,0,0,224,721,2.000,0.00,0.00}, ["iris#e"]={1,226,0,576,576,2.000,0.00,0.00}, ["slitH#n"]={1,804,0,76,571,2.000,0.00,0.00}, ["eyeD#n"]={2,0,0,883,404,1.500,0.50,-24.00}, ["eyeU#e"]={2,0,406,996,338,1.500,0.00,-113.00}, ["eyeL#e"]={3,0,0,996,313,1.500,0.00,101.50}, ["eyeC#e"]={1,0,723,984,207,1.500,1.00,31.50} }
local NSTRIP = { 0.3033, 0.2968, 0.2254, 0.2559, 0.2764, 0.2602, 0.2785, 0.2369, 0.2689, 0.3159, 0.2239, 0.2453, 0.2912, 0.3252, 0.3402, 0.2718, 0.2426, 0.2696, 0.3137, 0.2658, 0.2438, 0.2611, 0.2811, 0.3358, 0.3607, 0.3732, 0.3806, 0.4437, 0.4568, 0.4339, 0.4564, 0.5084, 0.5150, 0.5354, 0.5215, 0.5470, 0.5710, 0.5844, 0.6155, 0.6179, 0.6315, 0.6245, 0.5854, 0.5842, 0.6074, 0.5772, 0.6080, 0.7002 }
local FULL = { txf = "rbxassetid://<ASSET_ID>", edge = "rbxassetid://<ASSET_ID>", vign = "rbxassetid://<ASSET_ID>", fogb = "rbxassetid://<ASSET_ID>", fogt = "rbxassetid://<ASSET_ID>", tile_CLF = "rbxassetid://<ASSET_ID>", tile_CLN = "rbxassetid://<ASSET_ID>", tile_RN = "rbxassetid://<ASSET_ID>", tile_RF = "rbxassetid://<ASSET_ID>" }
M.IMG = {}
for _, t in ipairs({ SH, EP, PLATE, NEG, BLOOM, HI, OPL }) do for _, id in ipairs(t) do table.insert(M.IMG, id) end end
for _, id in pairs(FULL) do table.insert(M.IMG, id) end
for _, id in pairs(BFI) do table.insert(M.IMG, id) end
table.insert(M.IMG, WCORE)
table.insert(M.IMG, HGOI)
local SPR = { {1,172,770,148,236,1.00000,0.00,-9.00}, {1,0,770,170,250,1.00000,0.00,-3.00}, {7,287,730,545,96,1.00000,-7.50,0.00}, {7,0,830,556,96,1.00000,-2.00,0.00}, {4,0,0,512,512,0.50000,0.00,0.00}, {1,770,0,204,614,0.60000,0.00,0.00}, {2,770,0,137,614,0.60000,-56.00,0.00}, {2,909,0,112,614,0.60000,76.50,0.00}, {6,514,580,256,256,0.50000,0.00,0.00}, {1,52,1022,2,2,1.00000,-359.00,-359.00}, {1,56,1022,2,2,1.00000,-359.00,-359.00}, {3,0,972,52,52,1.00000,0.00,0.00}, {3,243,972,48,48,1.00000,0.00,0.00}, {3,0,0,643,643,1.00000,0.50,0.50}, {3,0,645,325,325,0.50000,0.00,0.00}, {7,801,830,68,89,1.00000,22.50,-16.00}, {2,172,941,89,65,1.00000,17.00,23.00}, {7,871,830,69,89,1.00000,-21.00,17.00}, {2,0,941,89,68,1.00000,-16.00,-20.50}, {1,874,770,43,161,1.00000,15.50,6.00}, {5,729,868,101,135,1.00000,3.50,-6.00}, {4,462,948,161,43,1.00000,-5.00,15.50}, {7,0,730,123,98,1.00000,14.00,5.00}, {1,919,770,39,147,1.00000,-16.50,-12.00}, {6,772,580,100,134,1.00000,-2.00,7.50}, {4,625,948,160,43,1.00000,6.50,-14.50}, {7,648,620,135,101,1.00000,-6.00,-2.50}, {1,414,770,68,199,1.00000,11.00,-0.50}, {2,0,770,154,169,1.00000,-1.50,-2.50}, {7,0,928,194,89,1.00000,-4.00,10.00}, {7,162,506,187,111,1.00000,6.00,8.50}, {1,575,770,135,180,1.00000,-2.00,-4.00}, {1,484,770,68,198,1.00000,-9.50,2.00}, {2,156,770,152,169,1.00000,2.50,4.50}, {7,196,928,193,87,1.00000,5.50,-9.50}, {7,432,506,187,110,1.00000,-5.00,-7.50}, {1,712,770,135,180,1.00000,2.50,5.00}, {1,1020,770,2,2,1.00000,-38.00,-69.50}, {1,0,1022,2,2,1.00000,-3.50,-76.50}, {1,4,1022,2,2,1.00000,-29.50,-71.50}, {1,8,1022,2,2,1.00000,-60.50,-54.00}, {1,12,1022,2,2,1.00000,-74.00,-17.50}, {1,16,1022,2,2,1.00000,-75.50,-11.00}, {1,20,1022,2,2,1.00000,-64.50,-49.00}, {1,24,1022,2,2,1.00000,-38.50,-69.50}, {1,28,1022,2,2,1.00000,-4.00,-76.50}, {1,32,1022,2,2,1.00000,-30.00,-71.50}, {1,36,1022,2,2,1.00000,-60.50,-54.00}, {1,40,1022,2,2,1.00000,-74.00,-18.00}, {1,44,1022,2,2,1.00000,-75.50,-11.50}, {1,48,1022,2,2,1.00000,-64.50,-49.00}, {3,709,0,34,335,1.00000,0.00,0.00}, {1,368,770,44,232,1.00000,0.00,0.00}, {3,645,0,26,373,1.00000,0.00,0.00}, {8,533,0,35,41,1.00000,1.00,-21.50}, {3,755,972,38,48,1.00000,1.50,-21.00}, {2,390,941,50,64,1.00000,-0.50,-21.00}, {8,129,0,31,41,1.00000,0.00,-21.50}, {3,564,972,36,48,1.00000,1.50,-21.00}, {2,502,941,47,63,1.00000,-1.00,-21.50}, {8,930,0,20,40,1.00000,0.50,-21.00}, {1,990,770,23,48,1.00000,1.00,-21.00}, {2,551,941,38,62,1.00000,0.50,-21.00}, {4,222,948,59,44,1.00000,0.50,-21.00}, {3,342,972,61,48,1.00000,0.50,-21.00}, {4,0,948,72,57,1.00000,1.00,-18.50}, {7,391,928,49,43,1.00000,0.00,-21.50}, {3,602,972,51,48,1.00000,0.00,-21.00}, {2,643,941,67,60,1.00000,0.00,-21.00}, {7,822,928,47,42,1.00000,0.00,-21.00}, {3,54,972,55,50,1.00000,0.00,-21.00}, {2,263,941,73,64,1.00000,0.00,-21.00}, {8,700,0,44,40,1.00000,2.50,-21.00}, {3,293,972,47,48,1.00000,3.00,-21.00}, {2,442,941,58,63,1.00000,0.50,-21.50}, {5,994,868,28,42,1.00000,0.50,-21.00}, {2,984,941,35,50,1.00000,1.00,-21.00}, {2,591,941,50,62,1.00000,0.50,-21.00}, {8,344,0,38,41,1.00000,0.50,-21.50}, {3,707,972,46,48,1.00000,0.50,-21.00}, {2,338,941,50,64,1.00000,0.50,-22.00}, {7,678,928,46,42,1.00000,0.00,-21.00}, {3,655,972,50,48,1.00000,0.00,-22.00}, {2,925,941,57,58,1.00000,-0.50,-24.00}, {4,787,948,62,43,1.00000,0.50,-21.50}, {3,456,972,64,48,1.00000,0.50,-22.00}, {2,851,941,72,58,1.00000,-0.50,-24.00}, {4,0,1007,10,17,1.00000,0.50,-1.50}, {8,685,44,17,24,1.00000,1.00,-2.00}, {8,580,44,30,32,1.00000,0.50,-2.00}, {2,0,1011,11,10,1.00000,1.50,-5.00}, {4,46,1007,17,16,1.00000,1.50,-5.00}, {8,657,44,26,26,1.00000,1.00,-5.00}, {3,111,972,42,49,1.00000,0.00,-25.50}, {4,74,948,50,56,1.00000,0.00,-25.00}, {2,958,770,54,71,1.00000,0.00,-25.50}, {7,543,928,47,42,1.00000,0.50,-22.00}, {3,405,972,49,48,1.00000,0.50,-21.00}, {2,793,941,56,59,1.00000,1.00,-19.50}, {8,570,0,35,41,1.00000,1.00,-21.50}, {8,607,0,35,41,1.00000,1.00,-21.50}, {8,644,0,31,41,1.00000,3.00,-21.50}, {8,547,44,31,34,1.00000,3.00,-24.00}, {8,162,0,31,41,1.00000,0.00,-21.50}, {8,195,0,31,41,1.00000,0.00,-21.50}, {8,228,0,28,41,1.00000,1.50,-21.50}, {8,519,44,26,34,1.00000,2.50,-24.00}, {8,952,0,20,40,1.00000,0.50,-21.00}, {8,974,0,19,40,1.00000,0.00,-21.00}, {8,995,0,17,40,1.00000,-1.00,-21.00}, {8,0,44,12,40,1.00000,1.50,-21.00}, {4,283,948,59,44,1.00000,0.50,-21.00}, {4,344,948,59,44,1.00000,0.50,-21.00}, {4,405,948,55,44,1.00000,2.50,-21.00}, {8,879,0,49,40,1.00000,1.50,-21.00}, {7,442,928,49,43,1.00000,0.00,-21.50}, {7,493,928,48,43,1.00000,0.50,-21.50}, {8,258,0,44,41,1.00000,-1.50,-20.50}, {8,304,0,38,41,1.00000,1.50,-20.50}, {7,871,928,47,42,1.00000,0.00,-21.00}, {7,920,928,47,42,1.00000,0.00,-21.00}, {7,969,928,47,42,1.00000,0.00,-21.00}, {8,0,0,39,42,1.00000,-2.00,-21.00}, {8,746,0,44,40,1.00000,2.50,-21.00}, {8,792,0,44,40,1.00000,2.50,-21.00}, {8,838,0,39,40,1.00000,0.00,-21.00}, {8,131,44,33,36,1.00000,-3.00,-23.00}, {8,41,0,28,42,1.00000,0.50,-21.00}, {8,71,0,28,42,1.00000,0.50,-21.00}, {8,101,0,26,42,1.00000,0.50,-21.00}, {8,677,0,21,41,1.00000,2.00,-20.50}, {8,384,0,38,41,1.00000,0.50,-21.50}, {8,424,0,38,41,1.00000,0.50,-21.50}, {8,464,0,38,41,1.00000,0.50,-21.50}, {8,504,0,27,41,1.00000,6.00,-21.50}, {7,726,928,46,42,1.00000,0.00,-21.00}, {7,774,928,46,42,1.00000,0.00,-21.00}, {8,83,44,46,38,1.00000,0.00,-23.00}, {8,336,44,41,35,1.00000,-2.50,-24.50}, {4,851,948,62,43,1.00000,0.50,-21.50}, {4,915,948,60,43,1.00000,0.50,-21.50}, {6,959,870,57,43,1.00000,2.00,-21.50}, {8,612,44,43,32,1.00000,1.00,-27.00}, {4,12,1007,10,17,1.00000,0.50,-1.50}, {4,24,1007,9,17,1.00000,1.00,-1.50}, {4,35,1007,9,16,1.00000,1.00,-1.00}, {1,1015,770,3,6,1.00000,0.00,4.00}, {2,13,1011,11,10,1.00000,1.50,-5.00}, {2,26,1011,11,10,1.00000,1.50,-5.00}, {2,39,1011,11,7,1.00000,1.50,-6.50}, {2,52,1011,6,4,1.00000,3.00,-5.00}, {3,155,972,42,49,1.00000,0.00,-25.50}, {3,199,972,42,49,1.00000,0.00,-25.50}, {3,522,972,40,48,1.00000,-1.00,-25.00}, {4,188,948,32,45,1.00000,-5.00,-25.50}, {4,977,948,45,42,1.00000,-0.50,-22.00}, {7,592,928,45,42,1.00000,-0.50,-22.00}, {7,639,928,37,42,1.00000,1.50,-22.00}, {8,57,44,24,38,1.00000,2.00,-20.00}, {1,322,770,44,232,1.00000,0.00,-88.00}, {3,673,0,34,335,1.00000,0.00,-116.50}, {1,976,0,26,373,1.00000,0.00,-109.50}, {1,960,770,28,118,0.50000,0.00,-89.00}, {1,849,770,23,172,0.50000,0.00,-115.50}, {1,554,770,19,188,0.50000,0.00,-106.00}, {1,60,1022,2,2,1.00000,-299.00,-359.00}, {2,91,941,79,66,0.80000,0.50,-45.50}, {2,310,770,79,146,0.80000,0.50,5.00}, {2,391,770,79,146,0.80000,0.50,5.00}, {2,472,770,79,145,0.80000,0.50,5.50}, {2,553,770,79,145,0.80000,0.50,5.50}, {2,634,770,79,144,0.80000,0.50,6.00}, {2,715,770,79,144,0.80000,0.50,6.00}, {2,796,770,79,143,0.80000,0.50,6.50}, {2,877,770,79,143,0.80000,0.50,6.50}, {3,894,645,79,142,0.80000,0.50,7.00}, {4,770,514,79,142,0.80000,0.50,7.50}, {4,851,514,79,142,0.80000,0.50,7.50}, {4,932,514,79,141,0.80000,0.50,8.00}, {5,770,434,79,141,0.80000,0.50,8.00}, {5,851,434,79,140,0.80000,0.50,8.50}, {5,932,434,79,140,0.80000,0.50,8.50}, {5,0,868,79,139,0.80000,0.50,9.00}, {5,81,868,79,138,0.80000,0.50,9.50}, {5,162,868,79,138,0.80000,0.50,9.50}, {5,243,868,79,138,0.80000,0.50,10.00}, {5,324,868,79,138,0.80000,0.50,10.00}, {5,405,868,79,137,0.80000,0.50,10.50}, {5,486,868,79,137,0.80000,0.50,10.50}, {5,567,868,79,136,0.80000,0.50,11.00}, {5,648,868,79,136,0.80000,0.50,11.00}, {5,832,868,79,135,0.80000,0.50,11.50}, {5,913,868,79,135,0.80000,0.50,11.50}, {6,874,580,78,134,0.80000,0.00,12.00}, {6,0,870,78,134,0.80000,0.00,12.50}, {6,80,870,78,134,0.80000,0.00,12.50}, {6,160,870,78,133,0.80000,0.00,13.00}, {6,240,870,78,133,0.80000,0.00,13.00}, {6,320,870,78,132,0.80000,0.00,13.50}, {6,400,870,78,132,0.80000,0.00,13.50}, {6,480,870,78,131,0.80000,0.00,14.00}, {6,560,870,78,131,0.80000,0.00,14.00}, {6,640,870,78,130,0.80000,0.50,14.50}, {6,720,870,78,130,0.80000,0.50,14.50}, {6,800,870,78,130,0.80000,0.50,15.00}, {6,880,870,77,129,0.80000,0.00,15.50}, {7,258,0,77,129,0.80000,0.00,15.50}, {7,337,0,77,128,0.80000,0.00,16.00}, {7,416,0,78,128,0.80000,0.50,16.00}, {7,496,0,78,127,0.80000,0.00,16.50}, {7,576,0,78,127,0.80000,0.00,16.50}, {7,656,0,78,126,0.80000,0.00,17.00}, {7,736,0,78,126,0.80000,0.00,17.50}, {7,816,0,78,126,0.80000,0.00,17.50}, {7,896,0,79,125,0.80000,0.50,18.00}, {7,0,258,79,125,0.80000,0.50,18.00}, {7,81,258,79,124,0.80000,0.50,18.50}, {7,162,258,79,123,0.80000,0.50,19.00}, {7,243,258,79,123,0.80000,0.50,19.00}, {7,324,258,79,122,0.80000,0.50,19.50}, {7,405,258,79,122,0.80000,0.50,19.50}, {7,486,258,79,122,0.80000,0.50,20.00}, {7,567,258,79,122,0.80000,0.50,20.00}, {7,648,258,79,121,0.80000,0.50,20.50}, {7,729,258,79,120,0.80000,0.50,21.00}, {7,810,258,79,120,0.80000,0.50,21.00}, {7,891,258,79,119,0.80000,0.50,21.50}, {7,0,385,79,119,0.80000,0.50,21.50}, {7,81,385,79,118,0.80000,0.50,22.00}, {7,162,385,79,118,0.80000,0.50,22.50}, {7,243,385,79,118,0.80000,0.50,22.50}, {7,324,385,79,117,0.80000,0.50,23.00}, {7,405,385,79,116,0.80000,0.50,23.50}, {7,486,385,79,116,0.80000,0.50,23.50}, {7,567,385,79,115,0.80000,0.50,24.00}, {7,648,385,79,114,0.80000,0.50,24.50}, {7,729,385,79,114,0.80000,0.50,24.50}, {7,810,385,79,114,0.80000,0.50,25.00}, {7,891,385,79,113,0.80000,0.50,25.50}, {7,0,506,79,112,0.80000,0.50,26.00}, {7,81,506,79,112,0.80000,0.50,26.00}, {7,351,506,79,111,0.80000,0.50,26.50}, {7,621,506,79,110,0.80000,0.50,27.00}, {7,702,506,79,110,0.80000,0.50,27.50}, {7,783,506,79,109,0.80000,0.50,28.00}, {7,864,506,79,109,0.80000,0.50,28.00}, {7,0,620,79,108,0.80000,0.50,28.50}, {7,81,620,79,106,0.80000,0.50,29.50}, {7,162,620,79,106,0.80000,0.50,29.50}, {7,243,620,79,106,0.80000,0.50,30.00}, {7,324,620,79,104,0.80000,0.50,31.00}, {7,405,620,79,103,0.80000,0.50,31.50}, {7,486,620,79,102,0.80000,0.50,32.00}, {7,567,620,79,102,0.80000,0.50,32.50}, {7,785,620,79,100,0.80000,0.50,33.50}, {7,866,620,79,99,0.80000,0.50,34.00}, {7,125,730,79,98,0.80000,0.50,35.00}, {7,206,730,79,97,0.80000,0.50,35.50}, {7,558,830,79,95,0.80000,0.50,36.50}, {7,639,830,79,93,0.80000,0.50,38.00}, {7,720,830,79,90,0.80000,0.50,40.00}, {2,712,941,79,60,0.80000,0.50,58.50}, {8,379,44,64,34,1.00000,0.00,0.00}, {3,795,972,86,45,1.00000,0.00,0.00}, {3,883,972,75,45,1.00000,0.00,0.00}, {8,166,44,48,35,1.00000,0.50,0.00}, {3,960,972,58,45,1.00000,0.00,0.00}, {8,216,44,50,35,1.00000,0.00,0.00}, {8,268,44,50,35,1.00000,0.00,0.00}, {4,126,948,60,45,1.00000,0.00,0.00}, {8,445,44,32,34,1.00000,0.00,0.00}, {8,14,44,41,39,1.00000,-2.50,-2.50}, {8,479,44,38,34,1.00000,0.00,-0.50}, {8,320,44,14,35,1.00000,1.00,0.00}, {4,514,0,480,480,1.00000,0.00,0.00}, {2,0,0,768,768,0.75000,0.00,0.00}, {1,0,0,768,768,0.75000,0.00,0.00}, {3,327,645,307,307,0.60000,0.00,0.00}, {7,0,0,256,256,0.50000,0.00,0.00}, {3,636,645,256,256,1.00000,0.00,0.00}, {4,65,1007,128,15,1.00000,0.00,0.50}, {4,0,514,768,432,0.75000,0.00,0.00}, {5,0,0,759,432,0.75000,-6.00,0.00}, {5,0,434,768,432,0.75000,0.00,0.00}, {6,0,0,512,288,0.50000,0.00,0.00}, {6,0,290,512,288,0.50000,0.00,0.00}, {6,0,580,512,288,0.50000,0.00,0.00} }
local IDX = { ["beam0#a"]=3,["beam1#a"]=4,["dial0#a"]=10,["dial1#a"]=11,["dot#a"]=12,["gly_101_0#n"]=55,["gly_101_1#a"]=56,["gly_101_2#a"]=57,["gly_102_0#n"]=58,["gly_102_1#a"]=59,["gly_102_2#a"]=60,["gly_105_0#n"]=61,["gly_105_1#a"]=62,["gly_105_2#a"]=63,["gly_109_0#n"]=64,["gly_109_1#a"]=65,["gly_109_2#a"]=66,["gly_110_0#n"]=67,["gly_110_1#a"]=68,["gly_110_2#a"]=69,["gly_111_0#n"]=70,["gly_111_1#a"]=71,["gly_111_2#a"]=72,["gly_114_0#n"]=73,["gly_114_1#a"]=74,["gly_114_2#a"]=75,["gly_115_0#n"]=76,["gly_115_1#a"]=77,["gly_115_2#a"]=78,["gly_116_0#n"]=79,["gly_116_1#a"]=80,["gly_116_2#a"]=81,["gly_118_0#n"]=82,["gly_118_1#a"]=83,["gly_118_2#a"]=84,["gly_119_0#n"]=85,["gly_119_1#a"]=86,["gly_119_2#a"]=87,["gly_44_0#n"]=88,["gly_44_1#a"]=89,["gly_44_2#a"]=90,["gly_46_0#n"]=91,["gly_46_1#a"]=92,["gly_46_2#a"]=93,["gly_84_0#n"]=94,["gly_84_1#a"]=95,["gly_84_2#a"]=96,["gly_97_0#n"]=97,["gly_97_1#a"]=98,["gly_97_2#a"]=99,["glyd_101_0#n"]=100,["glyd_101_1#n"]=101,["glyd_101_2#n"]=102,["glyd_101_3#n"]=103,["glyd_102_0#n"]=104,["glyd_102_1#n"]=105,["glyd_102_2#n"]=106,["glyd_102_3#n"]=107,["glyd_105_0#n"]=108,["glyd_105_1#n"]=109,["glyd_105_2#n"]=110,["glyd_105_3#n"]=111,["glyd_109_0#n"]=112,["glyd_109_1#n"]=113,["glyd_109_2#n"]=114,["glyd_109_3#n"]=115,["glyd_110_0#n"]=116,["glyd_110_1#n"]=117,["glyd_110_2#n"]=118,["glyd_110_3#n"]=119,["glyd_111_0#n"]=120,["glyd_111_1#n"]=121,["glyd_111_2#n"]=122,["glyd_111_3#n"]=123,["glyd_114_0#n"]=124,["glyd_114_1#n"]=125,["glyd_114_2#n"]=126,["glyd_114_3#n"]=127,["glyd_115_0#n"]=128,["glyd_115_1#n"]=129,["glyd_115_2#n"]=130,["glyd_115_3#n"]=131,["glyd_116_0#n"]=132,["glyd_116_1#n"]=133,["glyd_116_2#n"]=134,["glyd_116_3#n"]=135,["glyd_118_0#n"]=136,["glyd_118_1#n"]=137,["glyd_118_2#n"]=138,["glyd_118_3#n"]=139,["glyd_119_0#n"]=140,["glyd_119_1#n"]=141,["glyd_119_2#n"]=142,["glyd_119_3#n"]=143,["glyd_44_0#n"]=144,["glyd_44_1#n"]=145,["glyd_44_2#n"]=146,["glyd_44_3#n"]=147,["glyd_46_0#n"]=148,["glyd_46_1#n"]=149,["glyd_46_2#n"]=150,["glyd_46_3#n"]=151,["glyd_84_0#n"]=152,["glyd_84_1#n"]=153,["glyd_84_2#n"]=154,["glyd_84_3#n"]=155,["glyd_97_0#n"]=156,["glyd_97_1#n"]=157,["glyd_97_2#n"]=158,["glyd_97_3#n"]=159,["hgo#a"]=166,["ringc#a"]=276,["ringr#a"]=277,["sw2#n"]=284,["swg2#a"]=287 }
local TXT = { {84,447.70,307.50,4.4000,19.4017,0.1800}, {105,487.22,307.50,4.5350,19.3900,0.1800}, {109,532.95,307.50,4.6700,19.3783,0.1800}, {101,586.41,307.50,4.8050,19.3667,0.1800}, {119,662.12,307.50,5.0100,19.3550,0.1800}, {97,718.05,307.50,5.1450,19.3392,0.1800}, {105,757.05,307.50,5.2800,19.3233,0.1800}, {116,794.28,307.50,5.4150,19.3075,0.1800}, {115,836.81,307.50,5.5500,19.2917,0.1800}, {102,417.07,389.50,5.7550,19.2758,0.1800}, {111,466.38,389.50,5.8900,19.2600,0.1800}, {114,519.66,389.50,6.0250,19.2275,0.1800}, {110,595.59,389.50,6.2300,19.1950,0.1800}, {111,652.99,389.50,6.3650,19.1625,0.1800}, {111,732.77,389.50,6.5700,19.1300,0.1800}, {110,790.05,389.50,6.7050,19.0850,0.1800}, {101,840.46,389.50,6.8400,19.0400,0.1800}, {44,872.68,389.50,6.9750,18.9950,0.1800}, {110,370.88,471.50,7.5950,18.9500,0.1800}, {111,428.28,471.50,7.7300,18.7800,0.1800}, {116,479.56,471.50,7.8650,18.7350,0.1800}, {101,546.59,471.50,8.0700,18.6900,0.1800}, {118,592.31,471.50,8.2050,18.4100,0.1800}, {101,637.86,471.50,8.3400,18.3650,0.1800}, {110,688.08,471.50,8.4750,18.3200,0.1800}, {109,770.48,471.50,8.6800,17.8250,0.3400}, {101,823.94,471.50,8.8150,17.7800,0.3400}, {46,855.66,471.50,9.9900,17.0000,0.3400}, {46,886.31,471.50,10.9900,16.0200,0.3400}, {46,916.97,471.50,11.9900,14.9000,0.3400} }
local K = { T_TEXT = 4.4, T_TEXT_GONE = 19.631666666666668, T_RED = 13.65, T_S = 13.0, FREEZE = 0.95, TBX = 304.625, TBY = 115.69999999999999, NFR = 1037, EYECW = 720, EYECH = 404, EYEFW = 324, EYEFH = 182 }
local AG = 1.5
local CW, CH = K.EYECW, K.EYECH
local TILE = { { "CLF", 1440, 720 }, { "CLN", 1600, 800 }, { "RN", 512, 512 }, { "RF", 384, 384 } }

-- ---------- data: base64 -> LZ4 block -> buffer ----------
local B64 = {}
do local a = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/" for i = 1, 64 do B64[string.byte(a, i)] = i - 1 end end
local function unb64(s)
	local n = #s
	local pad = (string.sub(s, -2) == "==" and 2) or (string.sub(s, -1) == "=" and 1) or 0
	local out = buffer.create(n // 4 * 3 - pad)
	local len, o = buffer.len(out), 0
	for i = 1, n, 4 do
		local a, b, c, d = string.byte(s, i, i + 3)
		local v = B64[a] * 262144 + B64[b] * 4096 + (B64[c] or 0) * 64 + (B64[d] or 0)
		buffer.writeu8(out, o, bit32.rshift(v, 16))
		if o + 1 < len then buffer.writeu8(out, o + 1, bit32.band(bit32.rshift(v, 8), 255)) end
		if o + 2 < len then buffer.writeu8(out, o + 2, bit32.band(v, 255)) end
		o += 3
	end
	return out
end
local function unlz4(src, rawLen)
	local dst = buffer.create(rawLen)
	local ip, op, n = 0, 0, buffer.len(src)
	while ip < n do
		local tok = buffer.readu8(src, ip) ip += 1
		local lit = bit32.rshift(tok, 4)
		if lit == 15 then repeat local b = buffer.readu8(src, ip) ip += 1 lit += b until b ~= 255 end
		if lit > 0 then buffer.copy(dst, op, src, ip, lit) ip += lit op += lit end
		if ip >= n then break end
		local off = buffer.readu16(src, ip) ip += 2
		local ml = bit32.band(tok, 15)
		if ml == 15 then repeat local b = buffer.readu8(src, ip) ip += 1 ml += b until b ~= 255 end
		ml += 4
		local mp = op - off
		if off >= ml then buffer.copy(dst, op, dst, mp, ml)
		else for i = 0, ml - 1 do buffer.writeu8(dst, op + i, buffer.readu8(dst, mp + i)) end end
		op += ml
	end
	return dst
end
local DATA = nil
local function loadData()
	if DATA then return DATA end
	local parts = {}
	for i = 1, 5 do
		local base = (script.ClassName == "ModuleScript" and script.Parent) or script
		local ms = base:FindFirstChild("ChronosData" .. i)
		assert(ms, "ChronosData" .. i .. " missing")
		parts[i] = require(ms)
	end
	DATA = unlz4(unb64(table.concat(parts)), 1224495)
	return DATA
end
M.loadData = loadData

local function ease(x) x = math.clamp(x, 0, 1) return x * x * (3 - 2 * x) end
local function lerp(a, b, t) return a + (b - a) * t end
local function redness(t) return ease((t - K.T_RED) / 0.22) end
local function sceneT(tr) if tr < K.T_S then return tr elseif tr < K.T_S + K.FREEZE then return K.T_S else return tr - K.FREEZE end end
local BLUE = { 0.36, 0.62, 1.0 } local RED = { 1.0, 0.20, 0.13 }
local function mix3(a, b, t) return { lerp(a[1], b[1], t), lerp(a[2], b[2], t), lerp(a[3], b[3], t) } end

function M.play2D(C)
	local st, root = C.st, C.root
	local D = loadData()
	local NF = buffer.readu32(D, 0)
	-- make sure the art is in memory before the first frame (black screen meanwhile; max ~6 s)
	do
		local list = {}
		for _, id in ipairs(M.IMG) do local im = Instance.new("ImageLabel") im.Image = id table.insert(list, im) end
		local done = false
		task.spawn(function() pcall(function() ContentProvider:PreloadAsync(list) end) done = true end)
		local w0 = os.clock()
		while not done and os.clock() - w0 < 6 and not st.done do task.wait(0.1) end
		if st.done then return end
	end
	local cam = workspace.CurrentCamera
	-- ---------- layout: the 1280x720 video area fitted inside the screen (full-screen layers fill the rest) ----------
	local scrW, scrH, S, CX, CY = 0, 0, 1, 0, 0
	local function layout()
		local v = (cam and cam.ViewportSize) or Vector2.new(1280, 720)
		pcall(function() local a = root.AbsoluteSize if a.X > 10 then v = a end end)
		scrW, scrH = v.X, v.Y
		S = math.min(scrW / 1280, scrH / 720)
		CX, CY = scrW / 2, scrH / 2
	end
	layout()
	local zoom, dx, dy = 1, 0, 0
	local function X(x) return CX + ((x - 640) * zoom + dx) * S end
	local function Y(y) return CY + ((y - 360) * zoom + dy) * S end
	local function new(class, props)
		local o = Instance.new(class)
		for k, v in pairs(props) do o[k] = v end
		o.Parent = root
		return o
	end
	local function lab(props)
		local o = new("ImageLabel", { BackgroundTransparency = 1, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Visible = false })
		for k, v in pairs(props or {}) do o[k] = v end
		return { o = o }
	end
	local function rect(color)
		return { o = new("Frame", { BackgroundColor3 = color or Color3.new(0, 0, 0), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Visible = false }) }
	end
	-- cached setters (only touch a property when it changes)
	local function set(L, k, v) if L[k] ~= v then L[k] = v L.o[k] = v end end
	local function show(L, z) set(L, "Visible", true) set(L, "ZIndex", z) L.used = true end

	-- ---------- fixed layers ----------
	local bg = new("Frame", { BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 1 })
	local bgG = Instance.new("UIGradient") bgG.Rotation = 90 bgG.Parent = bg
	local bg2 = rect(Color3.new(1, 1, 1)) local bg2G = Instance.new("UIGradient") bg2G.Rotation = 90 bg2G.Parent = bg2.o
	local function bgColors(k, R)
		local c0 = { 0.035, 0.05, 0.11 } local c1 = { 0.01, 0.015, 0.04 }
		local f = { lerp(1, 1.6, R), lerp(1, 0.35, R), lerp(1, 0.3, R) }
		return ColorSequence.new(Color3.new(c0[1] * f[1] * k, c0[2] * f[2] * k, c0[3] * f[3] * k), Color3.new(c1[1] * f[1] * k, c1[2] * f[2] * k, c1[3] * f[3] * k))
	end
	local tiles = {}
	for i, t in ipairs(TILE) do tiles[i] = lab({ Image = FULL["tile_" .. t[1]], ScaleType = Enum.ScaleType.Tile, AnchorPoint = Vector2.new(0, 0) }) end
	local fogb = lab({ Image = FULL.fogb, ScaleType = Enum.ScaleType.Tile, AnchorPoint = Vector2.new(0, 0) })
	local fogt = lab({ Image = FULL.fogt, ScaleType = Enum.ScaleType.Tile, AnchorPoint = Vector2.new(0, 0) })
	local txf = lab({ Image = FULL.txf })
	local edge = lab({ Image = FULL.edge, AnchorPoint = Vector2.new(0, 0), Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Stretch })
	local vign = lab({ Image = FULL.vign, AnchorPoint = Vector2.new(0, 0), Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Stretch })
	local eyeL = lab({}) local plateL = lab({}) local negL = lab({ AnchorPoint = Vector2.new(0, 0), Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Crop })
	local hgoL = lab({}) local hgoL2 = lab({}) local plateH = lab({}) local bfL = lab({})
	local coreL = { lab({}), lab({}), lab({}) } -- v491: white-hot burst core layers (centre only, never full screen)
	-- v490: rolling warm-up: the sand/burst sheets needed in the next ~1.3 s are held by invisible labels so they are in video memory
	-- before their frame (all at once overflowed the low-end texture budget; on demand they arrived late)
	local warmL = {}
	for j = 1, 20 do warmL[j] = lab({ AnchorPoint = Vector2.new(0, 0), Size = UDim2.fromOffset(64, 64), Position = UDim2.fromOffset(0, 0), ImageTransparency = 0.995, ZIndex = 2 }) end
	local warmDone = false
	local irisClip = { o = new("Frame", { BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true, Visible = false }) }
	local irisL = {}
	for j = 1, 7 do local o = Instance.new("ImageLabel") o.BackgroundTransparency = 1 o.BorderSizePixel = 0 o.AnchorPoint = Vector2.new(0.5, 0.5) o.Visible = false o.Parent = irisClip.o irisL[j] = { o = o } end
	local bloomL = lab({})
	local ringL = { lab({}), lab({}) }
	local flood = rect(Color3.new(1.0, 0.08, 0.06)) local white = rect(Color3.new(1, 1, 1)) local eblack = rect() local fadeR = rect()
	local rects, nRect = {}, 0
	local function getRect()
		nRect += 1
		local r = rects[nRect]
		if not r then r = rect() rects[nRect] = r end
		return r
	end
	local pool, nPool = {}, 0
	local function getSpr()
		nPool += 1
		local L = pool[nPool]
		if not L then L = lab({}) pool[nPool] = L end
		return L
	end
	local dots, nDot = {}, 0
	local function getDot()
		nDot += 1
		local L = dots[nDot]
		if not L then
			local s = SPR[IDX["dot#a"]]
			L = lab({ Image = SH[s[1]], ImageRectOffset = Vector2.new(s[2], s[3]), ImageRectSize = Vector2.new(s[4], s[5]) })
			dots[nDot] = L
		end
		return L
	end

	-- one sprite from the atlas: x,y design px (pivot = the original image centre), sc = render scale, rot = Roblox degrees
	local function sprite(idx, x, y, sc, rot, inten, col, z, sx, sy)
		local s = SPR[idx]
		local L = getSpr()
		local k = sc / s[6]
		local ox, oy = s[7] * sc * (sx or 1), s[8] * sc * (sy or 1)
		if rot ~= 0 and (ox ~= 0 or oy ~= 0) then
			local a = math.rad(rot) local c, si = math.cos(a), math.sin(a)
			ox, oy = ox * c - oy * si, ox * si + oy * c
		end
		set(L, "Image", SH[s[1]])
		set(L, "ImageRectOffset", Vector2.new(s[2], s[3]))
		set(L, "ImageRectSize", Vector2.new(s[4], s[5]))
		set(L, "Position", UDim2.fromOffset(X(x + ox), Y(y + oy)))
		set(L, "Size", UDim2.fromOffset(s[4] * k * (sx or 1) * S * zoom, s[5] * k * (sy or 1) * S * zoom))
		set(L, "Rotation", rot)
		set(L, "ImageColor3", col)
		set(L, "ImageTransparency", 1 - inten)
		show(L, z)
	end
	local function addcol(r, g, b, gain, alpha)
		local kr, kg, kb = r * gain, g * gain, b * gain
		local m = math.max(kr, kg, kb, 1e-6)
		return Color3.new(kr / m, kg / m, kb / m), math.min(1, alpha * m / AG)
	end
	local function c3n(r, g, b) return Color3.new(math.min(r, 1), math.min(g, 1), math.min(b, 1)) end

	-- ---------- the words (Cinzel letters as images), the same rules as v7 ----------
	local function drawText(t, z)
		if not (t > K.T_TEXT - 0.1 and t < K.T_TEXT_GONE + 0.1) then return end
		local R = redness(t)
		local C = mix3(BLUE, RED, R)
		local tc = mix3({ 0.90, 0.95, 1.0 }, { 1.0, 0.80, 0.76 }, R)
		local tcC = c3n(tc[1], tc[2], tc[3])
		if t >= K.T_RED and t < K.T_RED + 1.7 then
			local u = t - K.T_RED
			local te = t - 1.0
			local Re = redness(te)
			local ce = mix3(BLUE, RED, Re)
			local tce = mix3({ 0.90, 0.95, 1.0 }, { 1.0, 0.80, 0.76 }, Re)
			local mv = 1 - ease((u - 0.55) / 0.85)
			local ox, oy = 14 * mv, -7 * mv
			local ea = 0.27 * math.clamp(u / 0.1, 0, 1) * (1 - ease((u - 1.3) / 0.4))
			if ea > 0.003 then
				for _, L in ipairs(TXT) do
					if L[4] <= te and te < L[5] then
						local c, it = addcol(ce[1], ce[2], ce[3], 1.2, ea * 0.8)
						sprite(IDX["gly_" .. L[1] .. "_1#a"], L[2] + ox, L[3] + oy, 1, 0, it, c, z)
						sprite(IDX["gly_" .. L[1] .. "_0#n"], L[2] + ox, L[3] + oy, 1, 0, math.min(1, ea), c3n(tce[1], tce[2], tce[3]), z + 1)
					end
				end
			end
		end
		for _, L in ipairs(TXT) do
			local d = t - L[4]
			if d >= 0 then
				local dr = t - L[5]
				if dr < L[6] then
					local ch = L[1]
					if dr > 0 then
						local p = dr / L[6]
						local c, it = addcol(C[1], C[2], C[3], 1.0, 0.35 * (1 - p))
						sprite(IDX["gly_" .. ch .. "_2#a"], L[2], L[3], 1, 0, it, c, z + 2)
						c, it = addcol(C[1], C[2], C[3], 1.1, 0.45 * (1 - p))
						sprite(IDX["gly_" .. ch .. "_1#a"], L[2], L[3], 1, 0, it, c, z + 3)
						local stg = math.clamp(math.floor(p * 4), 0, 3)
						sprite(IDX["glyd_" .. ch .. "_" .. stg .. "#n"], L[2], L[3], 1, 0, 1, tcC, z + 4)
					else
						local ain = ease(d / (ch == 46 and 0.08 or 0.1))
						local pk = 0.9 * math.exp(-d / 0.12)
						local c, it = addcol(C[1], C[2], C[3], 1.0 + pk, ain * 0.35)
						sprite(IDX["gly_" .. ch .. "_2#a"], L[2], L[3], 1, 0, it, c, z + 2)
						c, it = addcol(C[1], C[2], C[3], 1.1 + pk, ain * 0.45)
						sprite(IDX["gly_" .. ch .. "_1#a"], L[2], L[3], 1, 0, it, c, z + 3)
						sprite(IDX["gly_" .. ch .. "_0#n"], L[2], L[3], 1, 0, ain, tcC, z + 4)
					end
				end
			end
		end
	end

	-- ---------- one frame of the v7 draw list ----------
	local u8, u16, i16, u32 = buffer.readu8, buffer.readu16, buffer.readi16, buffer.readu32
	local function rgbAt(o) return Color3.fromRGB(u8(D, o), u8(D, o + 1), u8(D, o + 2)) end
	local lastFi = -1
	local function drawFrame(fi, tScene)
		local o = u32(D, 4 + fi * 4)
		dx, dy, zoom = i16(D, o) / 4, i16(D, o + 2) / 4, u16(D, o + 4) / 10000
		local pFlood, pWhite, pWc, pInv, pEb, pFade = u8(D, o + 6) / 255, u8(D, o + 7) / 255, u8(D, o + 8), u8(D, o + 9), u8(D, o + 10) / 255, u8(D, o + 11) / 255
		o += 12
		local nops, nsets = u16(D, o), u8(D, o + 2)
		o += 3
		nPool, nRect, nDot = 0, 0, 0
		for _, L in ipairs({ tiles[1], tiles[2], tiles[3], tiles[4], fogb, fogt, txf, edge, vign, eyeL, plateL, negL, hgoL, ringL[1], ringL[2], flood, white, eblack, fadeR, bg2, bloomL, hgoL2, plateH, bfL, irisClip, irisL[1], irisL[2], irisL[3], irisL[4], irisL[5], irisL[6], irisL[7] }) do L.used = false end
		local zText = 900
		if fi >= 690 and fi <= 861 then
			local want, list = {}, {}
			local function add(id) if id and not want[id] then want[id] = true table.insert(list, id) end end
			for f = fi, fi + 30 do add(BFI[f]) end
			if fi + 30 >= 750 and fi <= 754 then add(WCORE) end
			for f = math.max(fi, 748), math.min(fi + 40, 861) do local h = HIMAP[f] if h then add(HI[h[1]]) end local om = OPMAP[f - f % 2] if om then add(OPL[om[1]]) end end
			for j, L in ipairs(warmL) do local id = list[j] if id then set(L, "Image", id) set(L, "Visible", true) else set(L, "Visible", false) end end
		elseif fi > 861 and not warmDone then
			warmDone = true
			for _, L in ipairs(warmL) do set(L, "Visible", false) set(L, "Image", "") end
		end
		for i = 1, nops do
			local ty = u8(D, o) o += 1
			local z = 10 + i * 6
			if ty == 1 then
				local idx, x, y, sc, rot, it = u16(D, o), i16(D, o + 2) / 4, i16(D, o + 4) / 4, u16(D, o + 6) / 1000, i16(D, o + 8) / 10, u8(D, o + 10) / 255
				if HGSET[idx + 1] then
					local c = rgbAt(o + 11)
					sprite(idx + 1, x, y, sc, rot, math.min(1, it * 1.12), Color3.new(math.min(1, c.R * 1.18), math.min(1, c.G * 1.18), math.min(1, c.B * 1.18)), z)
				else
					sprite(idx + 1, x, y, sc, rot, it, rgbAt(o + 11), z)
				end
				o += 14
			elseif ty == 2 then
				local tid, ox, oy, it = u8(D, o) + 1, u16(D, o + 1) / 16, u16(D, o + 3) / 16, u8(D, o + 5) / 255
				local L, t = tiles[tid], TILE[tid]
				local tw, th = t[2] * S, t[3] * S
				local x0, y0 = CX - 640 * S, CY - 360 * S
				set(L, "TileSize", UDim2.fromOffset(tw, th))
				set(L, "Size", UDim2.fromOffset(scrW + 2 * tw, scrH + 2 * th))
				set(L, "Position", UDim2.fromOffset(((x0 - ox * S) % tw) - tw, ((y0 - oy * S) % th) - th))
				if tid >= 3 then it = math.min(1, it * 1.9) end   -- v487: rain was ~half as bright as v7
				set(L, "ImageColor3", rgbAt(o + 6)) set(L, "ImageTransparency", 1 - it)
				show(L, z)
				o += 9
			elseif ty == 3 then
				local R = u8(D, o) / 255 o += 1
				bgG.Color = bgColors(1, R)
			elseif ty == 4 then
				local c, it = rgbAt(o), u8(D, o + 3) / 255 o += 4
				local r = getRect() set(r, "BackgroundColor3", c) set(r, "BackgroundTransparency", 1 - it) show(r, z)
			elseif ty == 5 then
				local roll, fa, c = u16(D, o), u8(D, o + 2) / 255, rgbAt(o + 3) o += 6
				local x0, y0 = CX - 640 * S, CY - 360 * S
				local tw = 1280 * S
				for j, L in ipairs({ fogb, fogt }) do
					local h = (j == 1 and 260 or 200) * S
					set(L, "TileSize", UDim2.fromOffset(tw, h))
					set(L, "Size", UDim2.fromOffset(scrW + 2 * tw, h))
					set(L, "Position", UDim2.fromOffset(((x0 + roll * S) % tw) - tw, j == 1 and (y0 + 460 * S) or y0))
					set(L, "ImageColor3", c) set(L, "ImageTransparency", 1 - fa * (j == 1 and 1 or 0.8))
					show(L, z)
				end
			elseif ty == 6 then
				local m = u8(D, o) / 255 o += 1
				local r = getRect() set(r, "BackgroundColor3", Color3.new(0, 0, 0)) set(r, "BackgroundTransparency", m) show(r, z)
			elseif ty == 7 then
				local p = u8(D, o) / 255 o += 1
				set(txf, "Position", UDim2.fromOffset(X(640), Y(360))) set(txf, "Size", UDim2.fromOffset(1280 * S * zoom, 720 * S * zoom))
				set(txf, "ImageTransparency", 1 - 0.2 * p) show(txf, z)
			elseif ty == 8 then
				local a = u8(D, o) / 255 o += 1
				set(edge, "ImageTransparency", 1 - a) show(edge, z)
			elseif ty == 9 then
				local q, a = u16(D, o) / 10000, u8(D, o + 2) / 255 o += 3
				local p = lerp(3.0, 2.0, ease(q * 1.6)) local cf = 2 ^ (1 / p)
				local ax, by = (K.TBX + 18) * cf, (K.TBY + 18) * cf
				local e = q ^ 1.4
				local Rx, Ry = ax + (1000 - ax) * e, by + (1000 - by) * e ^ 0.75
				local wc = 3 - p   -- 0 = rounded box ring, 1 = circle ring
				for j, nm in ipairs({ "ringr#a", "ringc#a" }) do
					local w = j == 1 and (1 - wc) or wc
					if w > 0.01 then
						local s = SPR[IDX[nm]]
						local L = ringL[j]
						local sx, sy = Rx / 490, Ry / 490
						set(L, "Image", SH[s[1]]) set(L, "ImageRectOffset", Vector2.new(s[2], s[3])) set(L, "ImageRectSize", Vector2.new(s[4], s[5]))
						set(L, "Position", UDim2.fromOffset(X(640), Y(360)))
						set(L, "Size", UDim2.fromOffset(s[4] / s[6] * sx * S * zoom, s[5] / s[6] * sy * S * zoom))
						set(L, "ImageColor3", Color3.new(1, 1, 1)) set(L, "ImageTransparency", 1 - math.min(1, a * w))
						show(L, z + j)
					end
				end
			elseif ty == 10 then
				local Rr, it, rot, c, num = u16(D, o) / 4, u8(D, o + 2) / 255, i16(D, o + 3) / 10, rgbAt(o + 5), u8(D, o + 8) o += 9
				sprite(IDX[num == 1 and "dial1#a" or "dial0#a"], 640, 360, Rr / 340, rot, it, c, z)
			elseif ty == 11 then
				local d, it, c = u16(D, o) / 1000, u8(D, o + 2) / 255, rgbAt(o + 3) o += 6
				local Lb = 120 + 1500 * (1 - math.exp(-d / 0.14)) local r0 = 40 + 500 * (1 - math.exp(-d / 0.3))
				for k = 0, 59 do
					local mj = k % 5 == 0
					local an = math.rad(k * 6 - 90)
					local wb = (mj and 26 or 5) * (1 - 0.5 * math.clamp(d / 0.8, 0, 1))
					local Lk = Lb * (mj and 1 or 0.55)
					local rs = r0 * (mj and 1 or 1.3) local rt = r0 + Lk
					local rm = (rs + rt) / 2
					sprite(IDX[mj and "beam1#a" or "beam0#a"], 640 + math.cos(an) * rm, 360 + math.sin(an) * rm, 1, k * 6 - 90, it, c, z, math.max(0.05, (rt - rs) / 520), math.max(0.25, wb / 26))
				end
			elseif ty == 12 then
				-- v487: the thin glowing hourglass frame around the sand silhouette (glow layer + hot core layer, both from v7's own drawing)
				local it, c = u8(D, o) / 255, rgbAt(o + 1) o += 4
				for j, L in ipairs({ hgoL, hgoL2 }) do
					set(L, "Image", HGOI) set(L, "ImageRectOffset", Vector2.new(j == 1 and 0 or 512, 0)) set(L, "ImageRectSize", Vector2.new(507, 504))
					set(L, "Position", UDim2.fromOffset(X(640.0), Y(360.0))) set(L, "Size", UDim2.fromOffset(724 * S * zoom, 720 * S * zoom))
					set(L, "ImageColor3", c) set(L, "ImageTransparency", 1 - math.min(1, it)) show(L, z + j - 1)
				end
			elseif ty == 13 then
				local sh, ex, ey, cx, cy = u8(D, o) + 1, u16(D, o + 1), u16(D, o + 3), i16(D, o + 5) / 4, i16(D, o + 7) / 4 o += 11
				set(eyeL, "Image", EYE[sh]) set(eyeL, "ImageRectOffset", Vector2.new(ex, ey)) set(eyeL, "ImageRectSize", Vector2.new(K.EYEFW, K.EYEFH))
				set(eyeL, "Position", UDim2.fromOffset(X(cx), Y(cy))) set(eyeL, "Size", UDim2.fromOffset(CW * S * zoom, CH * S * zoom))
				set(eyeL, "ImageTransparency", 0) show(eyeL, z)
			elseif ty == 14 then
				local sh, px, py = u8(D, o) + 1, u16(D, o + 1), u16(D, o + 3) o += 5
				local hm = HIMAP[fi]
				if hm then
					-- v487: the explosion debris + vortex at full detail: the centre of the sand at 30 fps, the sparse outer grains as before
					local om = OPMAP[fi - fi % 2] or OPMAP[fi - fi % 2 - 2]
					if om then sh, px, py = 0, om[2], om[3] set(plateL, "Image", OPL[om[1]]) else set(plateL, "Image", PLATE[sh]) end
					set(plateH, "Image", HI[hm[1]]) set(plateH, "ImageRectOffset", Vector2.new(hm[2], hm[3])) set(plateH, "ImageRectSize", Vector2.new(410, 512))
					set(plateH, "Position", UDim2.fromOffset(X(640.0), Y(360.0))) set(plateH, "Size", UDim2.fromOffset(512 * S * zoom, 640 * S * zoom))
					set(plateH, "ImageTransparency", 0) show(plateH, z + 1)
				else
					set(plateL, "Image", PLATE[sh])
				end
				set(plateL, "ImageRectOffset", Vector2.new(px, py)) set(plateL, "ImageRectSize", Vector2.new(512, 288))
				set(plateL, "Position", UDim2.fromOffset(X(640), Y(360))) set(plateL, "Size", UDim2.fromOffset(1280 * S * zoom, 720 * S * zoom))
				set(plateL, "ImageTransparency", 0) show(plateL, z)
			elseif ty == 15 then
				local k = u8(D, o) / 255 o += 1
				bg2G.Color = bgColors(k, 0) set(bg2, "BackgroundTransparency", 0) show(bg2, z)
			elseif ty == 18 then
				-- the video's bloom (glow halo), baked per frame at low res and added on top like the render's own bloom pass
				local sh, bx, by = u8(D, o) + 1, u16(D, o + 1), u16(D, o + 3) o += 5
				set(bloomL, "Image", BLOOM[sh]) set(bloomL, "ImageRectOffset", Vector2.new(bx, by)) set(bloomL, "ImageRectSize", Vector2.new(160, 90))
				set(bloomL, "Position", UDim2.fromOffset(CX, CY)) set(bloomL, "Size", UDim2.fromOffset(1280 * S, 720 * S))
				set(bloomL, "ImageTransparency", 0) show(bloomL, z)
			elseif ty == 19 then
				-- THE EYE AT XII, drawn live from crisp parts (lids, iris with clock ticks, the hands' slit) with v7's own numbers per frame
				local cx, cy, P, a = i16(D, o) / 4, i16(D, o + 2) / 4, u16(D, o + 4) / 1000, u8(D, o + 6) / 255
				local sac, RIf, sw, sa, lw, fl = buffer.readi8(D, o + 7), u8(D, o + 8) / 255, u16(D, o + 9) / 100, u8(D, o + 11) / 255, u8(D, o + 12) / 255, u8(D, o + 13) / 80
				o += 14
				local cyan = Color3.new(0, 0.784, 0.847)
				local blk = Color3.new(0, 0, 0)
				local function part(nm, x, y, sx, sy, it, col, zz)
					if it <= 0.003 then return end
					local s = EPS[nm]
					local L = getSpr()
					set(L, "Image", EP[s[1]]) set(L, "ImageRectOffset", Vector2.new(s[2], s[3])) set(L, "ImageRectSize", Vector2.new(s[4], s[5]))
					set(L, "Position", UDim2.fromOffset(X(x + s[7] / s[6] * sx), Y(y + s[8] / s[6] * sy)))
					set(L, "Size", UDim2.fromOffset(s[4] / s[6] * sx * S * zoom, s[5] / s[6] * sy * S * zoom))
					set(L, "Rotation", 0) set(L, "ImageColor3", col) set(L, "ImageTransparency", 1 - math.min(1, it))
					show(L, zz)
				end
				local function glow(nm, x, y, sx, sy, it, zz)
					part(nm, x, y, sx, sy, it * math.min(fl, 1), cyan, zz)
					if fl > 1 then part(nm, x, y, sx, sy, it * math.min(fl - 1, 1), cyan, zz) end
					if fl > 2 then part(nm, x, y, sx, sy, it * math.min(fl - 2, 1), cyan, zz) end
				end
				local va = math.max(a, 0.03)
				local dyc = 0.22 * 148 * (1 - a) * P
				-- v487: the iris + slit sit in a clip frame the height of the lid opening, so the lids cut them as they open (v7 masks them by the lids)
				local ia = sa
				local HLp = 148 * P
				local cTop, cBot = cy + lerp(0.22 * HLp, -HLp, a), cy + lerp(0.22 * HLp, 0.78 * HLp, a)
				local clx0, cly0 = X(cx - 400), Y(cTop)
				set(irisClip, "Position", UDim2.fromOffset(clx0, cly0)) set(irisClip, "Size", UDim2.fromOffset(800 * S * zoom, math.max(0, (cBot - cTop) * S * zoom)))
				show(irisClip, z + 1)
				local nIris = 0
				local function cpart(nm, x, y, sx, sy, it, col, zz)
					if it <= 0.003 then return end
					nIris += 1
					local L = irisL[nIris] if not L then return end
					local s = EPS[nm]
					set(L, "Image", EP[s[1]]) set(L, "ImageRectOffset", Vector2.new(s[2], s[3])) set(L, "ImageRectSize", Vector2.new(s[4], s[5]))
					set(L, "Position", UDim2.fromOffset(X(x + s[7] / s[6] * sx) - clx0, Y(y + s[8] / s[6] * sy) - cly0))
					set(L, "Size", UDim2.fromOffset(s[4] / s[6] * sx * S * zoom, s[5] / s[6] * sy * S * zoom))
					set(L, "ImageColor3", col) set(L, "ImageTransparency", 1 - math.min(1, it))
					show(L, zz)
				end
				local function cglow(nm, x, y, sx, sy, it, zz)
					cpart(nm, x, y, sx, sy, it * math.min(fl, 1), cyan, zz)
					if fl > 1 then cpart(nm, x, y, sx, sy, it * math.min(fl - 1, 1), cyan, zz) end
					if fl > 2 then cpart(nm, x, y, sx, sy, it * math.min(fl - 2, 1), cyan, zz) end
				end
				part("eyeD#n", cx, cy + dyc, P, P * va, 1, blk, z)
				cglow("iris#e", cx + sac, cy, P * RIf, P * RIf, ia, z + 1)
				cpart("slitH#n", cx + sac, cy, sw / 16, P, ia, blk, z + 2)
				cglow("slit#e", cx + sac, cy, sw / 16, P, ia, z + 3)
				local la = lw * math.clamp(a / 0.35, 0, 1)
				glow("eyeU#e", cx, cy + dyc, P, P * va, la, z + 4)
				glow("eyeL#e", cx, cy + dyc, P, P * va, la, z + 4)
				if a < 0.35 then glow("eyeC#e", cx, cy, P, P, lw * (1 - a / 0.35), z + 4) end
			elseif ty == 20 then
				-- the front sand wall draining down the lens: v7's column drain as vertical strips of the same wall image
				local kind, cx, cy, sc, sl, it = u8(D, o), i16(D, o + 1) / 4, i16(D, o + 3) / 4, u16(D, o + 5) / 1000, u16(D, o + 7) / 4, u8(D, o + 9) / 255
				local col = rgbAt(o + 10)
				o += 13
				local s = SPR[IDX[kind == 0 and "swg2#a" or "sw2#n"]]
				local wn, hn = s[4] / s[6], s[5] / s[6]
				local N = #NSTRIP
				for j = 0, N - 1 do
					local off = sl * (0.45 + 1.1 * NSTRIP[j + 1])
					local L = getSpr()
					set(L, "Image", SH[s[1]]) set(L, "ImageRectOffset", Vector2.new(s[2] + j * s[4] / N, s[3])) set(L, "ImageRectSize", Vector2.new(s[4] / N, s[5]))
					set(L, "Position", UDim2.fromOffset(X(cx + (s[7] + (-wn / 2 + (j + 0.5) * wn / N)) * sc), Y(cy + s[8] * sc + off)))
					set(L, "Size", UDim2.fromOffset(wn / N * sc * S * zoom + 1, hn * sc * S * zoom))
					set(L, "Rotation", 0) set(L, "ImageColor3", col) set(L, "ImageTransparency", 1 - it)
					show(L, z)
				end
			elseif ty == 16 then
				zText = z
			elseif ty == 17 then
				if pFlood > 0.003 then set(flood, "BackgroundTransparency", 1 - pFlood * 0.75) show(flood, z) end
				set(vign, "ImageTransparency", 0.3) show(vign, z + 1)
				if pWhite > 0.003 then set(white, "BackgroundColor3", pWc == 1 and Color3.new(1, 0.97, 0.95) or Color3.new(1, 1, 1)) set(white, "BackgroundTransparency", 1 - pWhite) show(white, z + 2) end
				if pEb > 0.003 then set(eblack, "BackgroundTransparency", 1 - pEb) show(eblack, z + 3) end
				if pFade < 0.997 then set(fadeR, "BackgroundTransparency", pFade) show(fadeR, z + 4) end
				if pInv > 0 then set(negL, "Image", NEG[pInv]) set(negL, "ImageTransparency", 0) show(negL, z + 5) end
			end
		end
		if BFI[fi] then
			-- v487: the white-hot burst frames are the video's own frames (additive white-out cannot be rebuilt from tinted layers)
			set(bfL, "Image", BFI[fi]) set(bfL, "Position", UDim2.fromOffset(CX, CY)) set(bfL, "Size", UDim2.fromOffset(1280 * S, 720 * S))
			set(bfL, "ImageTransparency", 0) show(bfL, 5000)
		end
		-- v491: white-hot core of the burst (v7 reads white at the centre with the colour around it): one soft white radial glow stacked 3x
		-- at the burst centre, scale pop 750 -> 751, gone by 755. Max ~690 px of 1280 wide: centre only, no full-screen white-out.
		local ck = CORE[fi]
		for j, L in ipairs(coreL) do
			if ck then
				local d = CORED[j] * ck[1] * S
				set(L, "Image", WCORE) set(L, "ImageColor3", Color3.new(1, 1, 1))
				set(L, "Position", UDim2.fromOffset(CX + (628 - 640) * S, CY + (356 - 360) * S)) set(L, "Size", UDim2.fromOffset(d, d))
				set(L, "ImageTransparency", 1 - ck[2] * (j == 1 and 0.75 or 1)) set(L, "Visible", true) set(L, "ZIndex", 5000 + j)
			elseif L.Visible then
				set(L, "Visible", false)
			end
		end
		drawText(tScene, zText)
		-- sand grains (points)
		local zP = zText - 1
		for _ = 1, nsets do
			local c = rgbAt(o)
			local n = u16(D, o + 3)
			o += 5
			for j = 0, n - 1 do
				local p = o + j * 5
				local x, y, v = u16(D, p) / 32 - 8, u16(D, p + 2) / 32 - 8, u8(D, p + 4) / 110
				local L = getDot()
				set(L, "Position", UDim2.fromOffset(X(x), Y(y)))
				local sz = 3.4 * S * zoom
				set(L, "Size", UDim2.fromOffset(sz, sz))
				set(L, "ImageColor3", c) set(L, "ImageTransparency", 1 - math.min(1, v * 0.9))
				show(L, zP)
			end
			o += n * 5
		end
		-- hide what this frame did not use
		for i = nPool + 1, #pool do set(pool[i], "Visible", false) end
		for i = nRect + 1, #rects do set(rects[i], "Visible", false) end
		for i = nDot + 1, #dots do set(dots[i], "Visible", false) end
		for _, L in ipairs({ tiles[1], tiles[2], tiles[3], tiles[4], fogb, fogt, txf, edge, vign, eyeL, plateL, negL, hgoL, ringL[1], ringL[2], flood, white, eblack, fadeR, bg2, bloomL, hgoL2, plateH, bfL, irisClip, irisL[1], irisL[2], irisL[3], irisL[4], irisL[5], irisL[6], irisL[7] }) do
			if not L.used then set(L, "Visible", false) end
		end
	end

	-- ---------- clock: the soundtrack ----------
	local snd = C.bank and C.bank.s and C.bank.s.track
	local t0 = nil
	local started = false
	local ended = false
	local function finishUi()
		if ended then return end
		ended = true
		local hint = Instance.new("TextLabel")
		hint.Name = "TapHint" hint.BackgroundTransparency = 1 hint.Text = "Tap to continue" hint.TextSize = 20
		hint.TextColor3 = Color3.fromRGB(225, 232, 245) hint.AnchorPoint = Vector2.new(0.5, 1)
		hint.Position = UDim2.new(0.5, 0, 0.93, 0) hint.Size = UDim2.fromOffset(400, 30) hint.ZIndex = 5000 hint.TextTransparency = 1
		hint.Parent = root
		pcall(function() if C.lockFont then C.lockFont(hint, C.faceOf(Enum.Font.GothamMedium)) end end)
		local tapper = Instance.new("TextButton")
		tapper.Name = "TapToClose" tapper.Text = "" tapper.BackgroundTransparency = 1 tapper.Size = UDim2.fromScale(1, 1) tapper.ZIndex = 5001
		tapper.AutoButtonColor = false tapper.Parent = root
		tapper.Activated:Connect(function() C.close() end)
		table.insert(st.conns, UIS.InputBegan:Connect(function(input)
			local kc = input.KeyCode
			if kc == Enum.KeyCode.ButtonA or kc == Enum.KeyCode.ButtonB or kc == Enum.KeyCode.Return or kc == Enum.KeyCode.KeypadEnter or kc == Enum.KeyCode.Space then C.close() end
		end))
		local h0 = os.clock()
		table.insert(st.conns, RunService.RenderStepped:Connect(function()
			local e = os.clock() - h0
			if e < 0.5 then hint.TextTransparency = 1 - 0.8 * (e / 0.5) else hint.TextTransparency = 0.2 + 0.35 * (0.5 + 0.5 * math.sin((e - 0.5) * 3.2)) end
		end))
	end
	local lastTp, lastClock = 0, nil
	RunService:BindToRenderStep("SOPBlessingCutscene", Enum.RenderPriority.Last.Value, function()
		if st.done then return end
		local nowc = os.clock()
		if not started then
			started = true
			t0 = nowc
			if snd then pcall(function() snd.TimePosition = 0 snd:Play() end) end
		end
		layout()
		-- the soundtrack is the clock; if it is not playing (blocked/failed), the wall clock carries on
		local tp = nowc - t0
		if snd and snd.IsPlaying and snd.TimeLength > 0 then
			local sp = snd.TimePosition
			if sp > 0 then tp = sp end
		end
		local fi = math.floor(tp * 30)
		if fi >= NF then
			fi = NF - 1
			if not ended then finishUi() end
		end
		if fi ~= lastFi then
			lastFi = fi
			drawFrame(fi, sceneT(tp))
		end
	end)
end

return M
