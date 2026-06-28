import 'package:flutter/material.dart';

class CartOrderScreen extends StatelessWidget {
  const CartOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart Order')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'JomEat places one pre-order at a time from the food detail screen.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
