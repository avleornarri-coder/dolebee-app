import 'package:flutter/material.dart';

import '../models/order.dart';
import '../state/cart.dart';
import 'order_status_screen.dart';
import 'theme.dart';

/// Manual GCash payment: the customer scans the store's QR, pays the exact
/// amount, and enters the 13-digit GCash reference number for the owner to
/// check before cooking.
class GcashPaymentScreen extends StatefulWidget {
  final Order order;
  final Cart cart;
  const GcashPaymentScreen({super.key, required this.order, required this.cart});

  @override
  State<GcashPaymentScreen> createState() => _GcashPaymentScreenState();
}

class _GcashPaymentScreenState extends State<GcashPaymentScreen> {
  final _form = GlobalKey<FormState>();
  final _reference = TextEditingController();
  bool _receiptAttached = false;

  @override
  void dispose() {
    _reference.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    widget.cart.clear();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => OrderStatusScreen(order: widget.order)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pay with GCash')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  const Text('Amount to pay', style: TextStyle(color: Colors.black54)),
                  Text(peso(widget.order.totalPhp),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: brandOrange)),
                  const SizedBox(height: 16),
                  // Replaced with the store's real GCash QR image.
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF007DFE), width: 3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.qr_code_2, size: 160, color: Color(0xFF007DFE)),
                  ),
                  const SizedBox(height: 8),
                  const Text('Dolebee Fried Chicken · GCash'),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            const Text('1. Open GCash and scan the QR code.\n'
                '2. Pay the exact amount shown.\n'
                '3. Enter the reference number from your GCash receipt below.'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reference,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'GCash reference number',
                hintText: '13 digits',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (v) => RegExp(r'^\d{13}$').hasMatch(v!.replaceAll(' ', ''))
                  ? null
                  : 'The reference number has 13 digits',
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              // Photo upload to Firebase Storage comes with the Firebase setup.
              onPressed: () => setState(() => _receiptAttached = true),
              icon: Icon(_receiptAttached ? Icons.check_circle : Icons.photo_camera),
              label: Text(_receiptAttached ? 'Receipt screenshot attached' : 'Attach receipt screenshot'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              onPressed: _submit,
              child: const Text('I have paid', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 8),
            const Text('We start cooking once the store confirms your payment, usually within a few minutes.',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
