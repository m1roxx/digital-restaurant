import 'package:digital_restaurant/pages/saved_page.dart';
import 'package:digital_restaurant/pages/cart_page.dart';
import 'package:digital_restaurant/pages/menu_page.dart';
import 'package:digital_restaurant/pages/profile_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    MenuPage(),
    CartPage(),
    BookmarkPage(),
    ProfilePage(),
  ];

  final List<String> _appBarTitles = [
    "Menu",
    "Cart",
    "Saved",
    "Profile",
  ];

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]),
        leading: const Icon(Icons.menu),
        actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
          },
        ),
      ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: "Menu"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Saved"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ]
      ),
    );
  }
}