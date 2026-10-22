import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/order.dart';
import '../state/app_store.dart';
import 'order_status_screen.dart';
import 'theme.dart';

/// The customer's past and current orders; tapping one opens its status.
class MyOrdersScreen extends StatelessWidget {
  final AppStore store;
  const MyOrdersScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final orders = store.customerOrders;
          if (orders.isEmpty) {
            return const Center(
              child: Text('Your orders will appear here.', style: TextStyle(color: Colors.black54)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final order = orders[i];
              final done = order.status == OrderStatus.delivered || order.status == OrderStatus.cancelled;
              return Card(
                color: Colors.white,
                child: ListTile(
                  title: Text('Order ${order.id} · ${peso(order.totalPhp)}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${DateFormat('MMM d, h:mm a').format(order.createdAt)}\n'
                      '${order.lines.map((l) => '${l.quantity} × ${l.name}').join(', ')}'),
                  isThreeLine: true,
                  trailing: Text(customerStatusLabel(order.status),
                      style: TextStyle(
                        color: done ? Colors.black54 : brandOrange,
                        fontWeight: FontWeight.w600,
                      )),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => OrderStatusScreen(store: store, orderId: order.id))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
