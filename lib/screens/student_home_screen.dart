import 'package:flutter/material.dart';

import '../models/food_item.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../widgets/food_card.dart';
import 'food_detail_screen.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  List<FoodItem> _foods = [];
  bool _loading = true;
  String _name = '';

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

    if (mounted && result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to load menu')),
      );
    }
  }

  Future<void> _logout() async {
    await SessionService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JomEat Student Menu'),
        actions: [
          IconButton(
            tooltip: 'Order History',
            icon: const Icon(Icons.receipt_long),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Hi $_name, choose your cafeteria meal.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  ..._foods.map(
                    (food) => FoodCard(
                      food: food,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FoodDetailScreen(foodId: food.foodId),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
