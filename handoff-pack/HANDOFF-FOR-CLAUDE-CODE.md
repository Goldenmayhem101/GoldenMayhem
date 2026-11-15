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
