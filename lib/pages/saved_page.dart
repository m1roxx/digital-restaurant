import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_restaurant/models/dish.dart';
import 'package:digital_restaurant/pages/detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> savedDishIds = [];
  List<Dish> savedDishes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedDishes();
  }

  Future<void> _loadSavedDishes() async {
    if (mounted) {
      setState(() => isLoading = true);
    }
    
    final user = _auth.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      return;
    }

    try {
      // Get all saved dish IDs for current user
      final savedSnapshot = await _firestore
          .collection('saved')
          .doc(user.uid)
          .collection('items')
          .get();
      
      savedDishIds = savedSnapshot.docs.map((doc) => doc.id).toList();
      
      if (savedDishIds.isEmpty) {
        if (mounted) {
          setState(() {
            savedDishes = [];
            isLoading = false;
          });
        }
        return;
      }
      
      // Fetch dish details from Firestore
      final dishesSnapshot = await _firestore
          .collection('dishes')
          .where(FieldPath.documentId, whereIn: savedDishIds)
          .get();
      
      if (mounted) {
        setState(() {
          savedDishes = dishesSnapshot.docs.map((doc) => 
            Dish.fromFirestore(doc.data(), doc.id)
          ).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading saved dishes: ${e.toString()}')),
      );
    }
  }

  Future<void> _removeFromSaved(String dishId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      await _firestore
          .collection('saved')
          .doc(user.uid)
          .collection('items')
          .doc(dishId)
          .delete();
      
      if (mounted) {
        setState(() {
          savedDishIds.remove(dishId);
          savedDishes.removeWhere((dish) => dish.id == dishId);
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from favorites')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _buildSavedContent(),
    );
  }

  Widget _buildSavedContent() {
    if (_auth.currentUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Please log in to see your favorites',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to login page
              },
              child: const Text('Log In'),
            ),
          ],
        ),
      );
    }

    if (savedDishes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No favorite dishes yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'Add dishes to your favorites!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSavedDishes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: savedDishes.length,
        itemBuilder: (context, index) {
          final dish = savedDishes[index];
          return _buildSavedDishItem(dish);
        },
      ),
    );
  }

  Widget _buildSavedDishItem(Dish dish) {
    return Dismissible(
      key: Key(dish.id!),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _removeFromSaved(dish.id!),
      child: GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => DetailPage(dish: dish),
        ),
        child: Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Dish image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    dish.imagePath,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Dish details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dish.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dish.shortDescription,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${dish.price}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Remove button
                IconButton(
                  onPressed: () => _removeFromSaved(dish.id!),
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  splashRadius: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}