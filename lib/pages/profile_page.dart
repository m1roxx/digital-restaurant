import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:digital_restaurant/pages/auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  String _userInitials = "";
  String _userName = "";
  String _userEmail = "";
  String _joinDate = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    if (_currentUser != null) {
      setState(() {
        // Получаем email пользователя
        _userEmail = _currentUser!.email ?? "No email";
        
        // Получаем имя пользователя, если оно отсутствует, используем первую часть email
        _userName = _currentUser.displayName ?? 
            (_userEmail.contains('@') ? _userEmail.split('@')[0] : "User");
        
        // Создаем инициалы из имени пользователя
        if (_currentUser!.displayName != null && _currentUser.displayName!.isNotEmpty) {
          List<String> nameParts = _currentUser!.displayName!.split(' ');
          if (nameParts.length > 1) {
            _userInitials = nameParts[0][0] + nameParts[1][0];
          } else {
            _userInitials = nameParts[0][0];
          }
        } else {
          _userInitials = _userName[0].toUpperCase();
        }
        
        // Форматируем дату создания аккаунта
        final creationTime = _currentUser.metadata.creationTime;
        if (creationTime != null) {
          final month = _getMonthName(creationTime.month);
          _joinDate = "Joined $month ${creationTime.day}, ${creationTime.year}";
        } else {
          _joinDate = "Registration date unavailable";
        }
      });
    }
  }

  String _getMonthName(int month) {
    const months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return months[month - 1];
  }

  // Функция выхода из аккаунта
  Future<void> _signOut() async {
    final bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to exit?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              "Exit",
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      
      // Перенаправляем на страницу логина после выхода
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _currentUser == null 
        ? const Center(child: Text("Пользователь не авторизован")) 
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        ),
                        child: Center(
                          child: Text(
                            _userInitials,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    Text(
                      _userName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _joinDate,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // General 
                    Text(
                      "General",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.person, color: Theme.of(context).colorScheme.onSurface),
                            title: Text(_userName),
                            dense: true,
                          ),
                          Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey[300]),
                          ListTile(
                            leading: Icon(Icons.email, color: Theme.of(context).colorScheme.onSurface),
                            title: Text(_userEmail),
                            dense: true,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      "Account",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.edit, color: Theme.of(context).colorScheme.onSurface),
                            title: const Text("Edit profile"),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // Навигация на страницу редактирования профиля
                            },
                          ),
                          Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey[300]),
                          ListTile(
                            leading: Icon(Icons.history, color: Theme.of(context).colorScheme.onSurface),
                            title: const Text("Order history"),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // Навигация на страницу истории заказов
                            },
                          ),
                          Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey[300]),
                          ListTile(
                            leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
                            title: Text(
                              "Logout",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            onTap: _signOut,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}