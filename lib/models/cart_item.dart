import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String dishId;
  final int quantity;
  final DateTime addedAt;

  CartItem({
    required this.dishId,
    required this.quantity,
    required this.addedAt,
  });

  factory CartItem.fromFirestore(Map<String, dynamic> data) {
    return CartItem(
      dishId: data['dishId'] ?? '',
      quantity: data['quantity']?.toInt() ?? 1,
      addedAt: _parseTimestamp(data['addedAt']),
    );
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    return DateTime.now(); 
  }

  Map<String, dynamic> toFirestore() {
    return {
      'dishId': dishId,
      'quantity': quantity,
      'addedAt': FieldValue.serverTimestamp(),
    };
  }
}