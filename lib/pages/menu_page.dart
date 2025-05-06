import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_restaurant/widgets/dish_tile.dart';
import 'package:digital_restaurant/models/dish.dart';
import 'package:digital_restaurant/pages/detail_page.dart';
import 'package:flutter/material.dart';

enum SortType { lowToHigh, highToLow }

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final Stream<QuerySnapshot> _dishesStream =
      FirebaseFirestore.instance.collection('dishes').snapshots();
  String _searchQuery = '';
  String? _selectedCategory;
  SortType _currentSort = SortType.lowToHigh;

  Widget _buildCategoryChip(String label, String? category) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _selectedCategory == category,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        labelStyle: TextStyle(
          color: _selectedCategory == category 
              ? Theme.of(context).colorScheme.primary 
              : Colors.grey[600],
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
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

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip('All', null),
                _buildCategoryChip('Hot Dishes', 'hot dishes'),
                _buildCategoryChip('Soups', 'soups'),
              ],
            ),
          ),
        ),
        
        Container(
          height: 360,
          padding: const EdgeInsets.symmetric(vertical: 16),
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

              List<Dish> filteredDishes = allDishes.where((dish) {
                final matchesSearch = dish.title.toLowerCase().contains(_searchQuery.toLowerCase());
                final matchesCategory = _selectedCategory == null 
                    ? true 
                    : dish.category == _selectedCategory;
                return matchesSearch && matchesCategory;
              }).toList();

              filteredDishes.sort((a, b) => _currentSort == SortType.lowToHigh
                ? a.price.compareTo(b.price)
                : b.price.compareTo(a.price)
              );

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filteredDishes.length,
                itemBuilder: (context, index) {
                  final dish = filteredDishes[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 16),
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