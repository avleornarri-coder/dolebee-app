import 'package:flutter/material.dart';

import '../../models/order.dart';
import '../../state/app_store.dart';
import '../theme.dart';

/// Delivery staff view: orders handed to this staff member, with the
/// customer's address and phone, and buttons to finish each delivery.
class RiderHome extends StatelessWidget {
  final AppStore store;
  final Rider rider;
  final VoidCallback? onLogout;
  const RiderHome({super.key, required this.store, required this.rider, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deliveries · ${rider.name}'),
        actions: [
          if (onLogout != null)
            IconButton(tooltip: 'Log out', icon: const Icon(Icons.logout), onPressed: onLogout),
        ],
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final orders = store.ordersForRider(rider.id);
          final onHand = store.cashOnHand(rider.id);
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              if (onHand > 0)
                Card(
                  color: Colors.green[50],
                  child: ListTile(
                    leading: const Icon(Icons.payments, color: Colors.green),
                    title: Text('Cash on hand: ${peso(onHand)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Hand this to the owner. It clears once they tap "Received".'),
                  ),
                ),
              if (orders.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Text('No deliveries assigned to you right now.',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
                ),
              for (final order in orders)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _DeliveryCard(store: store, order: order),
                ),
            ],
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
