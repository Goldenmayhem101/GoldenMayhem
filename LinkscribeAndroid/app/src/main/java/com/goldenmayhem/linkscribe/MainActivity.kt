package com.goldenmayhem.linkscribe

import android.annotation.SuppressLint
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.net.Uri
import android.os.Bundle
import android.os.SystemClock
import android.view.View
import android.view.ViewGroup
import android.webkit.JavascriptInterface
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.Toast
import androidx.activity.OnBackPressedCallback
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import androidx.webkit.WebViewAssetLoader
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.AdView
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.rewarded.RewardedAd
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback
import com.google.android.gms.ads.rewarded.ServerSideVerificationOptions
import com.google.android.ump.ConsentInformation
import com.google.android.ump.ConsentRequestParameters
import com.google.android.ump.UserMessagingPlatform
import java.util.concurrent.atomic.AtomicBoolean

class MainActivity : AppCompatActivity() {

    // The page is served from the app's own files under this private https address (no file:// access needed).
    private val appOrigin = "https://appassets.androidplatform.net"
    private val startUrl = "$appOrigin/assets/index.html"

    private lateinit var web: WebView
    private lateinit var adBox: FrameLayout
    private lateinit var consent: ConsentInformation
    private val adsStarted = AtomicBoolean(false)
    private var adView: AdView? = null
    private var rewarded: RewardedAd? = null
    private var pageReady = false
    private var sharedLink: String? = null
    private var pendingSave: String? = null
    private val launchedAt = SystemClock.uptimeMillis()

    // "Save .txt": the player picks where to save the transcript (no storage permission needed).
    private val saveFile = registerForActivityResult(ActivityResultContracts.CreateDocument("text/plain")) { uri ->
        val text = pendingSave; pendingSave = null
        if (uri != null && text != null) {
            try {
                contentResolver.openOutputStream(uri)?.use { it.write(text.toByteArray(Charsets.UTF_8)) }
                Toast.makeText(this, "Saved", Toast.LENGTH_SHORT).show()
            } catch (_: Exception) {
                Toast.makeText(this, "Could not save the file", Toast.LENGTH_SHORT).show()
            }
        }
    }

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        // Android launch screen with the Linkscribe icon; it stays up until the page has loaded (max ~3 s)
        val splash = installSplashScreen()
        super.onCreate(savedInstanceState)
        splash.setKeepOnScreenCondition { !pageReady && SystemClock.uptimeMillis() - launchedAt < 3000 }

        // draw behind the system bars, then pad the layout so nothing is hidden
        WindowCompat.setDecorFitsSystemWindows(window, false)
        val night = (resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES
        WindowInsetsControllerCompat(window, window.decorView).apply {
            isAppearanceLightStatusBars = !night
            isAppearanceLightNavigationBars = !night
        }

        val assets = WebViewAssetLoader.Builder()
            .addPathHandler("/assets/", WebViewAssetLoader.AssetsPathHandler(this))
            .build()

        web = WebView(this)
        web.settings.apply {
            javaScriptEnabled = true
            domStorageEnabled = true            // remembers your last transcript, theme and options
            allowFileAccess = false             // security: the page can't read files on the phone
            allowContentAccess = false
            setSupportMultipleWindows(false)
            setGeolocationEnabled(false)
            safeBrowsingEnabled = true
        }
        web.overScrollMode = View.OVER_SCROLL_NEVER
        web.webViewClient = object : WebViewClient() {
            override fun shouldInterceptRequest(view: WebView, request: WebResourceRequest): WebResourceResponse? =
                assets.shouldInterceptRequest(request.url)

            // Only the app's own page runs inside the app. Any other link opens in the browser.
            override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
                if (request.url.toString().startsWith(appOrigin)) return false
                try { startActivity(Intent(Intent.ACTION_VIEW, request.url)) } catch (_: Exception) {}
                return true
            }

            override fun onPageFinished(view: WebView, url: String) { pageReady = true; deliverSharedLink() }
        }
        web.addJavascriptInterface(AppBridge(), "AndroidApp")

