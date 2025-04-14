import 'package:digital_restaurant/auth_wrapper.dart';
import 'package:digital_restaurant/controllers/theme_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:digital_restaurant/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    
    // Light Theme
    final lightTheme = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF5F2F3),
      primaryColor: const Color(0xFFA73238),
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFFA73238), 
        onPrimary: Colors.white,
        secondary: Color(0xFFFFD9DC),     
        onSecondary: Colors.black,
        error: Colors.red,
        onError: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFFA73238),
        unselectedItemColor: Colors.grey,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA73238),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
      ),
    );

    // Dark Theme
    final darkTheme = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      primaryColor: const Color(0xFFA73238),
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: const Color(0xFFA73238),       
        onPrimary: Colors.white,
        secondary: const Color(0xFF4E2326),     
        onSecondary: Colors.white,
        error: Colors.red.shade300,
        onError: Colors.black,    
        surface: const Color(0xFF2C2C2C),       
        onSurface: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(color: Colors.white70),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF2C2C2C),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2C2C2C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF2C2C2C),
        selectedItemColor: Color(0xFFA73238),
        unselectedItemColor: Colors.grey,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA73238),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFA73238),
        foregroundColor: Colors.white,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Restaurant',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AuthWrapper(),
    );
  }
}