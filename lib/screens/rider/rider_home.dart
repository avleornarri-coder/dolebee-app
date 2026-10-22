import 'package:flutter/material.dart';

import '../../models/order.dart';
import '../../state/app_store.dart';
import '../theme.dart';

/// Delivery staff view: orders handed to this staff member, with the
/// customer's address and phone, and buttons to finish each delivery.
class RiderHome extends StatelessWidget {
  final AppStore store;
  final Rider rider;
  const RiderHome({super.key, required this.store, required this.rider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Deliveries · ${rider.name}')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final orders = store.ordersForRider(rider.id);
          if (orders.isEmpty) {
            return const Center(
              child: Text('No deliveries assigned to you right now.',
                  style: TextStyle(color: Colors.black54)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _DeliveryCard(store: store, order: orders[i]),
          );
        },
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final AppStore store;
  final Order order;
  const _DeliveryCard({required this.store, required this.order});

  @override
  Widget build(BuildContext context) {
    final cod = order.payment == PaymentMethod.cashOnDelivery;
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.person, size: 18, color: Colors.black54),
            const SizedBox(width: 6),
            Text('${order.customerName} · ${order.customerId}'),
          ]),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.place, size: 18, color: Colors.black54),
            const SizedBox(width: 6),
            Expanded(
              child: Text('${order.address}${order.landmark.isEmpty ? '' : '\n${order.landmark}'}'),
            ),
          ]),
          const Divider(),
          for (final line in order.lines) Text('${line.quantity} × ${line.name}'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (cod ? Colors.green : Colors.blue).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              cod ? 'Collect ${peso(order.totalPhp)} cash' : 'Paid by GCash · collect nothing',
              style: TextStyle(fontWeight: FontWeight.bold, color: cod ? Colors.green[800] : Colors.blue[800]),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            onPressed: () => store.markDelivered(order.id, cashReceived: cod),
            child: Text(cod ? 'Delivered, cash received' : 'Delivered'),
          ),
        ]),
      ),
    );
  }
}
