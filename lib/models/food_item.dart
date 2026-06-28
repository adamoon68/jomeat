class FoodItem {
  final int foodId;
  final String name;
  final String description;
  final String category;
  final double price;
  final int preparationTime;
  final String availability;
  final String imageName;

  FoodItem({
    required this.foodId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.preparationTime,
    required this.availability,
    required this.imageName,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      foodId: int.parse(json['food_id'].toString()),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: double.parse(json['price'].toString()),
      preparationTime:
          int.tryParse((json['preparation_time'] ?? 0).toString()) ?? 0,
      availability: json['availability'] ?? 'Available',
      imageName: json['image_name'] ?? '',
    );
  }
}
