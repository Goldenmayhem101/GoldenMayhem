# Linkscribe – Android project (by Goldenmayhem)

Package name: **com.goldenmayhem.linkscribe** · Targets **Android 16 (API 36)** · Version 1.0 (versionCode 1)

The app shows the Linkscribe screens from inside the app and sends each transcript request to **your Linkscribe website on Render**. So the website must be running.

## 0. Before anything else (2 small jobs)
1. **Update your website once.** Open the folder `server-update` and follow `READ-ME-FIRST.txt` (replace server.js on GitHub; takes 2 minutes). Without it the app is blocked from your server.
2. **Put your website address in `gradle.properties`.** Replace `https://CHANGE-ME.onrender.com` on the `serverUrl=` line with your real address (https://..., no slash at the end).

## 1. Open it
1. Unzip this folder somewhere easy, e.g. `C:\Goldenmayhem\LinkscribeAndroid`.
2. Android Studio: **File > Open**, pick the `LinkscribeAndroid` folder, **Trust**.
3. If it asks "Please Select Gradle JVM", click **Use JVM 21**. Wait for Gradle sync to finish.
4. Optional test: plug in your phone (USB debugging on) and press the green **Run** button. Debug builds always show Google's test ads.

## 2. AdMob IDs (still to do)
In AdMob create an app called "Linkscribe" (Android, not listed yet) with ONE **Banner** and ONE **Rewarded** ad unit.
Open `gradle.properties`, remove the `#` in front of the three AdMob lines and paste the app ID, banner unit ID and rewarded unit ID.
Until you do, every build uses Google's test ads. Never tap your own real ads.
Then open the **Rewarded** unit in AdMob > **Server-side verification**, turn it on, and enter: `https://linkscribe-1.onrender.com/api/ssv`
(that is how Google tells your server a video was really watched, which gives the person 1 more transcript).

## 3. Make a NEW upload key and BACK IT UP
1. **Build > Generate Signed App Bundle or APK > Android App Bundle > Next**.
2. Key store path: **Create new...** and save it as `C:\Goldenmayhem\linkscribe-upload.jks`. Do not reuse another app's key.
3. Your own password, alias `upload`, your name, **OK**, then **release > Create**.
4. **Back up the .jks file and its password right away** (Google Drive + USB stick).
5. The bundle lands in `app\release\app-release.aab`.

## 4. Google Play Console
Everything for Google Play is in `store/LAUNCH-PACK.txt`: listing text, store settings, every App content answer, closed test setup,
a tester recruitment post and draft answers for the production application. The `store` folder also has the icon, the feature graphic,
5 phone screenshots and 5 tablet screenshots, and `privacy.html` (already published at the link in the pack).
For every later update, raise `versionCode` by 1 in `app/build.gradle.kts`.

## How the limit works
Each phone gets 2 free transcripts every 2 hours, counted by a random ID the app makes for each install (plus a safety cap per network address, so one person can't simply make many installs).
Watching a rewarded video adds 1 more, confirmed by Google AdMob straight to your server. People with their own Gemini key under Options have no limit.
You can change the numbers in Render > Environment: `RATE_LIMIT_COUNT` (default 2), `RATE_LIMIT_HOURS` (default 2), `REWARD_CREDITS` (default 1), `RATE_LIMIT_PER_IP` (default 12).
The counters live in the server's memory, so they reset if Render restarts the server. Nobody loses anything important, but it is a small way to get extra transcripts. No limit system on a free server is perfect.

## Keep your Gemini allowance in mind
A free Gemini key only covers a limited amount of video per day for everyone together. If the app gets popular, add billing to your key in Google AI Studio, or lower `RATE_LIMIT_PER_HOUR` in Render. Visitors can also type their own key under Options.

## What's inside
- The app screens: `app/src/main/assets/index.html` (works with the server, fonts built in)
- Banner ad strip at the top, rewarded video button, Google consent form + "Ad privacy options", Copy / Save .txt / Share / Paste, share-a-YouTube-link-into-the-app, back button, splash screen: `MainActivity.kt`

## Security built in
Target API 36, no plain-http traffic, the page runs from the app's own private https address, file and content access off,
Safe Browsing on, outside links open in the browser.
