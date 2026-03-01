import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  static FirebaseOptions web = FirebaseOptions(
    apiKey: dotenv.get('FIREBASE_API_KEY_WEB'),
    appId: dotenv.get('FIREBASE_APP_ID'),
    messagingSenderId: dotenv.get('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: dotenv.get('FIREBASE_PROJECT_ID'),
    authDomain: dotenv.get('FIREBASE_AUTH_DOMAIN'),
    storageBucket: dotenv.get('FIREBASE_STORAGE_BUCKET'),
    measurementId: dotenv.get('FIREBASE_MEASUREMENT_ID'),
  );

  static  FirebaseOptions android = FirebaseOptions(
    apiKey: dotenv.get('FIREBASE_API_KEY_ANDROID'),
    appId: dotenv.get('FIREBASE_APP_ID'),
    messagingSenderId: dotenv.get('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: dotenv.get('FIREBASE_PROJECT_ID'),
    storageBucket:dotenv.get('FIREBASE_STORAGE_BUCKET'),
  );

  static FirebaseOptions ios = FirebaseOptions(
    apiKey: dotenv.get('FIREBASE_API_IOS'),
    appId: dotenv.get('FIREBASE_APP_ID'),
    messagingSenderId: dotenv.get('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: dotenv.get('FIREBASE_PROJECT_ID'),
    storageBucket: dotenv.get('FIREBASE_STORAGE_BUCKET'),
    iosBundleId: dotenv.get('FIREBASE_IOS_BUNDLE_ID'),
  );
}
