import 'package:flutter/material.dart';

import '../models/order.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import 'edit_order_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<FoodOrder> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final userId = await SessionService.getUserId();
    if (userId == null) return;
    final result = await ApiService.getOrders(userId);
    final data = result['success'] == true ? result['data'] as List : [];
    setState(() {
      _orders = data.map((item) => FoodOrder.fromJson(item)).toList();
      _loading = false;
    });
  }

  Future<void> _cancel(FoodOrder order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel order?'),
        content: Text('Cancel ${order.foodName}?'),
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
    final result = await ApiService.cancelOrder(order.orderId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Cancel finished')),
    );
    _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadOrders,
              child: _orders.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(child: Text('No orders yet')),
                      ],
                    )
                  : ListView.builder(
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        final canEdit = order.status == 'Pending';
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.foodName,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text('Quantity: ${order.quantity}'),
                                Text(
                                  'Total: RM${order.totalPrice.toStringAsFixed(2)}',
                                ),
                                Text('Status: ${order.status}'),
                                Text('Date: ${order.orderDate}'),
                                if (order.notes.isNotEmpty)
                                  Text('Notes: ${order.notes}'),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.edit),
                                      label: const Text('Edit quantity'),
                                      onPressed: canEdit
                                          ? () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      EditOrderScreen(
                                                        order: order,
                                                      ),
                                                ),
                                              );
                                              _loadOrders();
                                            }
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.cancel),
                                      label: const Text('Cancel'),
                                      onPressed: canEdit
                                          ? () => _cancel(order)
                                          : null,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
