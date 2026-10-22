import 'package:flutter/material.dart';

import '../models/order.dart';
import '../state/app_store.dart';
import 'theme.dart';

/// What the customer sees for each order status.
String customerStatusLabel(OrderStatus status) => switch (status) {
      OrderStatus.awaitingPayment => 'Checking GCash payment',
      OrderStatus.received => 'Order received',
      OrderStatus.cooking => 'Frying your chicken',
      OrderStatus.outForDelivery => 'On the way',
      OrderStatus.delivered => 'Delivered',
      OrderStatus.cancelled => 'Cancelled',
    };

/// Live order progress, updated as the owner and delivery staff move the
/// order along.
class OrderStatusScreen extends StatelessWidget {
  final AppStore store;
  final String orderId;
  const OrderStatusScreen({super.key, required this.store, required this.orderId});

  static const _steps = [
    (OrderStatus.awaitingPayment, 'Checking GCash payment', Icons.account_balance_wallet),
    (OrderStatus.received, 'Order received', Icons.receipt_long),
    (OrderStatus.cooking, 'Frying your chicken', Icons.local_fire_department),
    (OrderStatus.outForDelivery, 'On the way', Icons.delivery_dining),
    (OrderStatus.delivered, 'Delivered', Icons.check_circle),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final order = store.orderById(orderId)!;
        final steps = order.payment == PaymentMethod.gcashQr
            ? _steps
            : _steps.where((s) => s.$1 != OrderStatus.awaitingPayment).toList();
        final current = steps.indexWhere((s) => s.$1 == order.status);
        return Scaffold(
          appBar: AppBar(
            title: Text('Order ${order.id}'),
            leading: IconButton(
              tooltip: 'Back to menu',
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: order.status == OrderStatus.cancelled
                      ? const ListTile(
                          leading: Icon(Icons.cancel, color: Colors.red, size: 32),
                          title: Text('Order cancelled'),
                          subtitle: Text('The store could not accept this order. '
                              'If you paid by GCash, they will contact you about a refund.'),
                        )
                      : Column(children: [
                          for (var i = 0; i < steps.length; i++)
                            ListTile(
                              leading: Icon(steps[i].$3,
                                  color: i <= current ? brandOrange : Colors.black26, size: 32),
                              title: Text(steps[i].$2,
                                  style: TextStyle(
                                    fontWeight: i == current ? FontWeight.bold : FontWeight.normal,
                                    color: i <= current ? Colors.black87 : Colors.black38,
                                  )),
                              trailing: i == current
                                  ? const Text('Now', style: TextStyle(color: brandOrange))
                                  : null,
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
      },
    );
  }
}
