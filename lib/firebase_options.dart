// TODO Implement this library.// File: lib/core/firebase/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for your project.
/// This file is typically generated via the FlutterFire CLI.
/// Run: flutterfire configure
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDEb5I0t2606YMozdQtGYxiq8oW_QJF-gk",
    appId: "1:154627419463:web:1:154627419463:web:9d4ad22c10de7e61067062", // Replace with your actual web app ID from Firebase Console
    messagingSenderId: "154627419463",
    projectId: "livora-b5b9e",
    authDomain: "livora-b5b9e.firebaseapp.com",
    storageBucket: "livora-b5b9e.appspot.com",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDEb5I0t2606YMozdQtGYxiq8oW_QJF-gk",
    appId: "1:154627419463:android:ee69702c1ffb680c067062",
    messagingSenderId: "154627419463",
    projectId: "livora-b5b9e",
    storageBucket: "livora-b5b9e.firebasestorage.app",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "YOUR_IOS_API_KEY",
    appId: "YOUR_IOS_APP_ID",
    messagingSenderId: "YOUR_SENDER_ID",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT_ID.appspot.com",
    iosBundleId: "com.example.app", // Replace with your actual iOS bundle ID
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: "YOUR_MACOS_API_KEY",
    appId: "YOUR_MACOS_APP_ID",
    messagingSenderId: "YOUR_SENDER_ID",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT_ID.appspot.com",
    iosBundleId: "com.example.app", // Replace with your macOS bundle ID
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: "YOUR_WINDOWS_API_KEY",
    appId: "YOUR_WINDOWS_APP_ID",
    messagingSenderId: "YOUR_SENDER_ID",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT_ID.appspot.com",
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: "YOUR_LINUX_API_KEY",
    appId: "YOUR_LINUX_APP_ID",
    messagingSenderId: "YOUR_SENDER_ID",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT_ID.appspot.com",
  );
}
