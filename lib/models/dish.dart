import 'package:digital_restaurant/models/ingredient.dart';

class Dish {
  final String title;
  final String shortDescription;
  final String description;
  final String imagePath;
  final List<Ingredient> ingredients;

  Dish({
    required this.title,
    required this.shortDescription,
    required this.description,
    required this.imagePath,
    required this.ingredients,
  });
}