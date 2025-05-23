import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/review.dart';

class ReviewService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<List<Review>> getReviewsForDish(String dishId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('dishId', isEqualTo: dishId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Review.fromFirestore(data, doc.id);
      }).toList();
    } catch (e) {
      print('Error getting reviews: $e');
      return [];
    }
  }

  static Stream<List<Review>> getReviewsStream(String dishId) {
    return _firestore
        .collection('reviews')
        .where('dishId', isEqualTo: dishId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Review.fromFirestore(data, doc.id);
      }).toList();
    });
  }

  static Future<bool> addReview({
    required String dishId,
    required double rating,
    required String comment,
    required BuildContext context,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add a review')),
      );
      return false;
    }

    try {
      // Check if user already reviewed this dish
      final existingReview = await _firestore
          .collection('reviews')
          .where('dishId', isEqualTo: dishId)
          .where('userId', isEqualTo: user.uid)
          .get();

      if (existingReview.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have already reviewed this dish')),
        );
        return false;
      }

      // Get user name from auth or use email as fallback
      String userName = user.displayName ?? user.email?.split('@')[0] ?? 'Anonymous';

      // Add review
      final reviewData = Review(
        dishId: dishId,
        userId: user.uid,
        userName: userName,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('reviews').add(reviewData.toFirestore());

      // Update dish average rating
      await _updateDishRating(dishId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review added successfully')),
      );
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding review: $e')),
      );
      return false;
    }
  }

  static Future<void> _updateDishRating(String dishId) async {
    try {
      final reviews = await getReviewsForDish(dishId);
      if (reviews.isEmpty) return;

      double totalRating = 0;
      for (var review in reviews) {
        totalRating += review.rating;
      }

      double averageRating = totalRating / reviews.length;
      int reviewCount = reviews.length;

      await _firestore.collection('dishes').doc(dishId).update({
        'averageRating': averageRating,
        'reviewCount': reviewCount,
      });
    } catch (e) {
      print('Error updating dish rating: $e');
    }
  }

  static Future<bool> hasUserReviewed(String dishId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('dishId', isEqualTo: dishId)
          .where('userId', isEqualTo: user.uid)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteReview(String reviewId, String dishId, BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      await _firestore.collection('reviews').doc(reviewId).delete();
      await _updateDishRating(dishId);
      
      // Проверяем, что контекст еще активен
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review deleted successfully')),
        );
      }
      return true;
    } catch (e) {
      // Проверяем, что контекст еще активен
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting review: $e')),
        );
      }
      return false;
    }
  }
}