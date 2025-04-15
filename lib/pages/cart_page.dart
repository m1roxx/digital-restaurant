import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_restaurant/models/cart_item.dart';
import 'package:digital_restaurant/models/dish.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view cart')),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('carts')
                  .doc(user.uid)
                  .collection('items')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart,
                            size: 60, color: Theme.of(context).hintColor),
                        const SizedBox(height: 16),
                        Text('Your cart is empty',
                            style: Theme.of(context).textTheme.headlineSmall),
                      ],
                    ),
                  );
                }

                final items = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final cartItem = CartItem.fromFirestore(
                        items[index].data() as Map<String, dynamic>);
                    final docId = items[index].id;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('dishes')
                          .doc(cartItem.dishId)
                          .get(),
                      builder: (context, dishSnapshot) {
                        if (!dishSnapshot.hasData) {
                          return const SizedBox();
                        }

                        final dish = Dish.fromFirestore(
                          dishSnapshot.data!.data() as Map<String, dynamic>,
                          dishSnapshot.data!.id,
                        );

                        return Dismissible(
                          key: Key(docId),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Theme.of(context).colorScheme.error,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: Icon(Icons.delete,
                                color: Theme.of(context).colorScheme.onError),
                          ),
                          onDismissed: (direction) => _deleteItem(user.uid, docId),
                          child: Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      dish.imagePath,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(dish.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                    fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Quantity: ${cartItem.quantity}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    currencyFormat.format(dish.price * cartItem.quantity),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          _TotalBar(userId: user.uid, currencyFormat: currencyFormat),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCheckoutDialog(context, user.uid),
        icon: const Icon(Icons.shopping_bag),
        label: const Text('Checkout'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _deleteItem(String userId, String itemId) async {
    await FirebaseFirestore.instance
        .collection('carts')
        .doc(userId)
        .collection('items')
        .doc(itemId)
        .delete();
  }

  Future<void> _showCheckoutDialog(BuildContext context, String userId) async {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    
    // Get total price from Firestore
    double total = 0;
    final cartItems = await FirebaseFirestore.instance
        .collection('carts')
        .doc(userId)
        .collection('items')
        .get();
    
    for (final cartItemDoc in cartItems.docs) {
      final cartItem = CartItem.fromFirestore(cartItemDoc.data());
      final dishDoc = await FirebaseFirestore.instance
          .collection('dishes')
          .doc(cartItem.dishId)
          .get();
      if (dishDoc.exists) {
        final dish = Dish.fromFirestore(dishDoc.data()!, dishDoc.id);
        total += dish.price * cartItem.quantity;
      }
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Complete Your Order',
                  style: Theme.of(context).textTheme.headlineSmall),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total: ${currencyFormat.format(total)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Text('Select Delivery Date and Time:',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 30)),
                            );
                            if (picked != null && picked != selectedDate) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            DateFormat('MMM dd, yyyy').format(selectedDate),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (picked != null && picked != selectedTime) {
                              setState(() {
                                selectedTime = picked;
                              });
                            }
                          },
                          icon: const Icon(Icons.access_time),
                          label: Text(selectedTime.format(context)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel',
                      style: TextStyle(color: Theme.of(context).hintColor)),
                ),
                FilledButton(
                  onPressed: () {
                    // Here you would process the order with the selected date and time
                    // Since you mentioned not saving to DB, we'll just close the dialog
                    Navigator.of(context).pop();
                    
                    // Show confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Order placed for ${DateFormat('MMM dd, yyyy').format(selectedDate)} at ${selectedTime.format(context)}',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Place Order'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _TotalBar extends StatelessWidget {
  final String userId;
  final NumberFormat currencyFormat;

  const _TotalBar({required this.userId, required this.currencyFormat});

  Stream<double> _getTotalStream() {
    return FirebaseFirestore.instance
        .collection('carts')
        .doc(userId)
        .collection('items')
        .snapshots()
        .asyncMap((cartSnapshot) async {
      double total = 0;
      for (final cartItemDoc in cartSnapshot.docs) {
        final cartItem = CartItem.fromFirestore(cartItemDoc.data());
        final dishDoc = await FirebaseFirestore.instance
            .collection('dishes')
            .doc(cartItem.dishId)
            .get();
        if (dishDoc.exists) {
          final dish = Dish.fromFirestore(dishDoc.data()!, dishDoc.id);
          total += dish.price * cartItem.quantity;
        }
      }
      return total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: StreamBuilder<double>(
        stream: _getTotalStream(),
        builder: (context, snapshot) {
          final total = snapshot.data ?? 0;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total:', style: Theme.of(context).textTheme.headlineSmall),
              Text(currencyFormat.format(total),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary)),
            ],
          );
        },
      ),
    );
  }
}