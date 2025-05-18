import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_restaurant/models/dish.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoritesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check if a dish is saved
  static Future<bool> isInFavorites(String dishId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore
          .collection('saved')
          .doc(user.uid)
          .collection('items')
          .doc(dishId)
          .get();
      
      return doc.exists;
    } catch (e) {
      print('Error checking favorites status: $e');
      return false;
    }
  }

  // Add dish to favorites
  static Future<void> addToFavorites(BuildContext context, String dishId) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save favorites')),
      );
      return;
    }

    try {
      await _firestore
          .collection('saved')
          .doc(user.uid)
          .collection('items')
          .doc(dishId)
          .set({
        'dishId': dishId,
        'savedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to favorites'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // Remove dish from favorites
  static Future<void> removeFromFavorites(BuildContext context, String dishId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('saved')
          .doc(user.uid)
          .collection('items')
          .doc(dishId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from favorites'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // Toggle favorite status
  static Future<bool> toggleFavorite(BuildContext context, String dishId) async {
    final isFavorite = await isInFavorites(dishId);
    
    if (isFavorite) {
      await removeFromFavorites(context, dishId);
      return false;
    } else {
      await addToFavorites(context, dishId);
      return true;
    }
  }
}