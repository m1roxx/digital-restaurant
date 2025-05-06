import 'package:digital_restaurant/auth_wrapper.dart';
import 'package:digital_restaurant/pages/auth/login_page.dart';
import 'package:digital_restaurant/pages/auth/register_page.dart';
import 'package:digital_restaurant/pages/cart_page.dart';
import 'package:digital_restaurant/pages/edit_profile_page.dart';
import 'package:digital_restaurant/pages/home_page.dart';
import 'package:digital_restaurant/pages/menu_page.dart';
import 'package:digital_restaurant/pages/profile_page.dart';
import 'package:digital_restaurant/pages/saved_page.dart';
import 'package:digital_restaurant/pages/settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ErrorScreen extends StatelessWidget {
  final String error;
  
  const ErrorScreen({super.key, required this.error});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Страница не найдена'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 100,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Ошибка 404',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Запрашиваемая страница не найдена',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Вернуться на главную'),
            ),
          ],
        ),
      ),
    );
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: false,
  errorBuilder: (context, state) => ErrorScreen(
    error: state.error?.toString() ?? 'Unknown error',
  ),
  redirect: (BuildContext context, GoRouterState state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isAuthRoute = state.uri.toString() == '/' || 
                        state.uri.toString() == '/login' || 
                        state.uri.toString() == '/register';

    // Если пользователь авторизован и пытается попасть на страницу входа/регистрации
    if (isLoggedIn && isAuthRoute) {
      return '/home';
    }

    // Если пользователь не авторизован и пытается попасть на защищенную страницу
    if (!isLoggedIn && !isAuthRoute) {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthWrapper(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfilePage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/menu',
      builder: (context, state) => MenuPage(),
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartPage(),
    ),
    GoRoute(
      path: '/saved',
      builder: (context, state) => const BookmarkPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);