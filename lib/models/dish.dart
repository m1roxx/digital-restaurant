class Dish {
  final String? id;
  final String title;
  final int price;
  final String description;
  final String imagePath;
  final String shortDescription;
  
  Dish({
    this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.imagePath,
    required this.shortDescription,
  });
}