import 'package:flutter/material.dart';

import '../models/food_item.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../widgets/food_card.dart';
import 'admin_menu_screen.dart';
import 'login_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  List<FoodItem> _foods = [];
  bool _loading = true;
  String _name = '';
  int? _deletingFoodId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final name = await SessionService.getUserName();
    final result = await ApiService.getMenu();
    final data = result['success'] == true ? result['data'] as List : [];

    setState(() {
      _name = name;
      _foods = data.map((item) => FoodItem.fromJson(item)).toList();
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await SessionService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _openMenuForm({FoodItem? food}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AdminMenuScreen(initialFood: food)),
    );
    _loadData();
  }

  Future<void> _confirmDelete(FoodItem food) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Delete ${food.name} from the menu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted || shouldDelete != true) return;
    await _deleteFood(food);
  }

  Future<void> _deleteFood(FoodItem food) async {
    setState(() => _deletingFoodId = food.foodId);
    final result = await ApiService.adminDeleteFood(food.foodId);

    if (!mounted) return;
    setState(() => _deletingFoodId = null);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Delete finished')),
    );

    if (result['success'] == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JomEat Admin Home'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openMenuForm,
        icon: const Icon(Icons.add),
        label: const Text('Create Item'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  Text(
                    'Hi $_name, Welcome to JomEat Admin Panel',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          label: 'Current Menu Items',
                          value: _foods.length.toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Current Menu Preview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ..._foods.map((food) {
                    final deleting = _deletingFoodId == food.foodId;
                    return FoodCard(
                      food: food,
                      onTap: () => _openMenuForm(food: food),
                      showPriceInSubtitle: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Edit item',
                            icon: const Icon(Icons.edit),
                            onPressed: deleting
                                ? null
                                : () => _openMenuForm(food: food),
                          ),
                          IconButton(
                            tooltip: 'Delete item',
                            icon: deleting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: deleting
                                ? null
                                : () => _confirmDelete(food),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;

  const _InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
