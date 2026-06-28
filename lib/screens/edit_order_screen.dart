import 'package:flutter/material.dart';

import '../models/order.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';

class EditOrderScreen extends StatefulWidget {
  final FoodOrder order;

  const EditOrderScreen({super.key, required this.order});

  @override
  State<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  late final TextEditingController _notesController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.order.quantity.toString(),
    );
    _notesController = TextEditingController(text: widget.order.notes);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final result = await ApiService.updateOrder(
      orderId: widget.order.orderId,
      quantity: int.parse(_quantityController.text),
      notes: _notesController.text.trim(),
    );
    setState(() => _loading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Update finished')),
    );
    if (result['success'] == true) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Order')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.order.foodName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final quantity = int.tryParse(value ?? '');
                  if (quantity == null || quantity < 1) {
                    return 'Enter valid quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 18),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      text: 'Save Changes',
                      icon: Icons.save,
                      onPressed: _save,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
