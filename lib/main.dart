import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:firebase_core/firebase_core.dart'; // Connexion Firebase
import 'firebase_options.dart'; // Fichier généré automatiquement via flutterfire configure

import 'config/app_config.dart';
import 'providers/auth_provider.dart';
import 'providers/items_provider.dart';
import 'providers/messages_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/main_navigation.dart';
import 'services/mock_data_service.dart';

Future<void> main() async {
  // Assure que les liaisons des widgets Flutter sont initialisées avant le code asynchrone
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation globale de Firebase avec les configurations du projet
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize timeago in French
  timeago.setLocaleMessages('fr', timeago.FrMessages());

  // Remplissage des fausses données (si activé dans ta config)
  if (AppConfig.useMockData) {
    MockDataService.instance.seedData();
  }

  runApp(const ObjetsPerdusDuCampusApp());
}

class ObjetsPerdusDuCampusApp extends StatelessWidget {
  const ObjetsPerdusDuCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ItemsProvider()),
        ChangeNotifierProvider(create: (_) => MessagesProvider()),
        ChangeNotifierProvider(create: (_) {
          final notif = NotificationProvider();
          notif.initialize();
          return notif;
        }),
      ],
      child: MaterialApp(
        title: 'Objets Perdus du Campus',
        debugShowCheckedModeBanner: false,
        theme: AppConfig.theme,
        home: const _AuthWrapper(),
      ),
    );
  }
}

/// Redirects to LoginScreen or MainNavigation based on auth state.
class _AuthWrapper extends StatelessWidget {
  const _AuthWrapper();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.status == AuthStatus.initial) {
      return const _SplashScreen();
    }

    if (auth.isAuthenticated) {
      return const MainNavigation();
    }

    return const LoginScreen();
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.surfaceColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppConfig.primaryColor, AppConfig.primaryDark]),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                      color: AppConfig.primaryColor.withOpacity(0.4),
                      blurRadius: 24, offset: const Offset(0, 8))
                ],
              ),
              child: const Icon(Icons.search_rounded, color: Colors.white, size: 52),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
                color: AppConfig.primaryColor, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}