import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pet_care_log/providers/auth_provider.dart' as custom_auth;
import 'package:pet_care_log/providers/pet_provider.dart';
import 'package:pet_care_log/providers/log_provider.dart';
import 'package:pet_care_log/services/notification_service.dart';
import 'package:pet_care_log/views/auth/login_screen.dart';
import 'package:pet_care_log/views/navigation/main_navigation_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi chạy Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Khởi tạo các dịch vụ khác một cách không đồng bộ để không chặn luồng chính quá lâu
  NotificationService().init();
  
  try {
    FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
  } catch (e) {
    debugPrint("Lỗi cấu hình: $e");
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
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00695C), // Teal đậm
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto', // Font mặc định của Material
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            color: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            scrolledUnderElevation: 0,

            backgroundColor: Colors.transparent,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00695C), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
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
      return const MainNavigationScreen();
    } else {
      return const LoginScreen();
    }
  }
}
