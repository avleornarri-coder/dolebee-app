import 'package:flutter/material.dart';

import '../models/order.dart';
import 'theme.dart';

/// Live order progress. Status changes come from the owner and delivery
/// staff apps once orders are stored in Firestore.
class OrderStatusScreen extends StatelessWidget {
  final Order order;
  const OrderStatusScreen({super.key, required this.order});

  static const _steps = [
    (OrderStatus.awaitingPayment, 'Checking GCash payment', Icons.account_balance_wallet),
    (OrderStatus.received, 'Order received', Icons.receipt_long),
    (OrderStatus.cooking, 'Frying your chicken', Icons.local_fire_department),
    (OrderStatus.outForDelivery, 'On the way', Icons.delivery_dining),
    (OrderStatus.delivered, 'Delivered', Icons.check_circle),
  ];

  @override
  Widget build(BuildContext context) {
    final steps = order.payment == PaymentMethod.gcashQr
        ? _steps
        : _steps.where((s) => s.$1 != OrderStatus.awaitingPayment).toList();
    final current = steps.indexWhere((s) => s.$1 == order.status);
    return Scaffold(
      appBar: AppBar(title: Text('Order ${order.id}'), automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                for (var i = 0; i < steps.length; i++)
                  ListTile(
                    leading: Icon(steps[i].$3,
                        color: i <= current ? brandOrange : Colors.black26, size: 32),
                    title: Text(steps[i].$2,
                        style: TextStyle(
                          fontWeight: i == current ? FontWeight.bold : FontWeight.normal,
                          color: i <= current ? Colors.black87 : Colors.black38,
                        )),
                    trailing: i == current ? const Text('Now', style: TextStyle(color: brandOrange)) : null,
                  ),
              ]),
            ),
          ),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (final line in order.lines) Text('${line.quantity} × ${line.name}'),
                const Divider(),
                Text('Total ${peso(order.totalPhp)} · '
                    '${order.payment == PaymentMethod.gcashQr ? 'GCash' : 'Cash on delivery'}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Deliver to ${order.address}${order.landmark.isEmpty ? '' : ' (${order.landmark})'}'),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