        adBox = FrameLayout(this)
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            // the banner ad sits in a slim strip at the top; the app fills the rest
            addView(adBox, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
            addView(web, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f))
        }
        setContentView(root)
        ViewCompat.setOnApplyWindowInsetsListener(root) { v, insets ->
            val bars = insets.getInsets(WindowInsetsCompat.Type.systemBars() or WindowInsetsCompat.Type.ime())
            v.setPadding(bars.left, bars.top, bars.right, bars.bottom)
            WindowInsetsCompat.CONSUMED
        }

        sharedLink = linkFrom(intent)
        web.loadUrl(startUrl)

        // Back button: closes Options / stops a running transcript, and only leaves the app from the main screen
        onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                web.evaluateJavascript("(window.__back?window.__back():'home')") {
                    if (it.contains("home")) moveTaskToBack(true)
                }
            }
        })

        // Ask for ad consent where the law requires it (EU/UK etc.), then show the banner.
        consent = UserMessagingPlatform.getConsentInformation(this)
        consent.requestConsentInfoUpdate(this, ConsentRequestParameters.Builder().build(), {
            UserMessagingPlatform.loadAndShowConsentFormIfRequired(this) { startAdsIfAllowed() }
        }, { startAdsIfAllowed() })
        startAdsIfAllowed() // returning players who already answered can start right away
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        sharedLink = linkFrom(intent)
        if (pageReady) deliverSharedLink()
    }

    // A YouTube link shared from the YouTube app or any other app
    private fun linkFrom(i: Intent?): String? {
        if (i?.action != Intent.ACTION_SEND) return null
        val t = i.getStringExtra(Intent.EXTRA_TEXT) ?: return null
        return Regex("https?://\\S+").find(t)?.value
    }

    private fun deliverSharedLink() {
        val link = sharedLink ?: return
        sharedLink = null
        val safe = link.replace("\\", "").replace("'", "").replace("\n", "")
        web.evaluateJavascript("(function(){var u=document.getElementById('url');if(u){u.value='$safe';}})()", null)
    }

    private fun startAdsIfAllowed() {
        if (!consent.canRequestAds() || !adsStarted.compareAndSet(false, true)) return
        MobileAds.initialize(this) { runOnUiThread { showBanner(); loadRewarded() } }
    }

    private fun showBanner() {
        val widthDp = (resources.displayMetrics.widthPixels / resources.displayMetrics.density).toInt()
        val v = AdView(this)
        v.adUnitId = BuildConfig.BANNER_UNIT
        v.setAdSize(AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(this, widthDp))
        adBox.removeAllViews()
        adBox.addView(v)
        adView = v
        v.loadAd(AdRequest.Builder().build())
    }

    private fun loadRewarded() {
        RewardedAd.load(this, BuildConfig.REWARDED_UNIT, AdRequest.Builder().build(), object : RewardedAdLoadCallback() {
            override fun onAdLoaded(ad: RewardedAd) { rewarded = ad }
            override fun onAdFailedToLoad(error: LoadAdError) { rewarded = null }
        })
    }

    // a random id for this install; the server uses it to count free transcripts and to credit a watched video
    private fun deviceId(): String {
        val sp = getSharedPreferences("linkscribe", Context.MODE_PRIVATE)
        var id = sp.getString("did", null)
        if (id == null) { id = java.util.UUID.randomUUID().toString(); sp.edit().putString("did", id).apply() }
        return id
    }

    private fun rewardReply(ok: Boolean) {
        runOnUiThread { web.evaluateJavascript("window.__rewardResult && window.__rewardResult($ok)", null) }
    }

    inner class AppBridge {
        @JavascriptInterface
        fun deviceId(): String = this@MainActivity.deviceId()

        // "Watch a short video for more": Google tells the server the video was really watched (server-side verification)
        @JavascriptInterface
        fun showReward() {
            runOnUiThread {
                val ad = rewarded
                if (ad == null) {
                    if (adsStarted.get()) loadRewarded()
                    rewardReply(false); return@runOnUiThread
                }
                ad.setServerSideVerificationOptions(ServerSideVerificationOptions.Builder().setUserId(deviceId()).build())
                var earned = false
                ad.fullScreenContentCallback = object : FullScreenContentCallback() {
                    override fun onAdDismissedFullScreenContent() { rewarded = null; loadRewarded(); rewardReply(earned) }
                    override fun onAdFailedToShowFullScreenContent(e: com.google.android.gms.ads.AdError) { rewarded = null; loadRewarded(); rewardReply(false) }
                }
                ad.show(this@MainActivity) { earned = true }
            }
        }

        @JavascriptInterface
        fun serverUrl(): String = BuildConfig.SERVER_URL

        @JavascriptInterface
        fun privacyUrl(): String = BuildConfig.PRIVACY_URL

        @JavascriptInterface
        fun copyText(text: String) {
            runOnUiThread {
                val cm = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                cm.setPrimaryClip(ClipData.newPlainText("Transcript", text))
            }
        }

        @JavascriptInterface
        fun pasteText(): String {
            val cm = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            return try { cm.primaryClip?.getItemAt(0)?.coerceToText(this@MainActivity)?.toString() ?: "" } catch (_: Exception) { "" }
        }

        @JavascriptInterface
        fun shareText(text: String) {
            runOnUiThread {
                val send = Intent(Intent.ACTION_SEND).apply { type = "text/plain"; putExtra(Intent.EXTRA_TEXT, text) }
                try { startActivity(Intent.createChooser(send, "Share transcript")) } catch (_: Exception) {}
            }
        }

        @JavascriptInterface
        fun saveText(name: String, text: String) {
            runOnUiThread {
                pendingSave = text
                try { saveFile.launch(name) } catch (_: Exception) { pendingSave = null }
            }
        }

        // "Ad privacy options" appears only where the law requires it
        @JavascriptInterface
        fun privacyOptionsRequired(): Boolean =
            consent.privacyOptionsRequirementStatus == ConsentInformation.PrivacyOptionsRequirementStatus.REQUIRED

        @JavascriptInterface
        fun showPrivacyOptions() {
            runOnUiThread { UserMessagingPlatform.showPrivacyOptionsForm(this@MainActivity) { startAdsIfAllowed() } }
        }

        // Settings link: "Privacy policy" opens in the phone's browser
        @JavascriptInterface
        fun openUrl(url: String) {
            if (!url.startsWith("https://")) return
            runOnUiThread { try { startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url))) } catch (_: Exception) {} }
        }
    }

    override fun onPause() { adView?.pause(); super.onPause(); web.onPause() }
    override fun onResume() { super.onResume(); web.onResume(); adView?.resume() }
    override fun onDestroy() { adView?.destroy(); super.onDestroy() }
}
