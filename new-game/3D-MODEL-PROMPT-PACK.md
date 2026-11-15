# Animal Warriors: 3D Model and Stage Prompt Pack

This is the step-by-step way to turn each warrior's reference sheet into a real 3D game character. Do it for the **Hyena** first. Once that one works, repeat it for the other warriors.

---

## STEP 1: Make a "3D-ready" picture of the warrior
Use the same image tool you used to make the reference sheets.

**Upload these 2 images first:**
- the warrior's big portrait (for example `05_Hyena.png`);
- the warrior's reference sheet (for example `004_Hyena_Reference_Sheet.png`).

**Then paste this prompt.** Change only the words in [brackets].

```
Using the uploaded [HYENA] warrior as the exact design reference, create a 3D character
model turnaround sheet of the SAME character: identical face, muzzle shape, ears, mane,
eye colour, fur colour and [SPOTS] pattern, identical bronze shoulder pauldron on the left
shoulder, leather chest strap with brass buckle, studded leather belt with round bronze
badge, layered leather skirt with ragged hem, studded leather bracers on both forearms.

Show 3 views side by side, full body, head to toe, same scale, perfectly aligned:
FRONT VIEW, SIDE VIEW (facing left), BACK VIEW.

Pose: neutral A-pose. Standing straight, feet shoulder-width apart, arms held out
diagonally down at 45 degrees away from the body, fingers open and slightly apart,
mouth closed, neutral expression. No weapon. No shield. No props.

Style: clean, flat, evenly lit colour, like a 3D modelling reference. No cast shadows,
no ground shadow, no dramatic lighting, no motion lines, no text, no labels, no frame.
Plain light-grey background. Same muscular heroic proportions as the reference.
High resolution, sharp, every detail clearly visible.
```

**What to fill in:**
- **Hyena:** HYENA / SPOTS.
- **Kangaroo:** KANGAROO / FUR. Add the sentence: *"Long thick tail resting on the ground behind, long hind feet."*
- **Any tailed or winged warrior:** add a sentence describing the tail or wings, so the tool doesn't leave them out.

**Check before moving on:**
- the face looks exactly like the portrait;
- the arms are away from the body, not touching it;
- no weapon is in the hands.

Generate it again until all three are true.

---

## STEP 2: Turn the picture into a 3D model (free tier is enough to test)
Pick **one** of these websites. Each has a free plan.
- **Meshy** (meshy.ai) → "Image to 3D" → **Multi-view**. Upload the front, side and back views. Crop them apart first if the tool asks for separate images.
- **Tripo** (tripo3d.ai) → "Multiview to 3D". Upload front, side and back.
- **Rodin / Hyper3D** (hyper3d.ai) → upload the views.

**Settings, if the tool shows them:**
- Texture: **On**.
- Polycount or "Topology": **Medium**, around **30,000 triangles**. Choose **Quad** if offered.
- Pose: **A-pose** if offered.
- Symmetry: **On**.

Download the model as **FBX**, or as GLB if FBX isn't offered.

**Check the result:**
- Turn it around in the preview.
- Hands, face and tail should look clean.
- If the face is mushy, regenerate. Running it again often gives a better result.

---

## STEP 3: Add a skeleton and fight animations (Mixamo, free)
1. Go to **mixamo.com** and sign in with a free Adobe account.
2. Click **Upload Character** and choose the FBX from Step 2.
3. Place the circles on the chin, wrists, elbows, knees and groin, then click **Next**. Mixamo builds the skeleton automatically. Set Skeleton LOD to **Standard Skeleton (65)**.
4. When it shows the character moving, click **Next** to confirm.
5. Search for each animation below and click **Download**:
   - Format: **FBX Binary**.
   - Skin: **With Skin** for the FIRST one only, **Without Skin** for all the others.
   - Frames per second: **30**.
   - Keyframe reduction: **None**.

**The animation list** (tick "In Place" whenever that box appears):

