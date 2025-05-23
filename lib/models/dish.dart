class Dish {
  final String? id;
  final String title;
  final int price;
  final String description;
  final String imagePath;
  final String shortDescription;
  final String category;
  final double averageRating;
  final int reviewCount;

  Dish({
    this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.imagePath,
    required this.shortDescription,
    required this.category,
    this.averageRating = 0.0,
    this.reviewCount = 0,
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
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'price': price,
      'description': description,
      'imagePath': imagePath,
      'shortDescription': shortDescription,
      'category': category,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
    };
  }
}