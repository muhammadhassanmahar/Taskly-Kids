// File generated manually from Firebase Web config
// ignore_for_file: type=lint

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCzThq5bxcqykGYDf1zFK1UrKTZXVd0Ee0",
    authDomain: "taskly-kids.firebaseapp.com",
    projectId: "taskly-kids",
    storageBucket: "taskly-kids.firebasestorage.app",
    messagingSenderId: "461535035050",
    appId: "1:461535035050:web:ecf2f952b97fa534ab5ad3",
    measurementId: "G-6SEY46H0SR",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyCzThq5bxcqykGYDf1zFK1UrKTZXVd0Ee0",
    appId: "1:461535035050:web:ecf2f952b97fa534ab5ad3",
    messagingSenderId: "461535035050",
    projectId: "taskly-kids",
    storageBucket: "taskly-kids.firebasestorage.app",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyCzThq5bxcqykGYDf1zFK1UrKTZXVd0Ee0",
    appId: "1:461535035050:web:ecf2f952b97fa534ab5ad3",
    messagingSenderId: "461535035050",
    projectId: "taskly-kids",
    storageBucket: "taskly-kids.firebasestorage.app",
    iosBundleId: "com.example.app", 
  );
}