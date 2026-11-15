# Breach Run – Android project (by Goldenmayhem)

Package name: **com.goldenmayhem.breachrun** · Targets **Android 16 (API 36)** · Version 1.1 (versionCode 2)

## 1. Open and test it
1. Unzip this folder somewhere easy, e.g. `Documents\BreachRunAndroid`.
2. In Android Studio: **File > Open** and pick the `BreachRunAndroid` folder. Wait for "Gradle sync" to finish.
3. Plug in your phone (USB debugging on) and press the green **Run** button.
   Debug builds always show Google's "Test Ad" ads. Never tap your own real ads.

## 2. AdMob (already done)
The Breach Run AdMob app and its two ad units (Rewarded + "Between Runs" interstitial) are created and their real IDs are in `gradle.properties`.
Debug builds still use Google's test ads automatically. Finish your AdMob **Payments** profile so you can get paid.

## 3. Make a NEW upload key and BACK IT UP
1. **Build > Generate Signed App Bundle / APK > Android App Bundle > Next**.
2. Under Key store path, click **Create new...** and save it as `Documents\breachrun-upload.jks`.
   Do **not** reuse or overwrite the Knot Out key file.
3. Pick a password, alias `upload`, fill in your name, **OK**, then choose **release** and **Create**.
4. **Back up `breachrun-upload.jks` right away** (Google Drive and a USB stick) together with its password.
   You need this exact file for every future update.
5. The bundle lands in `app\release\app-release.aab`.

## 4. Google Play Console
1. **Create app** > name "Breach Run" > Game > Free.
2. Upload `app-release.aab` to **Testing > Closed testing** and add your testers (the same Google Group as Knot Out works).
3. Privacy policy: use the Breach Run privacy policy page (make it public first: open it, Share, anyone with the link).
4. Store listing text, icon, feature graphic and 7 phone screenshots (`store/screenshots`) are in the `store` folder.
5. For every new upload, raise `versionCode` by 1 in `app/build.gradle.kts`.

## What's inside
- The whole game: `app/src/main/assets/index.html` (works offline)
- Ads, consent, rating card, reminder bridge and security settings: `MainActivity.kt`
- Daily Challenge reminder (about 6 pm, player can turn it on/off in Settings): `Reminder.kt`
- Icons: `res/mipmap-*` (launcher), `res/drawable-xxxhdpi` (adaptive icon + launch screen)

## Security built in
- Target API 36, no plain-http traffic, the game runs from the app's own private https address,
  file and content access turned off, Safe Browsing on, and any outside link opens in the browser instead of the app.
- Android back gesture: pauses a run, closes menus, and only leaves the app from the home screen.

## Version 1.1 changes
- New look based on the reference videos: hanging lamps with light beams, color-tinted rooms, clocks, frames, fans, racks, magnifier badges on searchable furniture, red "!" warnings for zombies coming from the dark.
- Zombie waves with a "Next wave of zombies" countdown, cash-locked floors, keys and locked doors, doors that repair while you stand next to them.
- Item descriptions on pickup, survivors who go ahead to the extraction point, an in-run backpack screen (with uncollected items and an ad to unlock slots), upgrade cards hidden in rooms.
- New holographic card picker, icon pause menu, chapter map and a results screen with damage stats.
