plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

// Real AdMob IDs and your server address live in gradle.properties
val admobAppId = (project.findProperty("admobAppId") as String?) ?: "ca-app-pub-3940256099942544~3347511713"
val realBanner = (project.findProperty("bannerUnit") as String?) ?: "ca-app-pub-3940256099942544/9214589741"
val realRewarded = (project.findProperty("rewardedUnit") as String?) ?: "ca-app-pub-3940256099942544/5224354917"
val serverUrl = (project.findProperty("serverUrl") as String?) ?: ""
val privacyUrl = (project.findProperty("privacyUrl") as String?) ?: ""

android {
    namespace = "com.goldenmayhem.linkscribe"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.goldenmayhem.linkscribe"   // the package name you type in Google Play Console
        minSdk = 26
        targetSdk = 36                                  // Android 16, required by Google Play
        versionCode = 2                                 // raise by 1 for every upload to Google Play
        versionName = "1.1"
        manifestPlaceholders["admobAppId"] = admobAppId
    }

    buildFeatures { buildConfig = true }

    buildTypes {
        // Debug builds (the green Run button) always use Google's TEST ads, so you never click your own real ads.
        debug {
            buildConfigField("String", "BANNER_UNIT", "\"ca-app-pub-3940256099942544/9214589741\"")
            buildConfigField("String", "REWARDED_UNIT", "\"ca-app-pub-3940256099942544/5224354917\"")
            buildConfigField("String", "SERVER_URL", "\"$serverUrl\"")
            buildConfigField("String", "PRIVACY_URL", "\"$privacyUrl\"")
        }
        // The signed release you upload to Google Play uses your real Linkscribe ad unit from gradle.properties.
        release {
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            buildConfigField("String", "BANNER_UNIT", "\"$realBanner\"")
            buildConfigField("String", "REWARDED_UNIT", "\"$realRewarded\"")
            buildConfigField("String", "SERVER_URL", "\"$serverUrl\"")
            buildConfigField("String", "PRIVACY_URL", "\"$privacyUrl\"")
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }
}

dependencies {
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("androidx.core:core-splashscreen:1.0.1")
    implementation("androidx.webkit:webkit:1.11.0")
    implementation("com.google.android.gms:play-services-ads:23.3.0")
    implementation("com.google.android.ump:user-messaging-platform:3.0.0")
}
