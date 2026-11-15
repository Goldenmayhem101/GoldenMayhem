# Knot Out – Android project

## Build it
1. Install **Android Studio** (free) on a Windows or Mac computer.
2. Unzip this folder, then in Android Studio choose **File > Open** and pick the `KnotOutAndroid` folder.
3. Let it finish "Gradle sync" (first time takes a few minutes; it downloads what it needs).
4. Plug in your Android phone with USB debugging on (or use an emulator) and press the green **Run** button.

## Before publishing on Google Play
1. **Your own package name.** In `app/build.gradle.kts`, change `applicationId = "com.knotout.game"` to something unique, e.g. `com.yourname.knotout`.
2. **AdMob is already set up.** Your Knot Out app ID and both ad units (Rewarded and Level Break interstitial) are in the project.
   - When you press Run in Android Studio you get a *debug* build that shows Google's "Test Ad" ads. That's on purpose: never click your own real ads, or AdMob can ban your account.
   - The *signed release* build you upload to Google Play uses your real ad units automatically (see `app/build.gradle.kts`).
   - Finish your AdMob payment setup, and after the game is live on Google Play, link it to the Knot Out app in AdMob (Apps > Knot Out > App settings > Add app store).
3. **Signed release.** Build > Generate Signed App Bundle / APK > Android App Bundle. Create a keystore and keep it safe forever: you need it for every update.
4. Upload the `.aab` file in the Google Play Console.

## Where things are
- The whole game: `app/src/main/assets/index.html`
- Ads + phone settings: `MainActivity.kt`
- App name: `app/src/main/res/values/strings.xml`
- Icon: `app/src/main/res/drawable/ic_launcher_foreground.xml`

The game loads its 3D engine from the internet the first time, so the phone needs a connection (ads need one anyway).

## Version 1.1 changes
- Targets Android 16 (API level 36), as Google Play requires.
- Android launch screen with the Knot Out icon, then the animated Goldenmayhem / Knot Out intro.
- First-time welcome with the privacy policy, a hand-guided tutorial, guide lines (Guide button), pinch-to-zoom hint and a first-win card.
- Security: the game is served from the app's own private https address with file access turned off, Safe Browsing on, no plain-http traffic, and only the game can run inside the app (other links open in the browser).
- Google's consent form (UMP) for ads, required in the EU/UK. Set up the message in AdMob > Privacy & messaging. Settings shows "Privacy choices" where required.
- Each new upload to Google Play needs a higher `versionCode` in `app/build.gradle.kts` (now 3).

## Version 1.2 changes
- Pinch-to-zoom removed; boards now max out at 12 x 18 so ropes stay easy to tap.
- Background music (Settings > Music), level replays (Home > Levels), Google Play rating card after levels 8, 20 and 45.
- Daily Challenge reminder notification around 6 pm (asked once, toggle in Settings > Daily reminder).
- Shop: 8 themes, 6 rope color sets and 5 rope finishes.

## Make the game work offline (do this once)
1. Open this link in your browser: https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js
2. Save the page (Ctrl+S) as **three.min.js** into the folder `app/src/main/assets/` (next to `index.html`).
3. Build again. The game now loads its 3D engine from inside the app. Without the file it still works, but needs internet on launch.