| Game move | Mixamo search name |
|---|---|
| Fight stance | Fight Idle |
| Run | Running |
| Jump | Jump |
| In the air | Falling Idle |
| Land | Landing |
| Jab | Lead Jab |
| Punch combo | Punching |
| Uppercut | Uppercut |
| Hook | Hook Punch |
| Front kick | Mma Kick |
| Spin kick | Roundhouse Kick |
| Low sweep | Leg Sweep |
| Heavy slam | Standing Melee Attack Downward |
| Weapon swing (axe) | Standing Melee Attack Horizontal |
| Weapon overhead | Standing Melee Attack 360 High |
| Block | Center Block |
| Dodge | Dodging |
| Cast magic | Standing 2H Magic Attack 01 |
| Get hit (light) | Head Hit |
| Get hit (big) | Big Side Hit |
| Knocked flying | Falling Back Death |
| Get up | Getting Up |
| Taunt | Taunt |
| Victory | Victory |
| Defeated | Defeated |

6. Put all the FBX files in one folder named after the warrior, zip it, and upload it to me.

**Note:** Mixamo only animates the human-shaped body. **Tails, wings, ears and capes** are animated by me inside Godot with springy physics, so a tail swings and flops naturally on its own.

---

## STEP 4 (optional, later): Faces that change expression
Your sheets have 8 expressions for every warrior. In 3D, a changing face needs "face shapes" (blendshapes) built into the model. Image-to-3D tools don't make those. Two ways to handle it:
1. **Right away (I do this):** use your 8 sheet expressions in the HUD portrait and on menus. The portrait reacts to the fight: angry when hit, surprised when launched, worried at high damage, confident when winning, happy at victory. During a fight the 3D bodies are small on screen, so this is where faces are actually noticed.
2. **Later (freelancer):** a 3D artist adds 5–6 face shapes per model: angry, surprised, happy, hurt, blink, mouth open. It's a small one-off job per character. I hook them up so the 3D face matches the HUD.

---

## STEP 5: Stage art (makes the game look professional)
Popular platform fighters use **painted backgrounds in layers** behind a 3D or 2D floor. The layers slide at different speeds as the camera moves, which gives a rich, deep look cheaply. Make each stage as **4 separate images** with the same prompt base, changing only the layer line.

**Prompt base** (fill in the [STAGE] idea):
```
Video game stage background art for a side-view platform fighting game, in the same
hand-inked comic style as the uploaded warrior reference sheets: bold black ink outlines,
fine hatching, warm cel shading, rich saturated colour.
Stage theme: [STAGE: e.g. "a sunlit ancient savannah colosseum built from sandstone,
with bronze statues of animal warriors, red and gold banners, acacia trees beyond the walls"].
Wide panoramic landscape, 21:9, 3840 x 1640 pixels, no characters, no text, no UI.
```
**Then add ONE of these lines per image:**
1. `LAYER 1 - SKY ONLY: sky, sun and clouds, nothing else.`
2. `LAYER 2 - FAR DISTANCE: distant mountains / mesas / city skyline on a plain light-grey background, bottom half empty.`
3. `LAYER 3 - MIDDLE: the arena walls, columns, statues and banners, on a plain light-grey background, top third empty.`
4. `LAYER 4 - FLOOR STRIP: a long flat stone fighting floor seen from the side, slightly from above, with a decorative front edge, on a plain light-grey background. Seamless and tileable left to right.`

I remove the grey backgrounds and build the layered stage with lighting, dust, drifting clouds, flags waving and so on.

**Stage ideas that suit the roster:**
- Savannah Colosseum (mammals);
- Sky Temple on cliff tops (birds);
- Jungle Ruins with a waterfall (reptiles and amphibians);
- Sunken Reef Palace (fish);
- Giant Hollow Tree / Hive (insects);
- Volcano Forge.

---

## What to send back
- **Hyena:** the zip of Mixamo FBX files (Step 3).
- **Kangaroo:** the same, when you're ready.
- **Savannah Colosseum:** 4 layer images (Step 5).
