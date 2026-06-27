import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return android;
      case TargetPlatform.fuchsia:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCh75C5MJIe1BTYzQCIbNY3pPQ_UlcX05I',
    appId: '1:193099775822:android:166eaecd969cbae657681f',
    messagingSenderId: '193099775822',
    projectId: 'lifedonor-67082',
    storageBucket: 'lifedonor-67082.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBcTeOObEOtI3NPECBuUouAi3NQfa4s204',
    appId: '1:193099775822:web:95241282a536b24657681f',
    messagingSenderId: '193099775822',
    projectId: 'lifedonor-67082',
    authDomain: 'lifedonor-67082.firebaseapp.com',
    storageBucket: 'lifedonor-67082.firebasestorage.app',
    measurementId: 'G-CLKR0DH0M3',
  );
}
