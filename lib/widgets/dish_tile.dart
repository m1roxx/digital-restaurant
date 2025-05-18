import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_restaurant/models/dish.dart';
import 'package:digital_restaurant/services/favorites_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Widget dishTile(BuildContext context, Dish dish) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            SizedBox(
              height: 180,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  dish.imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            // Favorite button
            Positioned(
              top: 8,
              right: 8,
              child: _FavoriteButton(dishId: dish.id!),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16),
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
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "\$${dish.price.toString()}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  _AnimatedAddButton(dish: dish),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _FavoriteButton extends StatefulWidget {
  final String dishId;

  const _FavoriteButton({required this.dishId});

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isFavorite = false;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    _checkFavoriteStatus();
  }
  
  Future<void> _checkFavoriteStatus() async {
    final isFavorite = await FavoritesService.isInFavorites(widget.dishId);
    if (mounted) {
      setState(() {
        _isFavorite = isFavorite;
        _isLoading = false;
      });
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    _controller.forward().then((_) => _controller.reverse());
    
    final newStatus = await FavoritesService.toggleFavorite(context, widget.dishId);
    if (mounted) {
      setState(() => _isFavorite = newStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    
    return GestureDetector(
      onTap: _toggleFavorite,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 20,
                color: _isFavorite ? Colors.red : Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedAddButton extends StatefulWidget {
  final Dish dish;

  const _AnimatedAddButton({required this.dish});

  @override
  _AnimatedAddButtonState createState() => _AnimatedAddButtonState();
}

class _AnimatedAddButtonState extends State<_AnimatedAddButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addToCart(BuildContext context) async {
    // Запускаем анимацию при нажатии
    _controller.forward().then((_) => _controller.reverse());
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add to cart'),
        ),
      );
      return;
    }

    final cartItemRef = FirebaseFirestore.instance
        .collection('carts')
        .doc(user.uid)
        .collection('items')
        .doc(widget.dish.id);

    try {
      await FirebaseFirestore.instance.runTransaction(
        (transaction) async {
          final doc = await transaction.get(cartItemRef);
          if (doc.exists) {
            final currentQty = doc['quantity'] as int;
            transaction.update(cartItemRef, {'quantity': currentQty + 1});
          } else {
            transaction.set(cartItemRef, {
              'dishId': widget.dish.id,
              'quantity': 1,
              'addedAt': FieldValue.serverTimestamp(),
            });
          }
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${widget.dish.title} to cart'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _addToCart(context),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                      spreadRadius: _controller.value * 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.add,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}