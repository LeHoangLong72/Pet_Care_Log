import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pet_care_log/providers/auth_provider.dart' as custom_auth;
import 'package:pet_care_log/providers/pet_provider.dart';
import 'package:pet_care_log/providers/log_provider.dart';
import 'package:pet_care_log/views/auth/login_screen.dart';
import 'package:pet_care_log/views/home/home_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Tắt xác thực App để tránh bị treo reCAPTCHA trên máy ảo
  // (Chỉ hoạt động trên Android/iOS)
  try {
    await FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
  } catch (e) {
    debugPrint("Lỗi cấu hình xác thực: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => custom_auth.AuthProvider()),
        ChangeNotifierProxyProvider<custom_auth.AuthProvider, PetProvider>(
          create: (_) => PetProvider(),
          update: (_, auth, petProvider) => petProvider!..updateUserId(auth.user?.uid),
        ),
        ChangeNotifierProxyProvider<custom_auth.AuthProvider, LogProvider>(
          create: (_) => LogProvider(),
          update: (_, auth, logProvider) => logProvider!..updateUserId(auth.user?.uid),
        ),
      ],
      child: MaterialApp(
        title: 'PetCareLog',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<custom_auth.AuthProvider>(context);
    
    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}
