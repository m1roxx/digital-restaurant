import 'package:digital_restaurant/widgets/dish_tile.dart';
import 'package:digital_restaurant/models/dish.dart';
import 'package:digital_restaurant/pages/detail_page.dart';
import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  MenuPage({super.key});

  final List<Dish> dishes = [
    Dish(
      title: "Farm Beef",
      price: "\$15",
      description: "Farm Beef with Zucchini is a hearty dish featuring tender beef slices and fresh zucchini, cooked together in a savory sauce. The beef is slow-cooked for rich flavor, while the zucchini adds a light, fresh touch.",
      shortDescription: "Tender beef with fresh zucchini",
      imagePath: "images/farm_beef.jpeg",
    ),
    Dish(
      title: "Lemon Chicken",
      price: "\$14",
      description: "Lemon Chicken is a flavorful dish featuring tender chicken cooked in a zesty lemon sauce. The citrusy tang enhances the juicy chicken, creating a perfect balance of freshness and richness.",
      shortDescription: "Zesty chicken with lemon sauce",
      imagePath: "images/lemon_chicken.jpeg",
    ),
    Dish(
      title: "Chicken Schnitzel",
      price: "\$13",
      description: "Chicken Schnitzel is a crispy, golden-fried dish made from tender chicken breast, coated in breadcrumbs and pan-fried to perfection. Crunchy on the outside and juicy on the inside.",
      shortDescription: "Crispy breaded chicken breast",
      imagePath: "images/chicken_schnitzel.jpeg",
    ),
    Dish(
      title: "Julienne",
      price: "\$12",
      description: "Julienne is a creamy baked dish made with mushrooms, chicken, and cheese. The tender chicken and sautéed mushrooms are mixed in a rich, velvety sauce and topped with golden, melted cheese.",
      shortDescription: "Creamy mushrooms with chicken",
      imagePath: "images/julienne.jpeg",
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
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
                    builder: (context) => DetailPage(
                      dish: dish,
                    ),
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
      ),
    );
  }
}