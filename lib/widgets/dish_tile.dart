import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_restaurant/models/dish.dart';
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
                  IconButton.filled(
                    onPressed: () async {
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
                          .doc(dish.id);

                      try {
                        await FirebaseFirestore.instance.runTransaction(
                          (transaction) async {
                            final doc = await transaction.get(cartItemRef);
                            if (doc.exists) {
                              final currentQty = doc['quantity'] as int;
                              transaction.update(
                                  cartItemRef, {'quantity': currentQty + 1});
                            } else {
                              transaction.set(cartItemRef, {
                                'dishId': dish.id,
                                'quantity': 1,
                                'addedAt': FieldValue.serverTimestamp(),
                              });
                            }
                          },
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added ${dish.title} to cart'),
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
                    },
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(6),
                      minimumSize: const Size(36, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    iconSize: 20,
                    icon: const Icon(Icons.add),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}