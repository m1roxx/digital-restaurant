import 'package:digital_restaurant/pages/restaurant_map_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:digital_restaurant/controllers/theme_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    return ListView(
      children: [
        // Settings
        Container(
          margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Icon(Icons.arrow_forward_ios)
              ],
            ),
          ),
        ),
        
        // Dark Mode Switch
        Container(
          margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Dark Mode",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Switch(
                  value: themeController.isDarkMode,
                  onChanged: (_) {
                    themeController.toggleTheme();
                  },
                )
              ],
            ),
          ),
        ),
        
        // Choose a Restaurant 
        Container(
          margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RestaurantMapPage()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Choose a Restaurant",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios)
                ],
              ),
            ),
          ),
        ),
      ]
    );
  }
}