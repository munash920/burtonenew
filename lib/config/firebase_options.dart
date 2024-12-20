import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'your-actual-api-key',
      appId: 'your-actual-app-id',
      messagingSenderId: 'your-actual-sender-id',
      projectId: 'your-actual-project-id',
      storageBucket: 'your-actual-storage-bucket',
      androidClientId: 'com.burtonesolutions.burtone',
    );
  }
} 