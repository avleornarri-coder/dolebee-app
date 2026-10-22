import 'package:flutter/material.dart';

/// Placeholder entry screen. Login routes each user to the customer, owner,
/// or delivery staff screens once Firebase Auth is connected.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dolebee Fried Chicken')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Order crispy fried chicken, delivered in Hinunangan.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
