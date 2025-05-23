import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double total;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final String status;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.orderDate,
    required this.deliveryDate,
    this.status = 'pending',
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toFirestore()).toList(),
      'total': total,
      'orderDate': Timestamp.fromDate(orderDate),
      'deliveryDate': Timestamp.fromDate(deliveryDate),
      'status': status,
    };
  }

  factory Order.fromFirestore(Map<String, dynamic> data, String orderId) {
    return Order(
      id: orderId,
      userId: data['userId'],
      items: (data['items'] as List)
          .map((item) => OrderItem.fromFirestore(item))
          .toList(),
      total: data['total'],
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      deliveryDate: (data['deliveryDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
    );
  }
}

class OrderItem {
  final String dishId;
  final String dishName;
  final double price;
  final int quantity;
  final String? imagePath;

  OrderItem({
    required this.dishId,
    required this.dishName,
    required this.price,
    required this.quantity,
    this.imagePath,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'dishId': dishId,
      'dishName': dishName,
      'price': price,
      'quantity': quantity,
      'imagePath': imagePath,
    };
  }

  factory OrderItem.fromFirestore(Map<String, dynamic> data) {
    return OrderItem(
      dishId: data['dishId'],
      dishName: data['dishName'],
      price: data['price'].toDouble(),
      quantity: data['quantity'],
      imagePath: data['imagePath'],
    );
  }
}