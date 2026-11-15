plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.knotout.game"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.knotout.game"   // must match the package name in Google Play Console
        minSdk = 26
        targetSdk = 36                       // Android 16, required by Google Play
        versionCode = 6                      // raise by 1 for every upload to Google Play
        versionName = "1.2"
    }

    buildFeatures { buildConfig = true }

    buildTypes {
        // While testing on your phone (debug builds), Google's TEST ads are used so you never click your own real ads.
        debug {
            buildConfigField("String", "REWARDED_UNIT", "\"ca-app-pub-3940256099942544/5224354917\"")
            buildConfigField("String", "INTERSTITIAL_UNIT", "\"ca-app-pub-3940256099942544/1033173712\"")
        }
        // The release build you upload to Google Play uses your REAL Knot Out ad units.
        release {
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            buildConfigField("String", "REWARDED_UNIT", "\"ca-app-pub-3920854813859561/9676354003\"")
            buildConfigField("String", "INTERSTITIAL_UNIT", "\"ca-app-pub-3920854813859561/5996304303\"")
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
    implementation("com.google.android.play:review-ktx:2.0.2")   // Google Play in-app rating card
    implementation("androidx.work:work-runtime-ktx:2.9.1")       // daily reminder notification
}
