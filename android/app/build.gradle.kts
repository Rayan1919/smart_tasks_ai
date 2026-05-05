plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// Ù†Ø­Ø§ÙˆÙ„ Ù†Ù‚Ø±Ø£ Ø§Ù„Ù†Ø³Ø® Ù…Ù† Ø®ØµØ§Ø¦Øµ FlutterØŒ ÙˆÙ„Ùˆ Ù…Ø§ Ù„Ù‚ÙŠÙ†Ø§Ù‡Ø§ Ù†Ø­Ø· Ø§ÙØªØ±Ø§Ø¶ÙŠØ§Øª
val flutterVersionCode: Int = (
    (project.findProperty("flutterVersionCode") as String?)
        ?: (project.findProperty("flutter.versionCode") as String?)
        ?: "1"
).toInt()

val flutterVersionName: String = (
    (project.findProperty("flutterVersionName") as String?)
        ?: (project.findProperty("flutter.versionName") as String?)
        ?: "1.0"
)

android {
    // Ø·Ø§Ø¨Ù‚ Ù…Ø¹ Ù…Ø³Ø§Ø± MainActivity.kt
    namespace = "com.example.smart_app"

    // Ø«Ø¨Ù‘Øª Ø§Ù„Ù€ NDK Ø§Ù„Ù…ØªÙÙ‚ Ø¹Ù„ÙŠÙ‡
    ndkVersion = "27.0.12077973"

    // Ø£Ø±Ù‚Ø§Ù… Ø«Ø§Ø¨ØªØ© Ù„ØªÙØ§Ø¯ÙŠ Ù…Ø±Ø§Ø¬Ø¹ ØºÙŠØ± Ù…Ø¹Ø±Ù‘ÙØ©
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.smart_app"
        minSdk = 23
        targetSdk = 34

        versionCode = flutterVersionCode
        versionName = flutterVersionName

        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}



