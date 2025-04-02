import 'package:digital_restaurant/widgets/dish_tile.dart';
import 'package:digital_restaurant/models/dish.dart';
import 'package:digital_restaurant/models/ingredient.dart';
import 'package:digital_restaurant/pages/detail_page.dart';
import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  MenuPage({super.key});

  final List<Dish> dishes = [
    Dish(
      title: "Julienne",
      shortDescription: "Baked mushrooms and chicken in a creamy sauce, topped with golden melted cheese.",
      description: "Julienne is a creamy baked dish made with mushrooms, chicken, and cheese. The tender chicken and sautéed mushrooms are mixed in a rich, velvety sauce and topped with golden, melted cheese.",
      imagePath: "images/julienne.jpeg",
      ingredients: [
        Ingredient(name: 'Mushrooms'),
        Ingredient(name: 'Chicken'),
        Ingredient(name: 'Cheese'),
        Ingredient(name: 'Butter'),
        Ingredient(name: 'Cream'),
      ],
    ),
    Dish(
      title: "Farm Beef with Zucchini",
      shortDescription: "Beef breaded in rice flour and fried with spices.",
      description: "Farm Beef with Zucchini is a hearty dish featuring tender beef slices and fresh zucchini, cooked together in a savory sauce. The beef is slow-cooked for rich flavor, while the zucchini adds a light, fresh touch.",
      imagePath: "images/farm_beef.jpeg",
      ingredients: [
        Ingredient(name: 'Beef'),
        Ingredient(name: 'Zucchini'),
        Ingredient(name: 'Soy Sauce'),
        Ingredient(name: 'Garlic'),
        Ingredient(name: 'Olive Oil'),
      ],
    ),
    Dish(
      title: "Lemon Chicken",
      shortDescription: "Chicken thigh fillet marinated with ginger, honey, Indian spices in hoisin sauce, fried until crispy.",
      description: "Lemon Chicken is a flavorful dish featuring tender chicken cooked in a zesty lemon sauce. The citrusy tang enhances the juicy chicken, creating a perfect balance of freshness and richness.",
      imagePath: "images/lemon_chicken.jpeg",
      ingredients: [
        Ingredient(name: 'Chicken thigh fillet'),
        Ingredient(name: 'Ginger'),
        Ingredient(name: 'Honey'),
        Ingredient(name: 'Hoisin sauce'),
        Ingredient(name: 'Lemon juice'),
      ],
    ),
    Dish(
      title: "Chicken Schnitzel",
      shortDescription: "Tender chicken fillet in a crispy breading, fluffy mashed potatoes.",
      description: "Chicken Schnitzel is a crispy, golden-fried dish made from tender chicken breast, coated in breadcrumbs and pan-fried to perfection. Crunchy on the outside and juicy on the inside.",
      imagePath: "images/chicken_schnitzel.jpeg",
      ingredients: [
        Ingredient(name: 'Chicken Breast'),
        Ingredient(name: 'Breadcrumbs'),
        Ingredient(name: 'Egg'),
        Ingredient(name: 'Flour'),
        Ingredient(name: 'Oil'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: dishes.length,
      itemBuilder: (context, index) {
        final dish = dishes[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPage(
                  title: dish.title,
                  description: dish.description,
                  imagePath: dish.imagePath,
                  ingredients: dish.ingredients,
                ),
              ),
            );
          },
          child: dishTile(
            context,
            dish.title,
            dish.shortDescription,
            dish.imagePath,
          ),
        );
      },
    );
  }
}