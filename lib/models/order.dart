class FoodOrder {
  final int orderId;
  final int userId;
  final int foodId;
  final String foodName;
  final int quantity;
  final double totalPrice;
  final String notes;
  final String status;
  final String orderDate;

  FoodOrder({
    required this.orderId,
    required this.userId,
    required this.foodId,
    required this.foodName,
    required this.quantity,
    required this.totalPrice,
    required this.notes,
    required this.status,
    required this.orderDate,
  });

  factory FoodOrder.fromJson(Map<String, dynamic> json) {
    return FoodOrder(
      orderId: int.parse(json['order_id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      foodId: int.parse(json['food_id'].toString()),
      foodName: json['food_name'] ?? json['name'] ?? '',
      quantity: int.parse(json['quantity'].toString()),
      totalPrice: double.parse(json['total_price'].toString()),
      notes: json['notes'] ?? '',
      status: json['status'] ?? '',
      orderDate: json['order_date'] ?? '',
    );
  }
}
