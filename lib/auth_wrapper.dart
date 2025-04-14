import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:digital_restaurant/pages/home_page.dart';
import 'package:digital_restaurant/pages/auth/login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the user is logged in, direct to HomePage
        if (snapshot.hasData) {
          return const HomePage();
        }
        // If the user is not logged in, direct to LoginPage
        return const LoginPage();
      },
    );
  }
}