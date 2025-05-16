import 'package:digital_restaurant/animations/custom_page_transitions.dart';
import 'package:digital_restaurant/pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:digital_restaurant/pages/menu_page.dart';
import 'package:digital_restaurant/pages/cart_page.dart';
import 'package:digital_restaurant/pages/saved_page.dart';
import 'package:digital_restaurant/pages/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  final List<Widget> _pages = [
    const MenuPage(),
    const CartPage(),
    const BookmarkPage(),
    const SettingsPage(),
  ];
  
  final List<String> _appBarTitles = [
    "Menu",
    "Cart",
    "Saved",
    "Settings",
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateBottomBar(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String _getUserInitials() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return "?";
    
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      List<String> nameParts = user.displayName!.split(' ');
      if (nameParts.length > 1) {
        return (nameParts[0][0] + nameParts[1][0]).toUpperCase();
      } else {
        return nameParts[0][0].toUpperCase();
      }
    }
    
    if (user.email != null && user.email!.isNotEmpty) {
      if (user.email!.contains('@')) {
        return user.email![0].toUpperCase();
      }
      return user.email![0].toUpperCase();
    }
    
    return "?";
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]),
        leading: const Icon(Icons.menu),
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            child: Hero(
              tag: 'profile-icon',
              child: Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    _getUserInitials(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              flightShuttleBuilder: (
                BuildContext flightContext,
                Animation<double> animation,
                HeroFlightDirection flightDirection,
                BuildContext fromHeroContext,
                BuildContext toHeroContext,
              ) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  ),
                  child: Center(
                    child: Text(
                      _getUserInitials(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: Tween<double>(begin: 16, end: 28).evaluate(animation),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
            onTap: () {
              final RenderBox renderBox = context.findRenderObject() as RenderBox;
              final position = renderBox.localToGlobal(Offset.zero);              
              final screenWidth = MediaQuery.of(context).size.width;
              final startOffset = Offset((position.dx / screenWidth) - 0.5, -0.2);
              
              Navigator.of(context).push(
                ProfilePageTransition(
                  page: const ProfilePage(),
                  begin: startOffset,
                ),
              );
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: "Menu"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Saved"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ]
      ),
    );
  }
}