# Goldenmayhem Asset Library
Shared assets for future games. All are Mixamo animations on the standard 65-bone Mixamo skeleton, so they work on any character rigged in Mixamo.

| Folder | Packs | Good for |
|---|---|---|
| mixamo/guns | Pro Rifle, Rifle 8-Way Locomotion (2 versions), Pistol Handgun Locomotion, Slim Shooter | shooters, zombie survival, Breach Run-style games |
| mixamo/bow | Pro Longbow, Lite Longbow, Longbow Aiming | archery and hunting games |
| mixamo/zombie | Scary Zombie, Not So Scary Zombie | zombie enemies (Breach Run!) |
| mixamo/sports | Soccer Game Pack | football / party sports games |
| mixamo/female | Female Locomotion, Female Basic Locomotion | female characters |
| mixamo/comedy | Male Drunk | funny NPCs, joke emotes |

The fighting, magic, sword, axe, creature, injured, gesture and locomotion packs live in
`new-game/godot/AnimalWarriors3D/mixamo/` and can be reused from there too.

## Fight animations added (Nov 2026) — all safe for a commercial game
- mocap/cmu-mocap/ — 102 Carnegie Mellon motion-capture clips (boxing, karate kata and kicks, blocks, flips,
  falls, get-ups, rolls, cartwheels). Free to use in commercial games (you may not resell the raw data itself).
- mocap/glb/ — the same clips converted for game engines (tools/bvh2glb.py).
- kinemiq/ — 35 CC0 game animations (Quaternius Universal Animation Library via KinemIQ): punches, hit
  reactions, dodge roll, get-up, death, jumps, runs, sword moves. No credit required.
- Baked onto the robot (Mixamo) skeleton: new-game/godot/MayhemPreviews/anim/ — 372 ready-to-play moves
  (c_* = mocap, split into single strikes; k_* = CC0 pack). Re-bake with scripts/Bake.gd.
