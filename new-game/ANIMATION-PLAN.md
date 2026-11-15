# Animal Warriors: Animation Analysis and Plan
All files you sent were unpacked, de-duplicated, loaded into Godot 4.7.2 and measured: length, whether the move travels across the floor, and how high the hips rise.
The full measurements are in `godot/AnimalWarriors3D/anim_catalog.tsv`.

## Totals
- **652 animation files** load and play in Godot with **0 failures**. All use the standard Mixamo skeleton (65 bones), so every one will transfer onto any warrior rigged in Mixamo.
- **Exact repeats ignored:**
  - Pro Melee Axe Pack_1 = Pro Melee Axe Pack (all 48 identical);
  - Soccer Game Pack_1 = Soccer Game Pack (all 55 identical);
  - Sword and Shield Pack is fully inside the Pro Sword and Shield Pack;
  - Lite Sword and Shield is almost all inside it too;
  - the Pro Longbow and Rifle zips were each sent twice.
- **Not used:**
  - guns and bows (Rifle ×3, Pistol, Slim Shooter, Longbow ×3);
  - Female locomotion ×2 (the warriors are male-built);
  - Zombie ×2 and Drunk (wrong style; one drunk stumble could be a joke taunt later).
- **Floor travel:** about 1 in 3 moves walk the body across the floor as they play. The game removes that movement, so the controls decide where the fighter goes.
- **Unique, useful moves after removing repeats:** about **420**.

## Every warrior has a fighting style (from the Character Bible)
The animation sets map onto those styles:

| Style | Warriors | Animation source | Coverage |
|---|---|---|---|
| **Bare fists** (everyone starts unarmed) | all | your loose files: 6 Boxing sets, Punching, Elbow Punch, Uppercut Jab, Surprise Uppercuts, Knee Jab, Knee Jabs to Uppercut, Punch-to-Elbow Combo, Fist Fight A/B, Roundhouse, Hurricane, Flying Kick, Flying Bicycle Kick, Inside Crescent, Kicking 1–3, Leg Sweep, Chapa / Martelo capoeira, Back Flip to Uppercut | **Excellent** |
| **Sword + shield** | Rooster, Tiger, Raven, Macaw, Falcon, Cobra, Gecko, Chameleon, Salamander, Caecilian, Piranha, Tuna | Pro Sword & Shield (52): 5 slashes, 4 attacks, kick, blocks, crouch block, impacts, power-up, casting | **Excellent** |
| **Heavy two-hand** (axe, hammer, mace, glaive) | Rhino, Alligator, Elephant, Tortoise, Bullfrog, Hellbender, Rhino Beetle, Bear, Komodo, Toad, Pufferfish, Stag Beetle, Mantis, Snapping Turtle | Great Sword (52) + Pro Melee Axe (48): spin attack, slide attack, jump attack, 5 slashes, 360 high/low, downward, backhand, combo ×3, run-jump attack, battlecry, chest thump | **Excellent** |
| **Spear / trident / polearm** | Wolf, Lion, Eagle, Owl, Peacock, Vulture, Ostrich, Penguin, Iguana, Croc, Python, frogs, Newt, Axolotl, Shark, Manta, Seahorse, Lionfish, Eel, Anglerfish, Ant, Wasp | no spear pack | **GAP** (see below) |
| **Beast / brute feel** | Gorilla, Bear, Hyena, Rhino, Komodo | Creature packs: mutant punch, swiping, jump attack, roaring, flexing, beast run, breathing idle | **Good** |
| **Magic** (every warrior casts) | all | Pro Magic + Magic Spell: 1H attacks ×3, 2H attacks ×5, **area attacks ×2**, cast spell, block start/idle/end/react | **Excellent** |

## Every game action, with the chosen animation
| Game action | Animation |
|---|---|
| Fight stance (loop) | Boxing (bouncing guard). Weapon styles use Sword & Shield Idle / Great Sword Idle |
| Walk | Walking / Standing Walk Forward |
| Run | Running / Standing Run Forward. Sprint = Standing Sprint Forward |
| Jump / double jump | Standing Jump, Jumping Up, Jump; double jump = Backflip |
| In the air | Falling Idle |
| Land | Hard Landing / Standing Land To Standing Idle |
| Dodge | Dodging; air dodge = goalkeeper Diving Save (soccer) |
| Block | Block, Body Block, Standing Block Start/Idle/End/React; shield block = Sword & Shield Block |
| Light attacks | jab, elbow, knee, front kick (loose files) |
| Combo strings | Punch to Elbow Combo, Knee Jabs to Uppercut, Boxing 1–5 |
| Up attack | Uppercut Jab / Surprise Uppercut / Back Flip to Uppercut |
| Low attack | Leg Sweep / soccer Slide Tackle |
| Air attacks | Flying Kick, Flying Bicycle Kick, soccer Scissor Kick |
| Heavy / charge | Hurricane Kick, Roundhouse, Great Sword High Spin, Mutant Jump Attack |
| Signature moves | Chapa Giratória, Martelo, Mutant Roaring, 2H Magic Area Attack |
| Got hit (small) | Hit To Head, Hit To The Legs, Kick To The Groin, React Small From Front/Back/Left/Right |
| Got hit (big) | React Large From Front/Back/Left/Right, Sword & Shield Impact |
| Launched / tumbling | Falling, Flying Back Death (first part), Knocked Down |
| Hit the floor / get up | Falling Flat Impact, Falling To Roll, Getting Up |
| High damage (hurt look) | Injured Hurting Idle, Injured Stumble Idle, Injured Walk |
| K.O. / defeated | Knocked Out, Dying, Death From The Front, Defeated |
| Pick up weapon | Unarmed Equip Over Shoulder / Draw Sword |
| Taunts / emotes | Taunt ×2, Taunt Battlecry, Chest Thump, Being Cocky, Angry Gesture, Flexing Muscles, Shaking Head No, Dance ×2 |
| Match entrance | Entry (10 s walk-on) |
| Victory | Victory ×2, Happy Hand Gesture, Flexing |
| Menus / character select | Gestures pack (nod, acknowledge, look away), idles |

## What's still missing
1. **The Hyena 3D model (most important).** Every file plays on Mixamo's grey practice dummy. Without each warrior's own model, the game shows dummies.
2. **Spear attacks.** About 22 warriors carry a spear or trident, and there's no spear pack. On Mixamo, try searching **"spear"**, **"thrust"**, **"stab"** and **"lunge"**, and send anything that looks like a two-handed forward stab. If Mixamo has little, I build spear thrusts by adjusting the two-handed sword moves in the game. That works, but real spear motion looks better.
3. **Flying for birds, the Bat and the Wasp.** "Flying" (superhero pose) works for launches. Wing flapping is done by me in Godot on the wing parts of each model, so no download is needed.
4. **Nothing else is needed.** Tails, wings, ears, capes, the Peacock's train and the Pufferfish inflate are all handled in Godot.

## App size note
The 652 files take 429 MB. The finished game only ships the roughly 150 moves it uses, combined into one shared animation library, so the download stays small.
