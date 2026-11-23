# Turf War Mayhem : handoff

Realistic zombie lane battler, portrait, Godot 4.4 (Compatibility renderer). Companion to the cartoon Squad Mayhem,
but a different game: gritty city, real soldiers, Mixamo zombies, guns, Warrok boss.

## Run it
Open this folder in Godot 4.4.x, press Play. First open takes a minute to import. Drag left/right to steer.

## What works now
- Main menu: zone picker (3 zones: Downtown, Night Shift, The Fog; each unlocks after beating the one before), Play, Upgrades, Heroes, Quality (High = 3D up to ~1440p, Balanced = ~1080p) and an FPS counter toggle.
- Squad auto-runs and auto-fires; gates (+, x, -, new gun), caged survivors, walkers, runners, exploding zombies (zones 2-3), elites, a boss per zone with HP bar.
- Coins saved on the phone (user://turf_war_mayhem.json). Upgrades: damage, start squad, fire rate. Heroes (bought with coins): Hazmat +15% damage, Captain +4 squad, Red Agent +12% fire rate, Brawler takes 30% less boss damage. The hero leads the squad.
- Sound effects (Kenney, CC0) and win/lose jingles. Muzzle flashes, tracers, blood, camera shake.
- Performance: zombies cast no shadows, far zombies animate at a lower rate, sleeping zombies are frozen until the squad is near, 3D resolution capped, 60 FPS cap.

## Files
- scripts/main.gd: whole game (level list is the LEVEL constant at the top; edit distances and counts).
- assets/: see ASSET_LIST.md. tools/: scripts that turned the big FBX files into small GLBs.
- Test without a phone: `DZM_SHOTS=/tmp/shots DZM_TIMES=20,60 godot --path . --fixed-fps 30` autoplays and saves screenshots.

## Next steps (in order)
1. Test on a real phone: turn FPS ON in the menu and report the numbers with 30+ zombies. Zone 2 and 3 boss HP and horde sizes are guesses and need tuning.
2. More weapons (shotgun, sniper are converted but unused), hero special skills, daily rewards, missions, tutorial.
3. Merge base between zones (shared idea with Squad Mayhem, different look).
4. More zones: other elites/bosses (pumpkin_hulk, moose_beast, blade_mutant), night level, rain.
5. Sound (Kenney audio is in asset-library/kenney-audio), ads (rewarded only), Android export and signing (owner does signing).

## Rules
No IAP in this game (studio rule). Rewarded video ads only. Never put keystores or passwords in files.

## Performance and quality goals (owner standing target, all games)
120 FPS or higher and 4K-sharp visuals. Reality: the frame rate follows the phone's screen (many are 60 Hz, some 120 Hz); 3D resolution should be native to the screen with a quality setting. Keep zombie/soldier models light and use 2K+ textures only where seen up close.
