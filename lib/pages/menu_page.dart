import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_restaurant/widgets/dish_tile.dart';
import 'package:digital_restaurant/models/dish.dart';
import 'package:digital_restaurant/pages/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

enum SortType { lowToHigh, highToLow }
enum MenuType { main, bar }

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final Stream<QuerySnapshot> _dishesStream =
      FirebaseFirestore.instance.collection('dishes').snapshots();
  String _searchQuery = '';
  SortType _currentSort = SortType.lowToHigh;
  MenuType _currentMenuType = MenuType.main;

  Widget _buildCategorySection(String category, List<Dish> dishes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            category,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        SizedBox(
          height: 355,
          child: AnimationLimiter(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dishes.length,
              itemBuilder: (context, index) {
                final dish = dishes[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 500),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 16 : 12,
                          right: index == dishes.length - 1 ? 16 : 0,
                        ),
                        child: GestureDetector(
                          onTap: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => DetailPage(dish: dish),
                          ),
                          child: SizedBox(
                            width: 220,
                            child: dishTile(context, dish),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showSortMenu(BuildContext context) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;

    final result = await showMenu<SortType>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          button.localToGlobal(button.size.topRight(Offset.zero)),
          button.localToGlobal(button.size.bottomRight(Offset.zero)),
        ),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem<SortType>(
          value: SortType.lowToHigh,
          child: Row(
            children: [
              const Icon(Icons.arrow_upward, size: 20),
              const SizedBox(width: 12),
              Text(
                'Price: Low to High',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        PopupMenuItem<SortType>(
          value: SortType.highToLow,
          child: Row(
            children: [
              const Icon(Icons.arrow_downward, size: 20),
              const SizedBox(width: 12),
              Text(
                'Price: High to Low',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );

    if (result != null) {
      setState(() => _currentSort = result);
    }
  }

  Widget _buildMenuTypeSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: _buildMenuTypeButton(
              title: 'Main Menu',
              isSelected: _currentMenuType == MenuType.main,
              onPressed: () => setState(() => _currentMenuType = MenuType.main),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildMenuTypeButton(
              title: 'Bar Menu',
              isSelected: _currentMenuType == MenuType.bar,
              onPressed: () => setState(() => _currentMenuType = MenuType.bar),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTypeButton({
    required String title,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected 
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
        foregroundColor: isSelected 
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Text(
            "Let's find your\nfavorite food!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              height: 1.2,
            ),
          ),
        ),

        _buildMenuTypeSelector(),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.filter_list,
                      color: Theme.of(context).colorScheme.primary),
                  onPressed: () => _showSortMenu(context),
                  tooltip: 'Sort by price',
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _dishesStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              List<Dish> allDishes = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Dish.fromFirestore(data, doc.id);
              }).toList();

              // Apply search filter
              List<Dish> filteredDishes = allDishes;
              if (_searchQuery.isNotEmpty) {
                filteredDishes = allDishes.where((dish) {
                  return dish.title.toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();
              }

              // Sort dishes
              filteredDishes.sort((a, b) => _currentSort == SortType.lowToHigh
                ? a.price.compareTo(b.price)
                : b.price.compareTo(a.price)
              );

              // Group dishes by category
              Map<String, List<Dish>> categorizedDishes = {};
              for (var dish in filteredDishes) {
                if (!categorizedDishes.containsKey(dish.category)) {
                  categorizedDishes[dish.category] = [];
                }
                categorizedDishes[dish.category]!.add(dish);
              }

              // Define main menu and bar menu categories
              List<String> mainMenuCategories = [
                'breakfast',
                'soups',
                'hot dishes',
              ];
              
              List<String> barMenuCategories = [
                'bubble teas',
                'lemonades',
              ];

              // Select which categories to display based on current menu type
              List<String> categoriesToDisplay = _currentMenuType == MenuType.main
                  ? mainMenuCategories
                  : barMenuCategories;

              // Add any categories found in data that aren't in our predefined lists
              if (_currentMenuType == MenuType.main) {
                categorizedDishes.keys.forEach((category) {
                  if (!mainMenuCategories.contains(category) && 
                      !barMenuCategories.contains(category)) {
                    categoriesToDisplay.add(category);
                  }
                });
              }

              // Filter out categories that don't have dishes
              categoriesToDisplay = categoriesToDisplay.where(
                (category) => categorizedDishes.containsKey(category)
              ).toList();

              return categoriesToDisplay.isEmpty
                  ? Center(
                      child: Text(
                        'No dishes found for ${_currentMenuType == MenuType.main ? 'Main Menu' : 'Bar Menu'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: categoriesToDisplay.length,
                      itemBuilder: (context, index) {
                        final category = categoriesToDisplay[index];
                        final dishes = categorizedDishes[category]!;
                        return _buildCategorySection(
                          category[0].toUpperCase() + category.substring(1), // Capitalize first letter
                          dishes
                        );
                      },
                    );
            },
          ),
        ),
      ],
    );
  }
}