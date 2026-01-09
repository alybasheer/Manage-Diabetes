import 'package:diabatic/screens/entry_point.dart';
import 'package:diabatic/screens/login_screen.dart';
import 'package:diabatic/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/diet_screen.dart';
import '../screens/glucose_screen.dart';
import '../screens/home_screen.dart';
import '../screens/medication_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/tips_screen.dart';
import '../utils/theme.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
      url: 'https://gjaknhuffqkahyiclzvu.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdqYWtuaHVmZnFrYWh5aWNsenZ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU4MDk3MzUsImV4cCI6MjA4MTM4NTczNX0.MKYZ-EHqOKt0SsjCau8URvfwOeqMTI9AnmEQ6zHryX8');

  // Initialize Notification Service
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DiabetesCare',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/': (context) => const EntryPoint(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/tips': (context) => const TipsScreen(),
        '/glucose': (context) => const GlucoseScreen(),
        '/diet': (context) => const DietScreen(),
        '/medication': (context) => const MedicationScreen(),
        '/reports': (context) => const ReportsScreen(),
      },
    );
  }
}
