class Dish {
  final String? id;
  final String title;
  final int price;
  final String description;
  final String imagePath;
  final String shortDescription;
  final String category; 

  Dish({
    this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.imagePath,
    required this.shortDescription,
    required this.category,
  });

  factory Dish.fromFirestore(Map<String, dynamic> data, String id) {
    return Dish(
      id: id,
      title: data['title'] ?? '',
      price: data['price'] ?? 0,
      description: data['description'] ?? '',
      imagePath: data['imagePath'] ?? '',
      shortDescription: data['shortDescription'] ?? '',
      category: data['category'] ?? '',
    );
  }
}