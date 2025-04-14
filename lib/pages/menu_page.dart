import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_restaurant/widgets/dish_tile.dart';
import 'package:digital_restaurant/models/dish.dart';
import 'package:digital_restaurant/pages/detail_page.dart';
import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  MenuPage({super.key});
  
  final Stream<QuerySnapshot> _dishesStream =
    FirebaseFirestore.instance.collection('dishes').snapshots();
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Text
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

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
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
        
        Container(
          height: 360,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: StreamBuilder<QuerySnapshot>(
            stream: _dishesStream,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final List<Dish> dishes = snapshot.data!.docs.map((doc) {
                return Dish(
                  id: doc.id,
                  title: doc['title'],
                  price: doc['price'] as int,
                  description: doc['description'],
                  imagePath: doc['imagePath'],
                  shortDescription: doc['shortDescription'],
                );
              }).toList();
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dishes.length,
                itemBuilder: (context, index) {
                  final dish = dishes[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(dish: dish),
                          ),
                        );
                      },
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