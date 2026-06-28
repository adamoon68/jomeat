import 'package:flutter/material.dart';

import '../models/food_item.dart';

class FoodCard extends StatelessWidget {
  final FoodItem food;
  final VoidCallback onTap;

  const FoodCard({super.key, required this.food, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isAvailable = food.availability.toLowerCase() == 'available';

    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(
          food.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(food.category),
              const SizedBox(height: 4),
              Text(
                food.availability,
                style: TextStyle(
                  color: isAvailable ? Colors.green.shade700 : Colors.red,
                ),
              ),
            ],
          ),
        ),
        trailing: Text(
          'RM${food.price.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
