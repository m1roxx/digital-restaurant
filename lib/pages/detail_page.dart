import 'package:digital_restaurant/models/ingredient.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  final String title;
  final String description;
  final String imagePath;
  final List<Ingredient> ingredients;

  const DetailPage({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.ingredients,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),
            
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                widget.imagePath,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              widget.description,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Ingrendients",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: widget.ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = widget.ingredients[index];
                  return Text(
                    ingredient.name,
                    style: const TextStyle(fontSize: 16),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
