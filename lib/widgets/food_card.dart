import 'package:flutter/material.dart';

import '../config.dart';
import '../models/food_item.dart';

class FoodCard extends StatelessWidget {
  final FoodItem food;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool showPriceInSubtitle;

  const FoodCard({
    super.key,
    required this.food,
    required this.onTap,
    this.trailing,
    this.showPriceInSubtitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = food.availability.toLowerCase() == 'available';

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: food.imageName.isEmpty
              ? Container(
                  width: 64,
                  height: 64,
                  color: const Color(0xFFFFE3D2),
                  child: const Icon(Icons.fastfood, color: Color(0xFFE66A2C)),
                )
              : Image.network(
                  AppConfig.foodImageUrl(food.imageName),
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 64,
                    height: 64,
                    color: const Color(0xFFFFE3D2),
                    child: const Icon(
                      Icons.broken_image,
                      color: Color(0xFFE66A2C),
                    ),
                  ),
                ),
        ),
        title: Text(
          food.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                showPriceInSubtitle
                    ? '${food.category} | RM${food.price.toStringAsFixed(2)}'
                    : food.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
        trailing:
            trailing ??
            Text(
              'RM${food.price.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
      ),
    );
  }
}
