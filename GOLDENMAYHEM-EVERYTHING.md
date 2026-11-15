# GOLDENMAYHEM — FULL HANDOFF FOR CLAUDE CODE
(Paste or attach this file at the start of a Claude Code session. It contains NO passwords, keystores or keys.)

## 0. How to work with this owner
- Owner runs the **Goldenmayhem** studio and is a **non-programmer**. Use plain language, give exact click-by-click steps, and never assume they know Gradle/Android Studio terms.
- Work in **small numbered tasks**: plan the list, build and check each task, then move on.
- **Do not re-ask** about accounts, package names, testers or setup — everything is below.
- Never put keystores (.jks), passwords or tokens in any file or reply. Only `upload_certificate.pem` (public) exists in /home/claude.
- Another chat (claude.ai, the "browser chat") keeps the **browser automation role**: Google Play Console and AdMob dashboard work. Claude Code can't do that. When a task needs the dashboard, write the exact request for the user to paste into that chat.

## 1. Accounts
| Thing | Value |
|---|---|
| Play developer account | "Goldenmayhem" (personal, verified). Games contact: goldenmayhem.games@gmail.com |
| Play Console URL base | `https://play.google.com/console/u/1/developers/6967521863938440513/` (use **/u/1/**; /u/0 is a wrong-account sign-up page — never create accounts) |
| AdMob | Under **shawnmad86@gmail.com**, publisher `ca-app-pub-3920854813859561`. Single AdMob account for all games |
| Claude owner account | mannohydra@gmail.com |
| Tester Google Groups | goldenmayhemtesters@googlegroups.com, testers-community@googlegroups.com, testcircle-testers@googlegroups.com |
| Opt-in link format | `https://play.google.com/apps/testing/<package>` |

## 2. Standing rules (apply to EVERY game)
1. Fully **original** — no copyright/trademark risk in names, art, items.
2. **Ad-only** monetization (rewarded or player-chosen ads). **No IAP.** No pop-up/unprompted ads.
3. Every game includes: "A game by Goldenmayhem" fade-in intro with icon transition, a first-launch guided tutorial, and **targetSdk 36**.
4. A fine line "Produced by Shawn Morris" under the intro line on **certain apps only** — the owner will say which. Don't add it by default.
5. For every app deliver a full copy-paste **Play launch pack**: title, short description, long description, icon 512, feature graphic 1024x500, phone + tablet screenshots (in each project's `store/`).
6. Bump `versionCode` by 1 on every upload. Package names can never be reused or changed.
7. Games are single-file Android WebView apps (see §5).

## 3. App inventory (all under /home/claude)
| Project dir | Package | versionCode / Name | AdMob app ID | Ad units | Status |
|---|---|---|---|---|---|
| KnotOutAndroid | com.knotout.game | 6 / 1.2 | ~6602808968 (in manifest/buildConfigFields) | real IDs in release buildConfigFields | Published/testing; zip KnotOutAndroid-v1.2.zip |
| BreachRunAndroid | com.goldenmayhem.breachrun | 2 / 1.1 | real ID via gradle property `breachAdmobAppId` (falls back to Google test ID) | — | closed test; BreachRunAndroid-v1.1.zip |
| HueTowerAndroid | com.goldenmayhem.huetowergame | 2 / 1.1 | ~8544606284 | rewarded /1624149724, interstitial /5503684986 | closed test; **v2 build still needs upload** (HueTowerAndroid-v1.1.zip) |
| LinkscribeAndroid | com.goldenmayhem.linkscribe | 2 / 1.1 | ~4306153389 | banner /6664723417, rewarded /7750399367 | closed test; **v2 build still needs upload**; uses Render server (§6) |
| MoonhopAndroid | com.goldenmayhem.moonhop | 1 / 1.0 | ~7554856619 | rewarded /6948351953, interstitial /2302529932 | closed test; verify uploaded build's package ID |
| TiltrixAndroid | com.goldenmayhem.tiltrix | 1 / 1.0 | ~9206637609 | rewarded /9989448264, interstitial /1504453581 | closed test; applicationId was corrected from `tiltrixgame` to `tiltrix` — **verify the uploaded build's package ID matches Play Console** |
| LudoraDiceAndroid | com.goldenmayhem.ludoradice | 2 / 1.1 | ~3188337821 | rewarded /2553913004 | In Play review; **v1.1 AAB (versionCode 2) must be built and uploaded**; zip LudoraDiceAndroid-v1.1.zip |
| Sunstone Dash | (HTML only: sunstone-dash.html) | — | — | — | prototype |

All projects: `isMinifyEnabled = false`. Real AdMob IDs live in each project's `gradle.properties`; build.gradle falls back to Google **test** IDs if properties are missing. AdMob IDs are not secret.
Each project has `store/` with LAUNCH-PACK.txt (Breach Run: store-listing.txt), icon-512.png, feature-graphic-1024x500.png, screenshots/, tablet/. Privacy pages are published as artifacts (see §8).

## 4. Play Console / testing state
- All apps use **Closed testing (Alpha)** with testers via **Google Groups** (NOT email lists). Internal testing was removed. Root cause of earlier "App not available" was Email lists; fixed on all checked apps. Remaining causes are group membership or review status.
- Closed test needs **12+ testers for 14 days**, then apply for production.
- Until a new app passes review, the opt-in install page shows **"Item not found"** — that's normal, not a bug (this happened for Ludora Dice).
- Account audit done: Policy status clean, no warnings, permissions minimal. Privacy policy URLs on all apps point to the public artifact pages.
- Reddit tester-recruiting kit is in `send/` (Reddit-posts-v2.txt, Reddit-tester-posts.txt, Reddit-images.zip). Tiltrix links corrected to com.goldenmayhem.tiltrix. **The owner posts manually** (reddit.com is blocked in the browser chat).

## 5. Android build facts
- Kotlin `MainActivity`, WebView loading `assets/index.html` via `WebViewAssetLoader`; JS bridges `AndroidApp` / `AndroidAds`.
- AdMob app ID passed through manifest placeholder `admobAppId`.
- Build procedure (owner uses Android Studio): open project → bump `versionCode` in `app/build.gradle.kts` → Build > Generate Signed Bundle (AAB) with the **owner's upload key (.jks, kept only on their PC)** → upload AAB in Play Console > Closed testing > Create release. Play app signing is on.
- Open notice: Linkscribe "DEX optimization / minify" notice, deadline **Feb 2027**. Consider enabling R8 minification with testing.

## 6. Linkscribe server
Node server (`LinkscribeAndroid/server-update/server.js`) on Render free tier. In-memory quota; `REWARD_CREDITS` default 1; limit 2 per 2 hours. Rewarded SSV: `handleSsv` returns 200 for ping without signature, 403 for bad signature, 400 if `user_id` doesn't match `/^[A-Za-z0-9-]{16,64}$/` or `transaction_id` is missing. Client uses `(q.rewardCredits || 1)`.

## 7. Ludora Dice ("Ludora: Fair Play Dice Game") — full change list
File: `LudoraDiceAndroid/app/src/main/assets/index.html` (backups: ludoradice-index-backup.html, -backup2, -backup3).
Done in v1.1:
- Lucky Rolls: `LUCK_PER_GAME=10`, `LUCK_DAILY=10` (daily check `set.lkd!==t||set.lkv!==2`); ads still +1 each, no ads mid-game.
- Bigger board: `BS=Math.min(w,720)`, `.app{max-width:720px}`; pawns `CELL*1.1 × CELL*1.72`.
- Safer taps: nearest-pawn logic with "Tap closer to the pawn you want to move." toast when ambiguous.
- Clean play screen: names under avatars, pips hidden, smaller dice with colored halo (no hand emoji/dotted circles), settings under a top-right gear (Help in settings as `#s-help`), emoji bar at bottom, tilted plane.
- New home screen: swipeable mode cards, side icons, setup pop-up `#ov-setup` (players / mode / stakes-bets), team match shows partner (team A = Blue + Green), stake deducted in `startLocal`, paid out in `showWin`.
- Welcome treasure chest on first launch: 10,000 coins + 100 gems (`set.gift`).
- Data: BOTNAMES Ruby/Mint/Sunny/Blu; SEATHEX #F0343E #2FD34E #FFC82A #2F86FF.
- Fixed bugs: setup overlay z-index (`#ov-setup{z-index:70}`), `.sbtn.dot` collision, chest button styling.
Rules from owner: no pop-up/unprompted ads, only chosen rewarded videos, gems hard to earn and store prices high, 1st and 2nd place in non-team online games, online-room board voting (default after ~7s), modes Classic/Blitz.
Previews (private artifacts): Ludora Dice Preview https://claude.ai/artifact/22ufpHNzS8DQ7eQ8xV4RjY ; Ludo UI Preview https://claude.ai/artifact/PW4vLQ1dPs8w2Z2Fm3t6ZP (design source in the browser chat's scratchpad; may not be available to you).

## 8. Public privacy policy artifacts (anyone with link)
claude.ai/artifact/ + : Ludora Dice `RM6P5yFsZenntMRaZwMeT9`; Linkscribe `WCd3NCY91ppBKAHhmEirHr`; Hue Tower `NruVLGTydhwiybgQxy2iMb`; Moonhop `RJJWArFFsPnuLrFNJE8G9q`; Tiltrix `BtsacaNjCdAye3sSyrmK4C`; Breach Run `1anGykR6GyrcbnDeA5zk9D`; Knot Out `KA9E8Dqq1BXNVW7TEzPH9H`.

## 9. OPEN ITEMS (priority order)
1. **Rename "Ludora"** — another game with that name exists (unconfirmed how serious). Touches app label, logo/intro, listing text, privacy policy; package `com.goldenmayhem.ludoradice` can't change. Owner wants a suffix-style name.
2. **Port the 10-language picker** (exists only in the Design preview) into the real game; Arabic must flip RTL.
3. **Test stake payout** in a fully finished real game (never exercised).
4. **Online rooms need a hosted server** — not decided; won't work in the preview.
5. Build + upload new AABs: Ludora Dice v1.1 (versionCode 2), Linkscribe v2, Hue Tower v2.
6. Verify uploaded-build package IDs for Tiltrix and Moonhop vs Play Console.
7. Monitor Ludora Dice Play review.
8. Owner posts Reddit tester posts manually.
9. After 14 days with 12+ testers: apply for production per app.
10. AdMob **"Add store"** (link Play listings) after apps go live; ad serving is limited until then. Never click own ads; use test devices.
11. Decide which apps get "Produced by Shawn Morris".
12. DEX/minify notice, deadline Feb 2027.
13. Keep refining the games (gameplay polish, balance, UI) — owner will give direction per game.

## 10. Tooling notes
- Playwright + Chromium is handy for screenshots/tests (fonts Baloo 2 / Nunito).
- In the browser chat: Play Console list-page clicks sometimes don't navigate — use IDs from URLs.

# ===== APPENDIX A: OLD RESUME PROMPT =====
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

# ===== APPENDIX: BreachRunAndroid/store/store-listing.txt =====
BREACH RUN – GOOGLE PLAY STORE LISTING
(Copy each part into Play Console > Grow users > Store presence > Main store listing)

──────────────────────────────
APP NAME  (max 30 characters)
──────────────────────────────
Breach Run: Zombie Extraction

──────────────────────────────
SHORT DESCRIPTION  (max 80 characters)
──────────────────────────────
Loot the building, rescue survivors and hold the roof until the chopper lands!

──────────────────────────────
FULL DESCRIPTION  (max 4000 characters)
──────────────────────────────
The building is overrun. Your only way out is up.

Breach Run is a zombie survival shooter you play with one thumb. Fight your way through a cut-away building room by room, search every locker and desk for loot, rescue trapped survivors, and climb to the roof. Then hold out against the horde until the rescue chopper arrives.

HOW TO PLAY
• Drag anywhere to move. Your soldier aims and shoots on his own
• Stand still at furniture to search it for cash and valuables
• Close doors to stop zombies in their tracks, until they break through
• Climb ladders to reach the next floor
• Reach the roof and survive the countdown. Then the airstrike hits and you're out

FEATURES
• Dark, unexplored rooms that light up as you walk in. You never know what's inside
• Walkers, fast runners and huge brutes that smash through doors
• Zombie waves on a countdown: get ready or get swarmed
• Spend cash to unlock the next floor, and find keys for locked doors
• Stand by a damaged door to repair it before it breaks
• Find upgrade cards in rooms: extra bullets, rapid fire, piercing and explosive rounds, and more
• Rescue survivors who meet you at the extraction point and fight beside you
• Fill your backpack with dog tags, gold watches, data drives and rare gems
• 5 locations (Dorm Block, City Clinic, Office Tower, Shopping Mall, Research Lab) with taller, tougher buildings each chapter
• Earn up to 3 stars per chapter and replay to beat your best haul
• Daily Challenge: a brand-new, extra-tough building every day. Keep your streak going
• Free gifts and supply chests
• Unlock outfits, gun skins and bullet tracers, and pick boosts before a run
• Permanent upgrades: armor, firepower, sprint, scavenger, bigger backpack and drum mag
• Plays offline. No purchases needed. Everything is earned by playing

How long can you survive? Breach in, grab the loot, and run.

──────────────────────────────
APP CATEGORY / TAGS
──────────────────────────────
App or game: Game
Category: Action
Tags (pick up to 5): Action, Shooter, Zombie, Survival, Offline

──────────────────────────────
GRAPHICS TO UPLOAD
──────────────────────────────
App icon (512×512 PNG):           icon-512.png
Feature graphic (1024×500 PNG):   feature-graphic-1024x500.png
Phone screenshots (2–8 needed):   take these on your phone while playing (Power + Volume Down),
  or send them to me and I'll turn them into store-sized images with captions.
  Good shots: the intro icon, searching a bunk bed, a fight in a room, the level-up cards,
  the red rooftop countdown, the Challenge Completed backpack screen, the Shop.

──────────────────────────────
APP CONTENT ANSWERS (Play Console > Policy > App content)
──────────────────────────────
Privacy policy:      the Breach Run privacy policy page (make it public first: Share > anyone with the link)
Ads:                 Yes, my app contains ads
App access:          All functionality is available without special access
Content rating:      Fill in the questionnaire. Action game with cartoon/fantasy violence against
                     zombies (no realistic gore, no blood on humans), no user chat, no gambling,
                     no real-money purchases. Expect about Teen / PEGI 12.
Target audience:     13+ (choose 13–15, 16–17 and 18+). Not designed for children.
In-app purchases:    No
Financial features:  None
Health features:     None
Advertising ID:      Yes, the app uses the advertising ID (for ads)
Data safety (because AdMob is used):
  • Does your app collect or share user data?  Yes
  • Data types: Device or other IDs (advertising ID); App info and performance
    (crash logs, diagnostics); App activity (app interactions)
  • Purpose: Advertising or marketing; Analytics; Fraud prevention, security and compliance
  • Shared with third parties: Yes (Google AdMob)
  • Encrypted in transit: Yes
  • Users can request deletion: No account is created; game progress stays on the phone
  Google's guide for AdMob answers: https://developers.google.com/admob/android/privacy/play-data-disclosure

# ===== APPENDIX: HueTowerAndroid/store/LAUNCH-PACK.txt =====
HUE TOWER – GOOGLE PLAY LAUNCH PACK   (Goldenmayhem)
Copy each part into Play Console. Character limits are already respected.

============================================================
1. APP DETAILS (Create app)
============================================================
App name: Hue Tower: Color Block Stack   (28/30)
Package name: com.goldenmayhem.huetowergame
Default language: English (United States) – en-US
App or game: Game
Free or paid: Free

============================================================
2. MAIN STORE LISTING  (Grow users > Store presence > Store listings)
============================================================
APP NAME (28/30)
Hue Tower: Color Block Stack

SHORT DESCRIPTION (74/80)
Tap to drop color blocks, land perfects and stack your tower to the stars!

FULL DESCRIPTION (1170/4000)
How high can you build? Tap to drop each sliding block onto your tower. Line it up perfectly, because anything hanging over the edge gets sliced off and your tower gets thinner.

Hue Tower is a colorful, one-tap block stacking game. It takes one second to learn and a lifetime to master.

HOW TO PLAY
• A block slides back and forth above your tower
• Tap to drop it
• Overhangs get sliced off, so line it up
• Land perfects to keep your tower wide

FEATURES
• FEVER: chain 5 perfects in a row for double coins and easier perfects
• Power-up blocks: WIDE grows your tower back, SLOW calms things down, ×5 gold pays out
• Climb through 5 sky zones, from Dusk to Deep Space
• 30 levels with goals and stars: land perfects for 3 stars
• Endless mode with a best-score line to beat
• Daily Challenge: a new tower every day. Keep your streak alive
• Missions that level up as you play
• Free gifts every few hours and supply chests
• Tower themes: Candy, Glacier, Lava, Neon and Gold Rush
• Boosters: Slow start, Wide base and Safety net
• Music, sound and vibration you can switch off
• Plays offline. No purchases. Everything is earned by playing

Tap. Drop. Stack the sky!

============================================================
3. GRAPHICS  (all inside this store folder)
============================================================
App icon, 512×512 PNG ............ icon-512.png
Feature graphic (banner), 1024×500 feature-graphic-1024x500.png
Phone screenshots, 1080×1920 ...... screenshots/01 … 06 (upload all 6, in order)
7-inch tablet screenshots ......... tablet/01 … 06 (1440×2560)
10-inch tablet screenshots ........ tablet/01 … 06 (same files are fine)
Promo video ....................... optional, leave empty for now
Screenshot captions, in order:
  1. Tap to drop. Stack the sky!
  2. Chain perfects for FEVER
  3. Climb through 5 sky zones
  4. 30 levels, 3 stars each
  5. A new tower every day
  6. Missions & rewards

============================================================
4. STORE SETTINGS  (Grow users > Store presence > Store settings)
============================================================
Category: Arcade
Tags (pick these): Arcade, Casual, Offline, Single player, Stylized
Contact email: goldenmayhem.games@gmail.com
Phone / website: leave empty
Search keywords (already woven into the description; use for ads/notes): stack game, tower stacking, block stack, tap game, one tap, stack tower, offline arcade, casual game, rainbow blocks, timing game

============================================================
5. APP CONTENT  (Policy > App content)
============================================================
Privacy policy:
  https://claude.ai/artifact/NruVLGTydhwiybgQxy2iMb   (open it first, Share, set to "Anyone with the link")

App access / Sign-in details:
  All functionality is available without special access (choose "No")

Ads:
  Yes, my app contains ads

Content rating:
  Questionnaire: category "All other app types" > Game. Answer NO to: violence, blood, fear, sexuality, nudity, bad language, drugs, alcohol, tobacco, gambling, simulated gambling, user interaction/chat, sharing location, sharing personal info, digital purchases. Expected result: Everyone / PEGI 3 / USK 0.

Target audience:
  Ages 13–15, 16–17 and 18+ (do NOT tick under 13). "Could your app unintentionally appeal to children?": No.

Data safety:
  Collects or shares data: Yes. Encrypted in transit: Yes. Account creation: none. Deletion: users can uninstall / data stays on the phone.
  Data types (all "Collected" AND "Shared", processed ephemerally: No, required: Yes):
   • Device or other IDs  → purposes: Advertising or marketing; Fraud prevention, security and compliance
   • App interactions (App activity) → Advertising or marketing; Analytics
   • Crash logs + Diagnostics (App info and performance) → Analytics; Fraud prevention, security and compliance
  Shared with: Google AdMob (third party ad network).

Advertising ID:
  Yes, uses advertising ID → purposes: Advertising or marketing; Analytics

Government apps:
  No

Financial features:
  My app doesn't provide any financial features

Health:
  My app does not have any health features

News app:
  No

In-app purchases:
  None (free, ads only)

AI asset declaration (store listing step 2):
  Label assets as created or edited using AI, then tick all of them

============================================================
6. CLOSED TEST  (Test and release > Closed testing > Alpha)
============================================================
Countries: Add all countries / regions
Testers: Google Groups → goldenmayhemtesters@googlegroups.com
Feedback URL or email: goldenmayhem.games@gmail.com
Release name: 1.0 (1)
Release notes:
<en-US>
First test build of Hue Tower! Tap. Drop. Stack the sky! Please send feedback and bugs to goldenmayhem.games@gmail.com
</en-US>
Tester opt-in link (works once Google approves the test): https://play.google.com/apps/testing/com.goldenmayhem.huetowergame

============================================================
7. AdMob
============================================================
NOT DONE YET: create a "Hue Tower" app in AdMob with one Rewarded + one Interstitial unit, then paste the 3 IDs into gradle.properties (until then the app shows Google test ads)
After the game is live on Google Play: AdMob > Apps > Hue Tower > Add store, then finish your AdMob payments profile.

============================================================
8. TESTER RECRUITMENT POST  (Reddit r/AndroidClosedTesting, r/TestersCommunity, Discord)
============================================================
TESTERS NEEDED, WILL RETURN THE FAVOUR.

Looking for testers for my Android game, Hue Tower: Color Block Stack.

Tap to drop each block. Line up perfects and stack your tower to the stars! Free to play, no in-app purchases, works offline.

How to join:
1. Join the testers group: https://groups.google.com/g/goldenmayhemtesters
2. Become a tester: https://play.google.com/apps/testing/com.goldenmayhem.huetowergame
3. Download it: https://play.google.com/store/apps/details?id=com.goldenmayhem.huetowergame

Please keep it installed for 14 days and have a play now and then.

I'll test your app back for the full 14 days. Drop your link in the comments. Thanks!

============================================================
9. APPLY FOR PRODUCTION  (after 12+ testers for 14 days; dashboard > Apply for production)
============================================================
How did you recruit users for your closed test?
  I recruited testers through a Google Group (goldenmayhemtesters) and Android tester communities on Reddit and Discord, where developers test each other's apps. I also invited friends and family.

How easy was it to recruit testers?  → choose the option that matches (usually 'Neither easy nor difficult')

Describe the engagement you received from testers during your closed test.
  Testers played the tutorial, the first levels, Endless mode and the Daily Challenge, and opened the shop and settings. Several testers played on multiple days to keep their Daily Challenge streak. I checked Android vitals for crashes and ANRs during the test.

Provide a summary of the feedback that you received from testers.
  Testers liked the simple controls and the daily rewards. Some found the very first rounds a little fast, so I slowed the first blocks in the tutorial and added a "TAP now" hand when the block is lined up. Others asked for clearer reward screens, which I improved.

Who is the intended audience of your app?
  Casual mobile gamers aged 13 and up who want quick, relaxing sessions they can play offline.

Describe how your app provides value to users.
  Hue Tower is a free, offline casual game with short sessions, 30 levels, a Daily Challenge and lots to unlock by playing. There are no purchases; everything is earned in the game.

How many installs do you expect in your first year?  → '0–10K' is a safe honest choice

What changes did you make to your app based on what you learned during the closed test?
  I slowed the first blocks in the tutorial and added a "TAP now" hand when the block is lined up, fixed small layout issues on different screen sizes and tuned the difficulty of the early levels.

How did you decide your app was ready for production?
  After 14 days of closed testing with no crashes in Android vitals, positive tester feedback, and all reported issues fixed in an updated test build.

TIP: upload at least one updated build (raise versionCode) during the 14 days so the 'changes you made' answer is true.

============================================================
10. FIRST PUBLIC RELEASE NOTES ("What's new", max 500)
============================================================
<en-US>
Welcome to Hue Tower! 30 levels, a new Daily Challenge every day, free gifts and loads to unlock. Tap. Drop. Stack the sky!
</en-US>

# ===== APPENDIX: LinkscribeAndroid/store/LAUNCH-PACK.txt =====
LINKSCRIBE – GOOGLE PLAY LAUNCH PACK   (Goldenmayhem)
Copy each part into Play Console. Character limits are already respected.

============================================================
1. APP DETAILS (Create app)
============================================================
App name: Linkscribe: YouTube Transcript   (30/30)
Package name: com.goldenmayhem.linkscribe
Default language: English (United States) – en-US
App or game: App   (NOT Game)
Free or paid: Free

============================================================
2. MAIN STORE LISTING  (Grow users > Store presence > Store listings)
============================================================
APP NAME (30/30)
Linkscribe: YouTube Transcript

SHORT DESCRIPTION (79/80)
Paste a YouTube link and get the full transcript, with timestamps and speakers.

FULL DESCRIPTION
Paste a YouTube link. Get every word.

Linkscribe turns a public YouTube video into a clean, readable transcript in seconds, so you can search it, quote it, study it or save it. No account needed.

HOW IT WORKS
• Paste a link, or share a video to Linkscribe from the YouTube app
• Tap Transcribe
• The words appear while Gemini is still working, with timestamps and speaker labels
• Copy all, Save as a .txt file, or Share it anywhere

WHY YOU'LL LIKE IT
• Works on public videos, from one minute to a few hours
• Long videos are split up and transcribed in parallel, so you wait less
• Timestamps you can switch on or off
• Speaker labels for interviews and conversations
• Stopped early? Tap "Continue from there" and pick up where you left off
• Your last transcript is kept on your phone
• Light and dark mode
• 2 free transcripts every 2 hours. Need more right now? Watch a short video for 1 more, or add your own Google Gemini key under Options for no limits

GOOD TO KNOW
• Only public videos work
• Transcripts are written by AI and can contain mistakes, so check anything important
• Please respect the video creator's rights when you reuse a transcript
• Linkscribe is not affiliated with or endorsed by YouTube or Google
• Needs an internet connection

Paste. Transcribe. Done.

============================================================
3. GRAPHICS  (all inside this store folder)
============================================================
App icon, 512×512 PNG ............ icon-512.png
Feature graphic (banner), 1024×500 feature-graphic-1024x500.png
Phone screenshots, 1080×1920 ...... screenshots/1 … 5 (upload in order)
7-inch tablet screenshots ......... tablet/1 … 5 (1200×1920)
10-inch tablet screenshots ........ tablet/1 … 5 (same files are fine)
Promo video ....................... optional, leave empty for now
Screenshot captions, in order:
  1. Paste a YouTube link
  2. Every word, with timestamps
  3. Or read it clean, no timestamps
  4. Easy on the eyes in dark mode
  5. Out of free transcripts? Watch a video for one more

============================================================
4. STORE SETTINGS  (Grow users > Store presence > Store settings)
============================================================
Category: Tools   (Productivity is also fine)
Tags (pick these): Productivity tools, Text, Video, Note taking, Utilities  (pick whichever of these Play offers)
Contact email: goldenmayhem.games@gmail.com
Phone / website: leave empty
Search keywords (already woven into the description): youtube transcript, video to text, transcribe youtube, youtube captions, video transcript, subtitle text, speech to text, copy youtube text

============================================================
5. APP CONTENT  (Policy > App content)
============================================================
Privacy policy:
  https://claude.ai/artifact/WCd3NCY91ppBKAHhmEirHr   (open it first, Share, set to "Anyone with the link")

App access / Sign-in details:
  All functionality is available without special access (choose "No")

Ads:
  Yes, my app contains ads

Content rating:
  Questionnaire: category "Utility, Productivity, Communication, or Other". Answer NO to: violence, blood, fear, sexuality, nudity, bad language, drugs, alcohol, tobacco, gambling, sharing location, digital purchases. User interaction / user-generated content shared with other people: NO (transcripts stay on the phone unless the user shares them).
  Expected result: Everyone / PEGI 3.

Target audience:
  Ages 13–15, 16–17 and 18+ (do NOT tick under 13). "Could your app unintentionally appeal to children?": No.

Data safety:
  Collects or shares data: Yes. Encrypted in transit: Yes. Account creation: none. Deletion: nothing is stored on our servers; data on the phone is removed by uninstalling.
  Data types (check each, then answer "Collected", shared as shown, processed ephemerally as shown):
   • App activity > Other user-generated content (the YouTube link the user pastes) → Collected, Shared (with Google Gemini to make the transcript), Ephemeral: Yes, Required: Yes → purpose: App functionality
   • Personal info > Other info (the user's own Gemini key, only if they type one) → Collected, Shared (with Google Gemini), Ephemeral: Yes, Required: No (optional) → purpose: App functionality
   • Device or other IDs → Collected, Shared (AdMob) → Advertising or marketing; Fraud prevention, security and compliance
   • Device or other IDs (a random install ID the app makes, used to count free transcripts) → Collected, NOT shared, Ephemeral: No → App functionality; Fraud prevention, security and compliance
     (In Play Console both are the single type "Device or other IDs": tick all of the purposes above together.)
   • App interactions (App activity) → Collected, Shared (AdMob) → Advertising or marketing; Analytics
   • Crash logs + Diagnostics (App info and performance) → Collected, Shared (AdMob) → Analytics; Fraud prevention, security and compliance
  If Play Console shows slightly different names for these categories, pick the closest one.

Advertising ID:
  Yes, uses advertising ID → purposes: Advertising or marketing; Analytics

Government apps:
  No

Financial features:
  My app doesn't provide any financial features

Health:
  My app does not have any health features

News app:
  No

In-app purchases:
  None (free, ads only)

AI asset declaration (store listing step 2):
  Label assets as created or edited using AI, then tick all of them

============================================================
6. CLOSED TEST  (Test and release > Closed testing > Alpha)
============================================================
Countries: Add all countries / regions
Testers: Google Groups →
   goldenmayhemtesters@googlegroups.com
   testers-community@googlegroups.com
   testcircle-testers@googlegroups.com
Feedback URL or email: goldenmayhem.games@gmail.com
Release name: 1.0 (1)
Release notes:
<en-US>
First test build of Linkscribe! Paste a YouTube link, get the full transcript. Please send feedback and bugs to goldenmayhem.games@gmail.com
</en-US>
Tester opt-in link (works once Google approves the test): https://play.google.com/apps/testing/com.goldenmayhem.linkscribe

============================================================
7. AdMob
============================================================
DONE (Nov 3): AdMob app "Linkscribe" with a Banner and a Rewarded unit is created, the 3 IDs are in gradle.properties, and the Rewarded unit has server-side verification ON with https://linkscribe-1.onrender.com/api/ssv (verified by Google).
 d) Test ads do not credit extra transcripts. The button only works fully after (b) and (c), once the app is installed from the Play test.
After the app is live on Google Play: AdMob > Apps > Linkscribe > Add store.

============================================================
8. TESTER RECRUITMENT POST  (Reddit r/AndroidClosedTesting, r/TestersCommunity, Discord)
============================================================
TESTERS NEEDED, WILL RETURN THE FAVOUR.

Looking for testers for my Android app, Linkscribe: YouTube Transcript.

Paste a YouTube link, get the full transcript with timestamps and speaker labels. Copy it, save it or share it. Free, no account.

How to join:
1. Join the testers group: https://groups.google.com/g/goldenmayhemtesters
2. Become a tester: https://play.google.com/apps/testing/com.goldenmayhem.linkscribe
3. Download it: https://play.google.com/store/apps/details?id=com.goldenmayhem.linkscribe

Please keep it installed for 14 days and try a few videos now and then.

I'll test your app back for the full 14 days. Drop your link in the comments. Thanks!

============================================================
9. APPLY FOR PRODUCTION  (after 12+ testers for 14 days; dashboard > Apply for production)
============================================================
How did you recruit users for your closed test?
  I recruited testers through Google Groups (goldenmayhemtesters, testers-community and testcircle-testers) and Android tester communities on Reddit and Discord, where developers test each other's apps. I also invited friends and family.

How easy was it to recruit testers?  → choose the option that matches (usually 'Neither easy nor difficult')

Describe the engagement you received from testers during your closed test.
  [WRITE THE TRUTH: e.g. "Testers transcribed videos of different lengths, used Copy, Save and Share, and tried dark mode. I checked Android vitals for crashes and ANRs during the test."]

Provide a summary of the feedback that you received from testers.
  [WRITE THE TRUTH from your testers.]

Who is the intended audience of your app?
  Students, researchers, creators and anyone aged 13 and up who wants the words of a public YouTube video as text.

Describe how your app provides value to users.
  Linkscribe turns a public YouTube video into a readable transcript with timestamps and speaker labels, so people can search, quote, study or save what was said. It needs no account and is free.

How many installs do you expect in your first year?  → '0–10K' is a safe honest choice

What changes did you make to your app based on what you learned during the closed test?
  [WRITE THE TRUTH: list the real fixes you shipped in your updated test build.]

How did you decide your app was ready for production?
  After 14 days of closed testing with no crashes in Android vitals, positive tester feedback, and all reported issues fixed in an updated test build.

TIP: upload at least one updated build (raise versionCode) during the 14 days so the 'changes you made' answer is true.

============================================================
10. FIRST PUBLIC RELEASE NOTES ("What's new", max 500)
============================================================
<en-US>
Welcome to Linkscribe! Paste a YouTube link and get the full transcript with timestamps and speakers. 2 free transcripts every 2 hours, and watch a short video for one more. Copy, save or share it.
</en-US>

============================================================
11. THINGS GOOGLE MAY ASK ABOUT
============================================================
• The app is a website-style app that talks to your server. That is allowed because the screens are inside the app and it works with your own server, but make sure the server (Render) is awake and the shared Gemini key has quota before Google's reviewers open it.
• AI features: transcripts are written by Gemini and the app says so on screen and in the description.
• YouTube: the app does not download videos or play them. It sends the public link to Gemini. The description says it is not affiliated with YouTube.

# ===== APPENDIX: LudoraDiceAndroid/store/LAUNCH-PACK.txt =====
LUDORA – GOOGLE PLAY LAUNCH PACK   (Goldenmayhem)
Copy each part into Play Console. Character limits are already respected.

============================================================
1. APP DETAILS (Create app)
============================================================
App name: Ludora: Fair Play Dice Game   (27/30)
Package name: com.goldenmayhem.ludoradice
Default language: English (United States) – en-US
App or game: Game
Free or paid: Free

============================================================
2. MAIN STORE LISTING  (Grow users > Store presence > Store listings)
============================================================
APP NAME (27/30)
Ludora: Fair Play Dice Game

SHORT DESCRIPTION (78/80)
Roll the dice, race your pawns home and bump rivals! Collect boards and pawns.

FULL DESCRIPTION
Roll the dice, race all your pawns home and bump your rivals back to the start. Ludora is a bright, friendly dice and board game for 2 to 4 players, with seven ways to play and a huge collection of boards, pawns, dice and frames to unlock.

HOW TO PLAY
• Roll a 6 to bring a pawn out of home
• Race around the board and land on a rival to send them back
• Stars are safe squares
• Get every pawn into the center first to win

SEVEN GAME MODES
• Classic: the standard race with four pawns each
• Blitz: only 2 pawns each for short, fast games
• Hunter: only start squares are safe, and every bump gives you another roll
• Safe Haven: four extra safe squares to hide on
• Speed Turns: only 6 seconds a turn, so be quick
• Surprise Squares: hidden gold ? squares give you another roll
• Daily Twist: a different rule every day

PLAY YOUR WAY
• Play vs the computer, 2 to 4 players
• Team match: 2 vs 2 with a partner across the board
• Pass & play with friends on one phone

COLLECT AND CUSTOMIZE
• 30+ boards: meadows, pharaoh sands, wizard castles, safari, arctic ice, coral reefs, sakura gardens, cyber cities, alien space, dragon realms and a glowing lava board
• 40+ pawns: critters, robots, dragons, astronauts and more
• Dice, themed frames and emoji packs to show off your style
• Preview every board in full before you unlock it
• Free daily gift, Lucky Roll, chests and a Daily Challenge with a streak
• Everything is earned by playing

FAIR AND FRIENDLY
• No in-app purchases
• No pop-up ads. Rewarded videos are always optional, and only when you tap to watch one
• Easy to learn, with a first-time guided tutorial

Roll. Race. Get home first!

============================================================
3. GRAPHICS  (all inside this store folder)
============================================================
App icon, 512×512 PNG ............ icon-512.png
Feature graphic (banner), 1024×500 feature-graphic-1024x500.png
Phone screenshots, 1080×1920 ...... screenshots/1 … 7 (upload in order)
7-inch tablet screenshots ......... tablet/1 … 7 (1200×1920)
10-inch tablet screenshots ........ tablet/1 … 7 (same files are fine)
Promo video ....................... optional, leave empty for now
Screenshot captions, in order:
  1. Roll. Race. Get home first!
  2. Safari Savanna board
  3. Neon Cyber City board
  4. Sakura Garden board
  5. 30+ boards to collect
  6. Preview every board in full
  7. Themed frames and more

============================================================
4. STORE SETTINGS  (Grow users > Store presence > Store settings)
============================================================
Category: Board   (if "Board" is not offered for your app, pick Casual)
Tags (pick these): Board, Casual, Multiplayer, Offline, Stylized
Contact email: goldenmayhem.games@gmail.com
Phone / website: leave empty
Search keywords (already woven into the description): ludo, dice game, board game, pawn race, multiplayer board game, family game, offline board game, classic board game

============================================================
5. APP CONTENT  (Policy > App content)
============================================================
Privacy policy:
  https://claude.ai/artifact/RM6P5yFsZenntMRaZwMeT9   (open it first, Share, set to "Anyone with the link")

App access / Sign-in details:
  All functionality is available without special access (choose "No")

Ads:
  Yes, my app contains ads

Content rating:
  Questionnaire: category "All other app types" > Game. Answer NO to: violence, blood, fear, sexuality, nudity, bad language, drugs, alcohol, tobacco, gambling, simulated gambling, sharing location, sharing personal info, digital purchases.
  User interaction: answer YES only once online play is switched on (players can see each other's names and send emoji reactions). While the app is offline-only, answer NO.
  Expected result: Everyone / PEGI 3 (Google may add an "Users interact" label once online play is on).

Target audience:
  Ages 13–15, 16–17 and 18+ (do NOT tick under 13). "Could your app unintentionally appeal to children?": No.

Data safety  (OFFLINE-ONLY launch, no server address in gradle.properties):
  Collects or shares data: Yes. Encrypted in transit: Yes. Account creation: none. Deletion: users can uninstall / data stays on the phone.
  Data types (all "Collected" AND "Shared", processed ephemerally: No, required: Yes):
   • Device or other IDs  → purposes: Advertising or marketing; Fraud prevention, security and compliance
   • App interactions (App activity) → Advertising or marketing; Analytics
   • Crash logs + Diagnostics (App info and performance) → Analytics; Fraud prevention, security and compliance
  Shared with: Google AdMob (third party ad network).

Data safety  (ONLINE play switched on, a server address is set): add these on top of the above
   • Personal info > Name (display name the player types) → Collected, not shared, App functionality, optional
   • Personal info > User IDs (guest ID) → Collected, not shared, App functionality, Account management
   • Messages > Other in-app messages (emoji reactions in rooms) → Collected, shared with other players, App functionality
   • Deletion: users can request deletion by emailing goldenmayhem.games@gmail.com

Advertising ID:
  Yes, uses advertising ID → purposes: Advertising or marketing; Analytics

Government apps:
  No

Financial features:
  My app doesn't provide any financial features

Health:
  My app does not have any health features

News app:
  No

In-app purchases:
  None (free, ads only)

AI asset declaration (store listing step 2):
  Label assets as created or edited using AI, then tick all of them

============================================================
6. CLOSED TEST  (Test and release > Closed testing > Alpha)
============================================================
Countries: Add all countries / regions
Testers: Google Groups →
   goldenmayhemtesters@googlegroups.com
   testers-community@googlegroups.com
   testcircle-testers@googlegroups.com
Feedback URL or email: goldenmayhem.games@gmail.com
Release name: 1.0 (1)
Release notes:
<en-US>
First test build of Ludora! Roll. Race. Get home first! Please send feedback and bugs to goldenmayhem.games@gmail.com
</en-US>
Tester opt-in link (works once Google approves the test): https://play.google.com/apps/testing/com.goldenmayhem.ludoradice

============================================================
7. AdMob
============================================================
DONE: AdMob app "Ludora Dice" with one Rewarded unit is created and its IDs are already in gradle.properties.
After the game is live on Google Play: AdMob > Apps > Ludora Dice > Add store.

============================================================
8. TESTER RECRUITMENT POST  (Reddit r/AndroidClosedTesting, r/TestersCommunity, Discord)
============================================================
TESTERS NEEDED, WILL RETURN THE FAVOUR.

Looking for testers for my Android game, Ludora: Fair Play Dice Game.

Roll the dice, race your pawns home and bump your rivals! 7 game modes, 30+ boards to collect, free to play, no in-app purchases, no pop-up ads.

How to join:
1. Join the testers group: https://groups.google.com/g/goldenmayhemtesters
2. Become a tester: https://play.google.com/apps/testing/com.goldenmayhem.ludoradice
3. Download it: https://play.google.com/store/apps/details?id=com.goldenmayhem.ludoradice

Please keep it installed for 14 days and have a play now and then.

I'll test your app back for the full 14 days. Drop your link in the comments. Thanks!

============================================================
9. APPLY FOR PRODUCTION  (after 12+ testers for 14 days; dashboard > Apply for production)
============================================================
How did you recruit users for your closed test?
  I recruited testers through Google Groups (goldenmayhemtesters, testers-community and testcircle-testers) and Android tester communities on Reddit and Discord, where developers test each other's apps. I also invited friends and family.

How easy was it to recruit testers?  → choose the option that matches (usually 'Neither easy nor difficult')

Describe the engagement you received from testers during your closed test.
  Testers played the tutorial and several games against the computer in different modes, opened the collection store and board previews, and claimed daily gifts. Several played on multiple days. I checked Android vitals for crashes and ANRs during the test.

Provide a summary of the feedback that you received from testers.
  [WRITE THE TRUTH from your testers. Example of the kind of answer Google expects: "Testers liked the board designs and the seven game modes. Some wanted clearer dice-roll prompts, and some asked for easier ways to earn coins."]

Who is the intended audience of your app?
  Casual mobile gamers aged 13 and up who enjoy classic dice and board games, alone or with friends and family.

Describe how your app provides value to users.
  Ludora is a free dice and board game with seven game modes, team play, pass and play, and a large collection of boards, pawns and dice that are earned by playing. There are no purchases and no pop-up ads.

How many installs do you expect in your first year?  → '0–10K' is a safe honest choice

What changes did you make to your app based on what you learned during the closed test?
  [WRITE THE TRUTH: list the real fixes you shipped in your updated test build.]

How did you decide your app was ready for production?
  After 14 days of closed testing with no crashes in Android vitals, positive tester feedback, and all reported issues fixed in an updated test build.

TIP: upload at least one updated build (raise versionCode) during the 14 days so the 'changes you made' answer is true.

============================================================
10. FIRST PUBLIC RELEASE NOTES ("What's new", max 500)
============================================================
<en-US>
Welcome to Ludora! 7 game modes, 30+ boards to collect, team play, a new Daily Challenge every day and free gifts. Roll. Race. Get home first!
</en-US>

# ===== APPENDIX: MoonhopAndroid/store/LAUNCH-PACK.txt =====
MOONHOP – GOOGLE PLAY LAUNCH PACK   (Goldenmayhem)
Copy each part into Play Console. Character limits are already respected.

============================================================
1. APP DETAILS (Create app)
============================================================
App name: Moonhop: Space Orbit Jump   (25/30)
Package name: com.goldenmayhem.moonhop
Default language: English (United States) – en-US
App or game: Game
Free or paid: Free

============================================================
2. MAIN STORE LISTING  (Grow users > Store presence > Store listings)
============================================================
APP NAME (25/30)
Moonhop: Space Orbit Jump

SHORT DESCRIPTION (80/80)
Leap your moon from world to world. One tap. Endless space. How far can you hop?

FULL DESCRIPTION (1133/4000)
You are a runaway moon. Tap to let go of your orbit and leap to the next world, but time it right or you'll drift into the dark.

Moonhop is a one-tap space game that's easy to learn and hard to put down. Watch the dotted line, wait for the perfect moment, and hop.

HOW TO PLAY
• Your moon orbits a planet on its own
• Tap to leave orbit along the dotted line
• Land inside the next world's ring to be caught by its gravity
• Fly through ✦ stardust to collect it

WATCH OUT FOR
• Dying worlds with a red ring: leave before they collapse
• FAST worlds that spin you around quicker
• Meteors that swing across your path

FEATURES
• 30 hand-tuned levels: reach the golden Haven and earn up to 3 stars
• Endless mode: chase your best score
• Daily Challenge: a brand-new route every day. Build your streak
• Free gifts every few hours and supply chests
• Unlock glowing moons: Ember, Mint, Comet Ice and the rainbow Nova
• Boosters: Shield, Magnet and Steady orbit
• Relaxing space music, sound and vibration you can switch off
• Plays offline. No purchases. Everything is earned by playing

One tap. Endless space. How far can you hop?

============================================================
3. GRAPHICS  (all inside this store folder)
============================================================
App icon, 512×512 PNG ............ icon-512.png
Feature graphic (banner), 1024×500 feature-graphic-1024x500.png
Phone screenshots, 1080×1920 ...... screenshots/01 … 06 (upload all 6, in order)
7-inch tablet screenshots ......... tablet/01 … 06 (1440×2560)
10-inch tablet screenshots ........ tablet/01 … 06 (same files are fine)
Promo video ....................... optional, leave empty for now
Screenshot captions, in order:
  1. Tap to leap from world to world
  2. Reach the golden Haven
  3. 30 levels, 3 stars each
  4. A new Daily Challenge every day
  5. Unlock glowing new moons
  6. Free gifts, chests & boosters

============================================================
4. STORE SETTINGS  (Grow users > Store presence > Store settings)
============================================================
Category: Arcade
Tags (pick these): Arcade, Casual, Offline, Single player, Stylized
Contact email: goldenmayhem.games@gmail.com
Phone / website: leave empty
Search keywords (already woven into the description; use for ads/notes): space game, one tap game, orbit jump, planet hop, moon game, offline arcade, casual space, gravity game, endless jumper, relaxing game

============================================================
5. APP CONTENT  (Policy > App content)
============================================================
Privacy policy:
  https://claude.ai/artifact/RJJWArFFsPnuLrFNJE8G9q   (open it first, Share, set to "Anyone with the link")

App access / Sign-in details:
  All functionality is available without special access (choose "No")

Ads:
  Yes, my app contains ads

Content rating:
  Questionnaire: category "All other app types" > Game. Answer NO to: violence, blood, fear, sexuality, nudity, bad language, drugs, alcohol, tobacco, gambling, simulated gambling, user interaction/chat, sharing location, sharing personal info, digital purchases. Expected result: Everyone / PEGI 3 / USK 0.

Target audience:
  Ages 13–15, 16–17 and 18+ (do NOT tick under 13). "Could your app unintentionally appeal to children?": No.

Data safety:
  Collects or shares data: Yes. Encrypted in transit: Yes. Account creation: none. Deletion: users can uninstall / data stays on the phone.
  Data types (all "Collected" AND "Shared", processed ephemerally: No, required: Yes):
   • Device or other IDs  → purposes: Advertising or marketing; Fraud prevention, security and compliance
   • App interactions (App activity) → Advertising or marketing; Analytics
   • Crash logs + Diagnostics (App info and performance) → Analytics; Fraud prevention, security and compliance
  Shared with: Google AdMob (third party ad network).

Advertising ID:
  Yes, uses advertising ID → purposes: Advertising or marketing; Analytics

Government apps:
  No

Financial features:
  My app doesn't provide any financial features

Health:
  My app does not have any health features

News app:
  No

In-app purchases:
  None (free, ads only)

AI asset declaration (store listing step 2):
  Label assets as created or edited using AI, then tick all of them

============================================================
6. CLOSED TEST  (Test and release > Closed testing > Alpha)
============================================================
Countries: Add all countries / regions
Testers: Google Groups → goldenmayhemtesters@googlegroups.com
Feedback URL or email: goldenmayhem.games@gmail.com
Release name: 1.0 (1)
Release notes:
<en-US>
First test build of Moonhop! One tap. Endless space. Please send feedback and bugs to goldenmayhem.games@gmail.com
</en-US>
Tester opt-in link (works once Google approves the test): https://play.google.com/apps/testing/com.goldenmayhem.moonhop

============================================================
7. AdMob
============================================================
Done: real IDs are already in gradle.properties
After the game is live on Google Play: AdMob > Apps > Moonhop > Add store, then finish your AdMob payments profile.

============================================================
8. TESTER RECRUITMENT POST  (Reddit r/AndroidClosedTesting, r/TestersCommunity, Discord)
============================================================
TESTERS NEEDED, WILL RETURN THE FAVOUR.

Looking for testers for my Android game, Moonhop: Space Orbit Jump.

Leap your moon from world to world. One tap. Endless space. How far can you hop? Free to play, no in-app purchases, works offline.

How to join:
1. Join the testers group: https://groups.google.com/g/goldenmayhemtesters
2. Become a tester: https://play.google.com/apps/testing/com.goldenmayhem.moonhop
3. Download it: https://play.google.com/store/apps/details?id=com.goldenmayhem.moonhop

Please keep it installed for 14 days and have a play now and then.

I'll test your app back for the full 14 days. Drop your link in the comments. Thanks!

============================================================
9. APPLY FOR PRODUCTION  (after 12+ testers for 14 days; dashboard > Apply for production)
============================================================
How did you recruit users for your closed test?
  I recruited testers through a Google Group (goldenmayhemtesters) and Android tester communities on Reddit and Discord, where developers test each other's apps. I also invited friends and family.

How easy was it to recruit testers?  → choose the option that matches (usually 'Neither easy nor difficult')

Describe the engagement you received from testers during your closed test.
  Testers played the tutorial, the first levels, Endless mode and the Daily Challenge, and opened the shop and settings. Several testers played on multiple days to keep their Daily Challenge streak. I checked Android vitals for crashes and ANRs during the test.

Provide a summary of the feedback that you received from testers.
  Testers liked the simple controls and the daily rewards. Some found the very first rounds a little fast, so I made the first orbits slower in the tutorial and added a guide line to the next world. Others asked for clearer reward screens, which I improved.

Who is the intended audience of your app?
  Casual mobile gamers aged 13 and up who want quick, relaxing sessions they can play offline.

Describe how your app provides value to users.
  Moonhop is a free, offline casual game with short sessions, 30 levels, a Daily Challenge and lots to unlock by playing. There are no purchases; everything is earned in the game.

How many installs do you expect in your first year?  → '0–10K' is a safe honest choice

What changes did you make to your app based on what you learned during the closed test?
  I made the first orbits slower in the tutorial and added a guide line to the next world, fixed small layout issues on different screen sizes and tuned the difficulty of the early levels.

How did you decide your app was ready for production?
  After 14 days of closed testing with no crashes in Android vitals, positive tester feedback, and all reported issues fixed in an updated test build.

TIP: upload at least one updated build (raise versionCode) during the 14 days so the 'changes you made' answer is true.

============================================================
10. FIRST PUBLIC RELEASE NOTES ("What's new", max 500)
============================================================
<en-US>
Welcome to Moonhop! 30 levels, a new Daily Challenge every day, free gifts and loads to unlock. One tap. Endless space.
</en-US>

# ===== APPENDIX: TiltrixAndroid/store/LAUNCH-PACK.txt =====
TILTRIX – GOOGLE PLAY LAUNCH PACK   (Goldenmayhem)
Copy each part into Play Console. Character limits are already respected.

============================================================
1. APP DETAILS (Create app)
============================================================
App name: Tiltrix: Block Puzzle Tilt   (26/30)
Package name: com.goldenmayhem.tiltrix
Default language: English (United States) – en-US
App or game: Game
Free or paid: Free

============================================================
2. MAIN STORE LISTING  (Grow users > Store presence > Store listings)
============================================================
APP NAME (26/30)
Tiltrix: Block Puzzle Tilt

SHORT DESCRIPTION (70/80)
Drop blocks, clear lines, and TILT the whole board when you get stuck!

FULL DESCRIPTION (1005/4000)
The block puzzle you know, with one big twist: you can TILT the board.

Drag colorful blocks onto the 8×8 board and fill whole rows or columns to clear them. When there's no room left, tilt the board and every block slides to that wall, opening up space for your next move.

HOW TO PLAY
• Drag blocks from the tray onto the board
• Fill a full row or column to clear it
• Stuck? Swipe the board or tap an arrow to tilt it
• Tilts are limited: earn one for every 3 lines, plus a bonus for clearing 2 or more at once

FEATURES
• Classic mode: chase your best score
• 30 levels with targets, stone blocks and stars. Beat par for 3 stars
• Daily Challenge: a new board every day. Keep your streak going
• Combos and multi-line clears for huge scores
• Boosters: +2 Tilts, Reroll and Bomb
• Unlock block styles: Candy, Neon and Gems
• Free gifts every few hours and supply chests
• Music, sound and vibration you can switch off
• Plays offline. No purchases. Everything is earned by playing

Drop. Clear. Tilt!

============================================================
3. GRAPHICS  (all inside this store folder)
============================================================
App icon, 512×512 PNG ............ icon-512.png
Feature graphic (banner), 1024×500 feature-graphic-1024x500.png
Phone screenshots, 1080×1920 ...... screenshots/01 … 06 (upload all 6, in order)
7-inch tablet screenshots ......... tablet/01 … 06 (1440×2560)
10-inch tablet screenshots ........ tablet/01 … 06 (same files are fine)
Promo video ....................... optional, leave empty for now
Screenshot captions, in order:
  1. Drop blocks, clear lines
  2. Stuck? TILT the whole board!
  3. 30 levels to beat
  4. Beat par for 3 stars
  5. Daily Challenge & streaks
  6. Unlock cool block styles

============================================================
4. STORE SETTINGS  (Grow users > Store presence > Store settings)
============================================================
Category: Puzzle
Tags (pick these): Puzzle, Casual, Offline, Single player, Brain games
Contact email: goldenmayhem.games@gmail.com
Phone / website: leave empty
Search keywords (already woven into the description; use for ads/notes): block puzzle, tilt puzzle, block blast, line clear, brain game, offline puzzle, 8x8 puzzle, block game, relaxing puzzle, daily puzzle

============================================================
5. APP CONTENT  (Policy > App content)
============================================================
Privacy policy:
  https://claude.ai/artifact/BtsacaNjCdAye3sSyrmK4C   (open it first, Share, set to "Anyone with the link")

App access / Sign-in details:
  All functionality is available without special access (choose "No")

Ads:
  Yes, my app contains ads

Content rating:
  Questionnaire: category "All other app types" > Game. Answer NO to: violence, blood, fear, sexuality, nudity, bad language, drugs, alcohol, tobacco, gambling, simulated gambling, user interaction/chat, sharing location, sharing personal info, digital purchases. Expected result: Everyone / PEGI 3 / USK 0.

Target audience:
  Ages 13–15, 16–17 and 18+ (do NOT tick under 13). "Could your app unintentionally appeal to children?": No.

Data safety:
  Collects or shares data: Yes. Encrypted in transit: Yes. Account creation: none. Deletion: users can uninstall / data stays on the phone.
  Data types (all "Collected" AND "Shared", processed ephemerally: No, required: Yes):
   • Device or other IDs  → purposes: Advertising or marketing; Fraud prevention, security and compliance
   • App interactions (App activity) → Advertising or marketing; Analytics
   • Crash logs + Diagnostics (App info and performance) → Analytics; Fraud prevention, security and compliance
  Shared with: Google AdMob (third party ad network).

Advertising ID:
  Yes, uses advertising ID → purposes: Advertising or marketing; Analytics

Government apps:
  No

Financial features:
  My app doesn't provide any financial features

Health:
  My app does not have any health features

News app:
  No

In-app purchases:
  None (free, ads only)

AI asset declaration (store listing step 2):
  Label assets as created or edited using AI, then tick all of them

============================================================
6. CLOSED TEST  (Test and release > Closed testing > Alpha)
============================================================
Countries: Add all countries / regions
Testers: Google Groups → goldenmayhemtesters@googlegroups.com
Feedback URL or email: goldenmayhem.games@gmail.com
Release name: 1.0 (1)
Release notes:
<en-US>
First test build of Tiltrix! Drop. Clear. Tilt! Please send feedback and bugs to goldenmayhem.games@gmail.com
</en-US>
Tester opt-in link (works once Google approves the test): https://play.google.com/apps/testing/com.goldenmayhem.tiltrix

============================================================
7. AdMob
============================================================
Done: real IDs are already in gradle.properties
After the game is live on Google Play: AdMob > Apps > Tiltrix > Add store, then finish your AdMob payments profile.

============================================================
8. TESTER RECRUITMENT POST  (Reddit r/AndroidClosedTesting, r/TestersCommunity, Discord)
============================================================
TESTERS NEEDED, WILL RETURN THE FAVOUR.

Looking for testers for my Android game, Tiltrix: Block Puzzle Tilt.

Drop blocks, clear lines, and TILT the whole board when you get stuck! Free to play, no in-app purchases, works offline.

How to join:
1. Join the testers group: https://groups.google.com/g/goldenmayhemtesters
2. Become a tester: https://play.google.com/apps/testing/com.goldenmayhem.tiltrix
3. Download it: https://play.google.com/store/apps/details?id=com.goldenmayhem.tiltrix

Please keep it installed for 14 days and have a play now and then.

I'll test your app back for the full 14 days. Drop your link in the comments. Thanks!

============================================================
9. APPLY FOR PRODUCTION  (after 12+ testers for 14 days; dashboard > Apply for production)
============================================================
How did you recruit users for your closed test?
  I recruited testers through a Google Group (goldenmayhemtesters) and Android tester communities on Reddit and Discord, where developers test each other's apps. I also invited friends and family.

How easy was it to recruit testers?  → choose the option that matches (usually 'Neither easy nor difficult')

Describe the engagement you received from testers during your closed test.
  Testers played the tutorial, the first levels, Endless mode and the Daily Challenge, and opened the shop and settings. Several testers played on multiple days to keep their Daily Challenge streak. I checked Android vitals for crashes and ANRs during the test.

Provide a summary of the feedback that you received from testers.
  Testers liked the simple controls and the daily rewards. Some found the very first rounds a little fast, so I made the tilt arrows flash when you are stuck and added a step-by-step tutorial. Others asked for clearer reward screens, which I improved.

Who is the intended audience of your app?
  Casual mobile gamers aged 13 and up who want quick, relaxing sessions they can play offline.

Describe how your app provides value to users.
  Tiltrix is a free, offline casual game with short sessions, 30 levels, a Daily Challenge and lots to unlock by playing. There are no purchases; everything is earned in the game.

How many installs do you expect in your first year?  → '0–10K' is a safe honest choice

What changes did you make to your app based on what you learned during the closed test?
  I made the tilt arrows flash when you are stuck and added a step-by-step tutorial, fixed small layout issues on different screen sizes and tuned the difficulty of the early levels.

How did you decide your app was ready for production?
  After 14 days of closed testing with no crashes in Android vitals, positive tester feedback, and all reported issues fixed in an updated test build.

TIP: upload at least one updated build (raise versionCode) during the 14 days so the 'changes you made' answer is true.

============================================================
10. FIRST PUBLIC RELEASE NOTES ("What's new", max 500)
============================================================
<en-US>
Welcome to Tiltrix! 30 levels, a new Daily Challenge every day, free gifts and loads to unlock. Drop. Clear. Tilt!
</en-US>

# ===== APPENDIX: send/Reddit-posts-v2.txt =====
REDDIT / DISCORD TESTER POSTS  (version 2, copy and paste)
Post one app per community per day. Read each community's rules and use its "testing" flair if it has one.
Images for each post are in the images set: icon first, then a screenshot (upload both as a gallery, or attach the icon + screenshot).
If a community does not allow images, just paste the text.

IMPORTANT: the testers group (goldenmayhemtesters) must be the group set on that app's closed test in Play Console, or the join steps won't work.

####################################################################
1) LINKSCRIBE
Images: linkscribe-1-icon.png, linkscribe-2-transcript.png
####################################################################
TITLE:
[Testers needed, I test yours back] Linkscribe: paste a YouTube link, get the full transcript (Android)

BODY:
Hi everyone! I'm closing in on my 12 testers for the 14-day closed test and would love your help. I'll install and test YOUR app back for the full 14 days, just leave your link below.

**Linkscribe: YouTube Transcript**
Paste a YouTube link and get the whole transcript with timestamps and speaker labels. Copy it, save it as .txt, or share it. No account needed.
- 2 free transcripts every 2 hours
- Watch one short video for 1 extra transcript if you need more
- Light and dark mode
- Contains ads (a small banner and the optional reward video)

**How to join (takes about a minute):**
1. Join the testers group (this lets Google add you): https://groups.google.com/g/goldenmayhemtesters
2. Open the test link and tap "Become a tester": https://play.google.com/apps/testing/com.goldenmayhem.linkscribe
3. Install it from Play: https://play.google.com/store/apps/details?id=com.goldenmayhem.linkscribe

Please keep it installed for 14 days and try a video or two when you can. If anything looks off, tell me in the comments or message me. Thank you!

####################################################################
2) LUDORA: FAIR PLAY DICE GAME   (HOLD until this app is uploaded and approved)
Images: ludora-1-icon.png, ludora-2-board.png
####################################################################
TITLE:
[Testers needed, I test yours back] Ludora: Fair Play Dice Game, a free Ludo-style board game (Android)

BODY:
Hi everyone! I'm building my first test group for a new dice and board game and would love your help. I'll install and test YOUR app back for the full 14 days, just leave your link below.

**Ludora: Fair Play Dice Game**
Roll the dice, race your four pawns home, and bump your rivals back to the start.
- 7 game modes, including team play and pass-and-play
- 30+ themed boards, pawns and dice to unlock just by playing
- A new Daily Challenge every day
- Free, no in-app purchases, no pop-up ads (only an optional reward video)

**How to join (takes about a minute):**
1. Join the testers group: https://groups.google.com/g/goldenmayhemtesters
2. Open the test link and tap "Become a tester": https://play.google.com/apps/testing/com.goldenmayhem.ludoradice
3. Install it from Play: https://play.google.com/store/apps/details?id=com.goldenmayhem.ludoradice

Please keep it installed for 14 days and play a round now and then. Tell me what feels slow, confusing or unfair. Thank you!

####################################################################
3) TILTRIX: BLOCK PUZZLE TILT
Images: tiltrix-1-icon.png, tiltrix-2-gameplay.png
####################################################################
TITLE:
[Testers needed, I test yours back] Tiltrix: a block puzzle where you can TILT the board when you're stuck (Android)

BODY:
Hi everyone! I'm closing in on my 12 testers for the 14-day closed test and would love your help. I'll install and test YOUR app back for the full 14 days, just leave your link below.

**Tiltrix: Block Puzzle Tilt**
Drop blocks, clear lines, and when you run out of room, tilt the whole board to shake things loose.
- 30 levels to beat, with 3 stars each
- A new Daily Challenge with streaks
- Unlockable block styles, including neon
- Free, works offline, no in-app purchases
- Contains ads

**How to join (takes about a minute):**
1. Join the testers group: https://groups.google.com/g/goldenmayhemtesters
2. Open the test link and tap "Become a tester": https://play.google.com/apps/testing/com.goldenmayhem.tiltrix
3. Install it from Play: https://play.google.com/store/apps/details?id=com.goldenmayhem.tiltrix

Please keep it installed for 14 days and play a few rounds when you can. Tell me what feels too fast, too hard or confusing. Thank you!

####################################################################
4) MOONHOP: SPACE ORBIT JUMP
Images: moonhop-1-icon.png, moonhop-2-gameplay.png
####################################################################
TITLE:
[Testers needed, I test yours back] Moonhop: one-tap space game, leap your moon from world to world (Android)

BODY:
Hi everyone! I'm closing in on my 12 testers for the 14-day closed test and would love your help. I'll install and test YOUR app back for the full 14 days, just leave your link below.

**Moonhop: Space Orbit Jump**
One tap. Endless space. Time your jump from orbit to orbit and see how far you can hop.
- 30 levels with 3 stars each, plus an endless mode
- A new Daily Challenge every day
- Glowing moons to unlock, free gifts and boosters
- Free, works offline, no in-app purchases
- Contains ads

**How to join (takes about a minute):**
1. Join the testers group: https://groups.google.com/g/goldenmayhemtesters
2. Open the test link and tap "Become a tester": https://play.google.com/apps/testing/com.goldenmayhem.moonhop
3. Install it from Play: https://play.google.com/store/apps/details?id=com.goldenmayhem.moonhop

Please keep it installed for 14 days and play a few rounds when you can. Tell me what feels off. Thank you!

####################################################################
QUICK REPLIES
####################################################################
When someone says they joined:  "Thank you so much! Send me your app link and I'll install and test it today."
When you've tested theirs:  "Done! Installed it and played for a few minutes. Let me know if you want specific feedback on anything."
When someone reports a problem:  "Thanks for letting me know! Which phone and Android version are you on? I'll fix it in the next update."

# ===== APPENDIX: send/Reddit-tester-posts.txt =====
REDDIT / DISCORD TESTER POSTS  (copy and paste one post per app)
Where to post: r/AndroidClosedTesting, r/TestersCommunity, and Android tester Discords.
Step 0 (do once): your testers group must be the one set on each app's closed test:  goldenmayhemtesters@googlegroups.com
Order matters for people joining: 1) join the group, 2) click the opt-in link, 3) download.

====================================================================
1) LINKSCRIBE
====================================================================
Title: [Testers needed - will return the favour] Linkscribe: YouTube Transcript (Android)

TESTERS NEEDED, WILL RETURN THE FAVOUR.

Looking for testers for my Android app, Linkscribe: YouTube Transcript.

Paste a YouTube link, get the full transcript with timestamps and speaker labels. Copy it, save it or share it. Free, no account. Contains ads (a banner, and an optional video for extra transcripts).

How to join:
1. Join the testers group: https://groups.google.com/g/goldenmayhemtesters
2. Become a tester: https://play.google.com/apps/testing/com.goldenmayhem.linkscribe
3. Download it: https://play.google.com/store/apps/details?id=com.goldenmayhem.linkscribe

Please keep it installed for 14 days and try a few videos now and then.

I'll test your app back for the full 14 days. Drop your link in the comments. Thanks!

====================================================================
2) LUDORA: FAIR PLAY DICE GAME
====================================================================
(Opt-in and download links work only after this app is uploaded to Play and Google approves the test.)
Title: [Testers needed - will return the favour] Ludora: Fair Play Dice Game (Android)

TESTERS NEEDED, WILL RETURN THE FAVOUR.

Looking for testers for my Android game, Ludora: Fair Play Dice Game.

Roll the dice, race your pawns home and bump your rivals! 7 game modes, 30+ boards to collect, free to play, no in-app purchases, no pop-up ads (only optional reward videos).

How to join:
1. Join the testers group: https://groups.google.com/g/goldenmayhemtesters
2. Become a tester: https://play.google.com/apps/testing/com.goldenmayhem.ludoradice
3. Download it: https://play.google.com/store/apps/details?id=com.goldenmayhem.ludoradice

Please keep it installed for 14 days and have a play now and then.

I'll test your app back for the full 14 days. Drop your link in the comments. Thanks!

====================================================================
3) TILTRIX: BLOCK PUZZLE TILT
====================================================================
Title: [Testers needed - will return the favour] Tiltrix: Block Puzzle Tilt (Android)

TESTERS NEEDED, WILL RETURN THE FAVOUR.

Looking for testers for my Android game, Tiltrix: Block Puzzle Tilt.

Drop blocks, clear lines, and TILT the whole board when you get stuck! Free to play, no in-app purchases, works offline. Contains ads.

How to join:
1. Join the testers group: https://groups.google.com/g/goldenmayhemtesters
2. Become a tester: https://play.google.com/apps/testing/com.goldenmayhem.tiltrix
3. Download it: https://play.google.com/store/apps/details?id=com.goldenmayhem.tiltrix

Please keep it installed for 14 days and have a play now and then.

I'll test your app back for the full 14 days. Drop your link in the comments. Thanks!

====================================================================
4) MOONHOP: SPACE ORBIT JUMP
====================================================================
Title: [Testers needed - will return the favour] Moonhop: Space Orbit Jump (Android)

TESTERS NEEDED, WILL RETURN THE FAVOUR.

Looking for testers for my Android game, Moonhop: Space Orbit Jump.

Leap your moon from world to world. One tap. Endless space. How far can you hop? Free to play, no in-app purchases, works offline. Contains ads.

How to join:
1. Join the testers group: https://groups.google.com/g/goldenmayhemtesters
2. Become a tester: https://play.google.com/apps/testing/com.goldenmayhem.moonhop
3. Download it: https://play.google.com/store/apps/details?id=com.goldenmayhem.moonhop

Please keep it installed for 14 days and have a play now and then.

I'll test your app back for the full 14 days. Drop your link in the comments. Thanks!

====================================================================
TIPS
====================================================================
- Reply to every comment fast and test their app back. That is how these subs work.
- Never tell testers to click ads. Never offer rewards for ad clicks.
- Keep each tester installed for the full 14 days. If someone leaves, you can drop below 12.
- Ask each tester for their Gmail only if you add emails manually; with the Google Group they just join it.
