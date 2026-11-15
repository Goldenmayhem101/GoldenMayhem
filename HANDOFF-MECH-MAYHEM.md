# Mech Mayhem — handoff (from the cloud session, Nov 15 2026)

Owner: Goldenmayhem studio. Not a programmer, so give plain-language, step-by-step answers.
Studio rules: ad-only (rewarded ads, no in-app purchases), original IP, Android targetSdk 36. Every game starts with
the "A game by Goldenmayhem" intro and has a tutorial. This game also gets "Produced by Shawn Morris".

## The game
Mech Mayhem is a Brawlhalla-style 3D robot fighter in landscape. The arena is one flat, solid floor with nothing to
fall off. 1v1 now; 2v2 and 4-player are planned. Every character on the shared skeleton gets the same moves. The owner
will make custom human-shaped characters (Mixamo-rigged, FBX Binary with skin, T-pose) to plug in.
Stages are real places with recognisable landmarks: New York, Tokyo, Egypt. The crowd is shown sharp, with no blur.
The owner will supply landmark photos.

## Engine
Godot 4.7.2, project `new-game/godot/MayhemPreviews` (main scene Main.tscn).
Run a demo:   godot --path new-game/godot/MayhemPreviews -- --demo=<key>
Keys (scripts/Main.gd):
- robot_clip2: the main 12 s fight clip.
- stage_nyc, stage_tokyo, stage_egypt: stage stills.
- anim_sheet --anims=a,b --at=0.5: grid of moves.
- probe --anims=...: strike timing.
- bake --manifest=x.json: retarget animations onto the robot.
- zlineup: zombie character lineup.

## Key scripts
- Actor.gd: X Bot body, play(), ground_lock, stocky shape.
- Kit.gd: materials, shared animation library (res://a/*.fbx plus baked res://anim/*.res).
- RobotClip2.gd: fight clip and AI. MOVES[0] is red (motion-capture punches/kicks); MOVES[1] is blue (Mixamo
  sword and shield, ss_*).
- Bake.gd: offline retargeter that bakes CMU/KinemIQ clips onto the Mixamo skeleton (face-forward fix, auto-split
  into single strikes).
- StageShot.gd: the three landmark stages, built from code (the owner wants real photos instead of the primitive
  Statue of Liberty).

## Animation assets
- res://a: Mixamo fighting, soccer and zombie moves, plus 52 sword-and-shield moves (ss_*).
- res://anim: 372 baked moves. c_* are CMU motion capture (free for commercial games; the raw data may not be
  resold). k_* are the KinemIQ/Quaternius CC0 pack.
- asset-library/tools: bvh2glb.py (CMU BVH to GLB) and addskin.py (adds a skin and the mannequin bind pose to
  KinemIQ GLBs).

## Not in this zip (the owner has the originals)
- 652 earlier Mixamo FBX files.
- KayKit packs.
- Soccer, zombie and gun packs.
- 16 zombie packs (7 characters: yaku, cop, girl, war, clown, skeleton, pumpkin; plus "Not So Scary" with
  24 moves and "Scary" with 12 moves).

## Next steps the owner wants
1. Stages: use real photos or 3D landmark models (New York, Tokyo, Egypt). Check every asset's licence allows a
   commercial game.
2. Large environment packs (CGTrader, 700 MB+): check the licence (Royalty Free = OK, Editorial = not OK),
   then optimise them for mobile.
3. Fight polish: guard footwork (strafe, walk in stance) and a fair split of attacks.
4. Zombie survival shooter later, using the 7 zombie characters.

Never put keystores, passwords or tokens in files or replies.
