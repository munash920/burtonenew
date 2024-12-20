import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
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
    apiKey: 'AIzaSyBW2AIY8F3ylAvAfOGJs6rJdmzg1hBjTQg',
    appId: '1:957546529821:web:5248822444444444',
    messagingSenderId: '957546529821',
    projectId: 'burtone-app',
    authDomain: 'burtone-app.firebaseapp.com',
    storageBucket: 'burtone-app.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBW2AIY8F3ylAvAfOGJs6rJdmzg1hBjTQg',
    appId: '1:957546529821:android:5248822444444444',
    messagingSenderId: '957546529821',
    projectId: 'burtone-app',
    storageBucket: 'burtone-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBW2AIY8F3ylAvAfOGJs6rJdmzg1hBjTQg',
    appId: '1:957546529821:ios:5248822444444444',
    messagingSenderId: '957546529821',
    projectId: 'burtone-app',
    storageBucket: 'burtone-app.appspot.com',
    iosClientId: 'com.burtonesolutions.burtone',
    iosBundleId: 'com.burtonesolutions.burtone',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBW2AIY8F3ylAvAfOGJs6rJdmzg1hBjTQg',
    appId: '1:957546529821:macos:5248822444444444',
    messagingSenderId: '957546529821',
    projectId: 'burtone-app',
    storageBucket: 'burtone-app.appspot.com',
    iosClientId: 'com.burtonesolutions.burtone.macos',
    iosBundleId: 'com.burtonesolutions.burtone',
  );
} 