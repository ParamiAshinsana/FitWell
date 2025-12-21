import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return web;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC3h3kR0HRCRaPScJ_yh31mh-OfLAR5Tt8',
    appId: '1:401665416758:web:9e63e8047fc3d46d5d0297',
    messagingSenderId: '401665416758',
    projectId: 'fitwell-4542a',
    authDomain: 'fitwell-4542a.firebaseapp.com',
    storageBucket: 'fitwell-4542a.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAP94jfFLeGlEdDnvWo0_LJtU1blVBOQ6E',
    appId: '1:879271719252:android:5af9cac97718149652d8c1',
    messagingSenderId: '879271719252',
    projectId: 'fitwell-36502',
    storageBucket: 'fitwell-36502.firebasestorage.app',
  );
}

