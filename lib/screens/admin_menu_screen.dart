import 'package:flutter/material.dart';

import '../models/food_item.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _prepController = TextEditingController();
  String _availability = 'Available';
  List<FoodItem> _foods = [];
  FoodItem? _selectedFood;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _prepController.dispose();
    super.dispose();
  }

  Future<void> _loadFoods() async {
    final result = await ApiService.getMenu();
    final data = result['success'] == true ? result['data'] as List : [];
    setState(() {
      _foods = data.map((item) => FoodItem.fromJson(item)).toList();
      _loading = false;
    });
  }

  void _fillForm(FoodItem food) {
    setState(() {
      _selectedFood = food;
      _nameController.text = food.name;
      _descriptionController.text = food.description;
      _categoryController.text = food.category;
      _priceController.text = food.price.toStringAsFixed(2);
      _prepController.text = food.preparationTime.toString();
      _availability = food.availability;
    });
  }

  void _clearForm() {
    setState(() {
      _selectedFood = null;
      _nameController.clear();
      _descriptionController.clear();
      _categoryController.clear();
      _priceController.clear();
      _prepController.clear();
      _availability = 'Available';
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final selected = _selectedFood;
    final result = selected == null
        ? await ApiService.adminAddFood(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _categoryController.text.trim(),
            price: _priceController.text.trim(),
            preparationTime: _prepController.text.trim(),
            availability: _availability,
          )
        : await ApiService.adminUpdateFood(
            foodId: selected.foodId,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _categoryController.text.trim(),
            price: _priceController.text.trim(),
            preparationTime: _prepController.text.trim(),
            availability: _availability,
          );
    setState(() => _saving = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Save finished')),
    );
    if (result['success'] == true) {
      _clearForm();
      _loadFoods();
    }
  }

  Future<void> _delete(FoodItem food) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete food item?'),
        content: Text('Delete ${food.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final result = await ApiService.adminDeleteFood(food.foodId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Delete finished')),
    );
    _clearForm();
    _loadFoods();
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'Required' : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Menu')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 780;
                final form = _buildForm();
                final list = _buildFoodList();
                return wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: form),
                          Expanded(child: list),
                        ],
                      )
                    : ListView(children: [form, list]);
              },
            ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedFood == null ? 'Add Food Item' : 'Update Food Item',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: _required,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              validator: _required,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final price = double.tryParse(value ?? '');
                      if (price == null || price <= 0) return 'Invalid price';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _prepController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Prep minutes',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final minutes = int.tryParse(value ?? '');
                      if (minutes == null || minutes < 0) return 'Invalid time';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              key: ValueKey(_availability),
              initialValue: _availability,
              decoration: const InputDecoration(
                labelText: 'Availability',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Available', child: Text('Available')),
                DropdownMenuItem(
                  value: 'Unavailable',
                  child: Text('Unavailable'),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _availability = value ?? 'Available'),
            ),
            const SizedBox(height: 14),
            _saving
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(
                    text: _selectedFood == null ? 'Add Food' : 'Update Food',
                    icon: Icons.save,
                    onPressed: _save,
                  ),
            if (_selectedFood != null)
              TextButton.icon(
                onPressed: _clearForm,
                icon: const Icon(Icons.add),
                label: const Text('Clear form for new item'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodList() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Existing Menu',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ..._foods.map(
            (food) => Card(
              child: ListTile(
                title: Text(food.name),
                subtitle: Text(
                  '${food.category} | RM${food.price.toStringAsFixed(2)} | ${food.availability}',
                ),
                onTap: () => _fillForm(food),
                trailing: IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete),
                  onPressed: () => _delete(food),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
