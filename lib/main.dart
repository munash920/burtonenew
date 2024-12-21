import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_preview/device_preview.dart';
import 'firebase_options.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize services
    final prefs = await SharedPreferences.getInstance();
    final firebaseService = FirebaseService();
    final notificationService = NotificationService();

    // Run app with DevicePreview
    runApp(
      DevicePreview(
        enabled: true,
        tools: const [
          ...DevicePreview.defaultTools,
        ],
        builder: (context) => App(
          prefs: prefs,
          firebaseService: firebaseService,
          notificationService: notificationService,
        ),
      ),
    );
  } catch (e) {
    print('Error during initialization: $e');
  }
}
