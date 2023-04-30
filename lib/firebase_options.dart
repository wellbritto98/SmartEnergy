// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBs8o4rCZAAwbeTC3ZDgA0Ui71Zsx2EPhE',
    appId: '1:680152858800:web:062c3eedffb8ac739d3b75',
    messagingSenderId: '680152858800',
    projectId: 'smartenergy-f37f0',
    authDomain: 'smartenergy-f37f0.firebaseapp.com',
    storageBucket: 'smartenergy-f37f0.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyATX3aNE2QgPAJUu0CM46RfseTlbAdq7cc',
    appId: '1:680152858800:android:ec9243d0c6c4b3619d3b75',
    messagingSenderId: '680152858800',
    projectId: 'smartenergy-f37f0',
    storageBucket: 'smartenergy-f37f0.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBY4XDngxLLNg_UBJZRg9IdIlDvcaoi5kQ',
    appId: '1:680152858800:ios:4cf1b65e4da51f369d3b75',
    messagingSenderId: '680152858800',
    projectId: 'smartenergy-f37f0',
    storageBucket: 'smartenergy-f37f0.appspot.com',
    iosClientId: '680152858800-gcth6i0ice0njfer0p2tld53b1emb5gi.apps.googleusercontent.com',
    iosBundleId: 'com.example.smartEnergy',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBY4XDngxLLNg_UBJZRg9IdIlDvcaoi5kQ',
    appId: '1:680152858800:ios:4cf1b65e4da51f369d3b75',
    messagingSenderId: '680152858800',
    projectId: 'smartenergy-f37f0',
    storageBucket: 'smartenergy-f37f0.appspot.com',
    iosClientId: '680152858800-gcth6i0ice0njfer0p2tld53b1emb5gi.apps.googleusercontent.com',
    iosBundleId: 'com.example.smartEnergy',
  );
}
