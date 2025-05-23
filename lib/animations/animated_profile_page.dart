import 'package:digital_restaurant/pages/order_history_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class AnimatedProfilePage extends StatefulWidget {
  const AnimatedProfilePage({super.key});

  @override
  State<AnimatedProfilePage> createState() => _AnimatedProfilePageState();
}

class _AnimatedProfilePageState extends State<AnimatedProfilePage> 
    with SingleTickerProviderStateMixin {
  
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  String _userInitials = "";
  String _userName = "";
  String _userEmail = "";
  String _joinDate = "";
  
  late AnimationController _animationController;
  late Animation<double> _avatarAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _avatarAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic),
    ));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _loadUserData() {
    if (_currentUser != null) {
      setState(() {
        _userEmail = _currentUser.email ?? "No email";
        _userName = _currentUser.displayName ?? 
            (_userEmail.contains('@') ? _userEmail.split('@')[0] : "User");
        
        if (_currentUser.displayName != null && _currentUser.displayName!.isNotEmpty) {
          List<String> nameParts = _currentUser.displayName!.split(' ');
          if (nameParts.length > 1) {
            _userInitials = nameParts[0][0] + nameParts[1][0];
          } else {
            _userInitials = nameParts[0][0];
          }
        } else {
          _userInitials = _userName[0].toUpperCase();
        }
        
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
      
      context.go('/login');
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
            _animationController.reverse().then((_) {
              if (mounted) {
                context.go("/home");
              }
            });
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
                    // Animated avatar
                    Center(
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.5, end: 1.0).animate(_avatarAnimation),
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
                    ),
                    
                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
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
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
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
                                  context.push('/edit-profile');
                                },
                              ),
                              Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey[300]),
                              ListTile(
                                leading: Icon(Icons.history, color: Theme.of(context).colorScheme.onSurface),
                                title: const Text("Order history"),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const OrderHistoryPage(),
                                    ),
                                  );
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
                ),
              ),
            ],
          ),
    );
  }
}