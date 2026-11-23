# Dead Zone Mayhem (working title): handoff

Realistic zombie lane battler, portrait, Godot 4.4 (Compatibility renderer). Companion to the cartoon Squad Mayhem,
but a different game: gritty city, real soldiers, Mixamo zombies, guns, Warrok boss.

## Run it
Open this folder in Godot 4.4.x, press Play. First open takes a minute to import. Drag left/right to steer.

## What works now (first playable, Zone 1)
- Squad auto-runs and auto-fires. Shows up to 9 soldiers; the big number is the real squad size.
- Gates: +N, xN, -N, weapon upgrade (pistol, SMG, rifle, bullpup). Pass through the side you steer to.
- Caged survivors: steer next to them for +6 soldiers.
- Zombies (walkers + fast runners), elite mutant, boss Warrok with HP bar. Coins per kill.
- Win / lose screens with replay.

## Files
- scripts/main.gd: whole game (level list is the LEVEL constant at the top; edit distances and counts).
- assets/: see ASSET_LIST.md. tools/: scripts that turned the big FBX files into small GLBs.
- Test without a phone: `DZM_SHOTS=/tmp/shots DZM_TIMES=20,60 godot --path . --fixed-fps 30` autoplays and saves screenshots.

## Next steps (in order)
1. Tune Zone 1 balance on a real phone; check frame rate with 40+ zombies.
2. Hero select screen (heroes folder) and weapon/upgrade shop with coins.
3. Merge base between zones (shared idea with Squad Mayhem, different look).
4. More zones: other elites/bosses (pumpkin_hulk, moose_beast, blade_mutant), night level, rain.
5. Sound (Kenney audio is in asset-library/kenney-audio), ads (rewarded only), Android export and signing (owner does signing).

## Rules
No IAP in this game (studio rule). Rewarded video ads only. Never put keystores or passwords in files.
