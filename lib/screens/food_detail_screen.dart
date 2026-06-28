import 'package:flutter/material.dart';

import '../models/food_item.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../widgets/custom_button.dart';

class FoodDetailScreen extends StatefulWidget {
  final int foodId;

  const FoodDetailScreen({super.key, required this.foodId});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  FoodItem? _food;
  int _quantity = 1;
  bool _loading = true;
  bool _ordering = false;

  @override
  void initState() {
    super.initState();
    _loadFood();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadFood() async {
    final result = await ApiService.getFoodDetail(widget.foodId);
    if (mounted) {
      setState(() {
        _food = result['success'] == true
            ? FoodItem.fromJson(result['data'])
            : null;
        _loading = false;
      });
      if (result['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Food not found')),
        );
      }
    }
  }

  Future<void> _order() async {
    if (!_formKey.currentState!.validate() || _food == null) return;
    final userId = await SessionService.getUserId();
    if (userId == null) return;
    setState(() => _ordering = true);
    final result = await ApiService.addOrder(
      userId: userId,
      foodId: _food!.foodId,
      quantity: _quantity,
      notes: _notesController.text.trim(),
    );
    setState(() => _ordering = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Order finished')),
    );
    if (result['success'] == true) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final food = _food;
    return Scaffold(
      appBar: AppBar(title: const Text('Food Detail')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : food == null
          ? const Center(child: Text('Food item not found'))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Text(
                    food.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(food.description),
                  const SizedBox(height: 16),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Category: ${food.category}'),
                          Text('Price: RM${food.price.toStringAsFixed(2)}'),
                          Text('Preparation: ${food.preparationTime} minutes'),
                          Text('Availability: ${food.availability}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Text('Quantity'),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                      ),
                      Text('$_quantity', style: const TextStyle(fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Order notes, for example less spicy',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 18),
                  _ordering
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButton(
                          text: 'Pre-order',
                          icon: Icons.shopping_bag,
                          onPressed: food.availability == 'Available'
                              ? _order
                              : null,
                        ),
                ],
              ),
            ),
    );
  }
}
