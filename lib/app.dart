import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_preview/device_preview.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/client_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/email_template_provider.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/clients/add_client_screen.dart';
import 'screens/clients/edit_client_screen.dart';
import 'screens/clients/client_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  final SharedPreferences prefs;
  final FirebaseService firebaseService;
  final NotificationService notificationService;

  const App({
    super.key,
    required this.prefs,
    required this.firebaseService,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ClientProvider(firebaseService),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(FirebaseFirestore.instance),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(firebaseService),
        ),
        ChangeNotifierProvider(
          create: (_) => EmailTemplateProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Burtone',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
              '/add-client': (context) => const AddClientScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/edit-client') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => EditClientScreen(client: args['client']),
                );
              }
              if (settings.name == '/client-detail') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => ClientDetailScreen(client: args['client']),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
} 