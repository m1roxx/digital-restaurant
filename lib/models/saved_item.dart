import 'package:cloud_firestore/cloud_firestore.dart';

class SavedItem {
  final String dishId;
  final DateTime savedAt;

  SavedItem({
    required this.dishId,
    required this.savedAt,
  });

  factory SavedItem.fromFirestore(Map<String, dynamic> data) {
    return SavedItem(
      dishId: data['dishId'] ?? '',
      savedAt: _parseTimestamp(data['savedAt']),
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
      'savedAt': FieldValue.serverTimestamp(),
    };
  }
}