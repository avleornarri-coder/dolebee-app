import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/order.dart';
import '../../state/app_store.dart';
import '../theme.dart';

/// Owner's live order board: confirm GCash payments, start cooking, and
/// hand orders to delivery staff.
class OrdersScreen extends StatelessWidget {
  final AppStore store;
  const OrdersScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final orders = store.activeOrders;
          if (orders.isEmpty) {
            return const Center(
              child: Text('No orders right now.\nNew orders appear here with a sound.',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _OrderCard(store: store, order: orders[i]),
          );
        },
      ),
    );
  }
}

const _statusLabels = {
  OrderStatus.awaitingPayment: ('Check GCash', Colors.blue),
  OrderStatus.received: ('New', Colors.red),
  OrderStatus.cooking: ('Cooking', brandOrange),
  OrderStatus.outForDelivery: ('Out for delivery', Colors.green),
};

class _OrderCard extends StatelessWidget {
  final AppStore store;
  final Order order;
  const _OrderCard({required this.store, required this.order});

  @override
  Widget build(BuildContext context) {
    final (label, color) = _statusLabels[order.status]!;
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(DateFormat.jm().format(order.createdAt),
                  overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 8),
          for (final line in order.lines) Text('${line.quantity} × ${line.name}'),
          const SizedBox(height: 6),
          Text('${peso(order.totalPhp)} · '
              '${order.payment == PaymentMethod.gcashQr ? 'GCash' : 'Cash on delivery'}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('${order.customerName} · ${order.customerId}'),
          Text('${order.address}${order.landmark.isEmpty ? '' : ' (${order.landmark})'}',
              style: const TextStyle(color: Colors.black54)),
          if (order.gcashReference != null) ...[
            const SizedBox(height: 6),
            Text('GCash ref: ${order.gcashReference}'
                '${order.receiptPhotoUrl != null ? ' · receipt attached' : ''}',
                style: const TextStyle(color: Colors.blue)),
          ],
          const SizedBox(height: 10),
          ..._actions(context),
        ]),
      ),
    );
  }

  List<Widget> _actions(BuildContext context) {
    switch (order.status) {
      case OrderStatus.awaitingPayment:
        return [
          const Text('Check that this reference and amount are in your GCash history.',
              style: TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => store.setStatus(order.id, OrderStatus.cancelled),
                child: const Text('Not received'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: () => store.setStatus(order.id, OrderStatus.received),
                child: const Text('Payment confirmed'),
              ),
            ),
          ]),
        ];
      case OrderStatus.received:
        return [
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => store.setStatus(order.id, OrderStatus.cancelled),
                child: const Text('Reject'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: () => store.setStatus(order.id, OrderStatus.cooking),
                child: const Text('Start cooking'),
              ),
            ),
          ]),
        ];
      case OrderStatus.cooking:
        return [
          const Text('Ready? Send out with:'),
          const SizedBox(height: 6),
          Wrap(spacing: 8, children: [
            for (final rider in store.riders)
              FilledButton.tonalIcon(
                onPressed: () => store.sendOut(order.id, rider.id),
                icon: const Icon(Icons.delivery_dining),
                label: Text(rider.name),
              ),
          ]),
        ];
      case OrderStatus.outForDelivery:
        return [Text('With ${store.riderName(order.riderId)}')];
      default:
        return const [];
    }
  }
}
