package com.appstarterkit.app.app

import android.app.Application
import dagger.hilt.android.HiltAndroidApp

@HiltAndroidApp
class AppStarterKit : Application() {

    override fun onCreate() {
        super.onCreate()

        // MARK: Firebase / Crashlytics
        // TODO: Add google-services.json (downloaded from Firebase Console → Project settings →
        //       Your apps → Android app → google-services.json) to android/app/google-services.json,
        //       then apply the plugins in android/build.gradle.kts:
        //         id("com.google.gms.google-services") version "4.4.0" apply false
        //         id("com.google.firebase.crashlytics") version "2.9.9" apply false
        //       And in android/app/build.gradle.kts:
        //         alias(libs.plugins.google.services)
        //         alias(libs.plugins.firebase.crashlytics)
        //       Finally, uncomment the three lines below:
        // FirebaseApp.initializeApp(this)
        // FirebaseCrashlytics.getInstance().setCrashlyticsCollectionEnabled(!BuildConfig.DEBUG)
    }
}
