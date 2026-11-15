# PASTE THIS INTO A NEW CLAUDE CHAT TO PICK UP WHERE WE LEFT OFF

You are continuing an ongoing project with me. Read everything below, then reply with one short line saying you're caught up and what the next step is. Don't redo finished work.

## Who I am and what we're doing
- I publish simple, addictive mobile games on **Google Play** under the studio name **Goldenmayhem** (developer email: goldenmayhem.games@gmail.com). Ads only (AdMob), **no in-app purchases**.
- My PC is Windows (user folder `C:\Users\indepth`). I build the Android apps in **Android Studio** and use the **Google Play Console** (personal developer account, so every new app needs a **closed test with 12+ testers for 14 days** before production).
- I'm not a programmer. Give me clear click-by-click steps, one small step at a time, and tell me exactly what to paste where.

## How I want you to work
- **Plan first, then build one small task at a time.** Show me the numbered task list before you start. If I say "do all the tasks without my approval", go through them all and report at the end.
- **Golden Mayhem standard kit** goes into EVERY game/app you build for me:
  1. Studio intro: "A game by Goldenmayhem" fades in/out, then the game's icon/logo animation transitions into the game (quick logo only on later launches, tap to skip)
  2. First-launch guided tutorial with a pointing hand + guide lines (replayable from Settings)
  3. Daily Challenge (hard but beatable) with calendar + streak; daily reminder notification (toggle)
  4. Free gift timer, chests/rewards, rate-us prompt (Google Play in-app review)
  5. Slow, challenging coin economy; boosters priced up to ~500; customization shop
  6. Replay levels/chapters with stars/best score; music, sound, vibration toggles; works offline
  7. Rewarded ads + occasional interstitials (test ads in debug builds, real ads in release); Google UMP consent + "Privacy options"; privacy policy page
  8. Android: **target/compile API 36**, secure WebView (no cleartext, no file access, Safe Browsing, outside links open in browser), splash screen with the icon, back gesture pauses instead of quitting
  9. Signed .aab + store listing text, 512 icon, 1024x500 feature graphic, Data safety answers
- Pick the right tool per game: simple 2D/puzzle games = single-file HTML5 game inside an Android WebView app (what we've been doing). Bigger 3D/action games can use **Godot** (I have Godot 4.7.2 at `C:\Users\indepth\Downloads\New folder (3)\Godot_v4.7.2-stable_win64.exe`, connected to the Claude desktop app with the `@coding-solo/godot-mcp` server; it only works while I message from the desktop app). Unity is another option.

## Game 1: Knot Out: Rope Untangle Puzzle (3D rope/arrow untangle puzzle)
- Package **com.knotout.game**. Current build: **v1.2, versionCode 6**, compileSdk/targetSdk 36. Project folder on my PC: the KnotOutAndroid project (Android Studio). AdMob app + real Rewarded and Interstitial units are already in the project.
- Playable web version (Claude artifact): https://claude.ai/artifact/PTiH8jojctpEzc97VDmgWn
- Privacy policy page: https://claude.ai/artifact/KA9E8Dqq1BXNVW7TEzPH9H (must be shared publicly: Share > anyone with the link)
- **Upload key history:** my original upload keystore was overwritten. I requested an upload key reset; Google approved it and the NEW key became valid on **Oct 23, 2026 (4:19 AM UTC)**. New keystore file: `Documents\knotout-upload` (alias `key0`, new cert SHA1 DB:AD:1D:C4:C8:A3:F9:5A:44:BB:2D:48:11:3D:CB:52:2B:23:2C:6B). The `app-release.aab` (versionCode 6) was already built with this new key. I must back the keystore up (Drive + USB) with its password.
- **Status / next steps:** upload `app-release.aab` to **Testing > Closed testing**, add testers (plan: a Google Group the testers join themselves, e.g. Golden Mayhem Testers), finish the store listing (text, icon, feature graphic, phone screenshots), App content forms (privacy policy, ads = yes, advertising ID = yes, Data safety for AdMob, content rating, target audience 13+), AdMob payments, then run the 14-day closed test and apply for production.
- Optional: put `three.min.js` (r128) into `app/src/main/assets/` so it works fully offline.

## Game 2: Breach Run (zombie extraction shooter, inspired by "Last Extract"-style games)
- Package **com.goldenmayhem.breachrun**. Current build: **v1.1, versionCode 2**, API 36. Android project: BreachRunAndroid (README inside explains everything).
- Playable web version: https://claude.ai/artifact/HajF9yuWskfPeZQbGMhAbP
- Privacy policy page: https://claude.ai/artifact/1anGykR6GyrcbnDeA5zk9D (needs to be shared publicly)
- Features done: cut-away "dollhouse" building, dark unexplored rooms, hold-to-search furniture loot, backpack, doors (close/repair/locked + keys), paid floor unlocks, zombie waves countdown, survivors who go to the extraction point, rooftop "Rescue is coming" hold-out + airstrike + helicopter, holographic level-up cards, chapters (Dorm Block, City Clinic, Office Tower, Shopping Mall, Research Lab), Daily Challenge, gifts/chests, shop (outfits, gun skins, tracers, boosts), upgrades, tutorial, intro, rate-us, interstitials, Android bridges.
- **Still to do (me):** create a "Breach Run" app in AdMob with one Rewarded + one Interstitial unit and paste the 3 IDs into `gradle.properties`; make a NEW upload key `Documents\breachrun-upload.jks` (alias `upload`) and back it up; create the app in Play Console, upload the .aab to closed testing, store listing + phone screenshots.

## Other earlier prototypes
- Sunstone Dash (Temple Run-style runner) and Hue Tower: early web prototypes, not being published yet.

## Notes for you (Claude)
- A new chat can't see the old workspace files. If you need the project files, ask me to attach `KnotOutAndroid-v1.2.zip` or `BreachRunAndroid-v1.1.zip` (or the game HTML). You can read the artifact links above directly.
- Never ask me to type passwords into chat or web forms for you; I enter passwords myself.
