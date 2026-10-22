import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/daily_sales.dart';
import '../../state/app_store.dart';
import '../theme.dart';

/// Today's sales at a glance: totals, GCash vs cash, cash each delivery
/// staff member should hand over, and best sellers.
class SalesScreen extends StatelessWidget {
  final AppStore store;
  const SalesScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: Text('Sales · ${DateFormat('EEE, MMM d').format(today)}')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final sales = store.salesOn(today);
          final best = sales.quantityByItem.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                color: brandOrange,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Today\'s sales', style: TextStyle(color: Colors.white70)),
                    Text(peso(sales.totalPhp),
                        style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                    Text('${sales.orderCount} delivered ${sales.orderCount == 1 ? 'order' : 'orders'}',
                        style: const TextStyle(color: Colors.white)),
                  ]),
                ),
              ),
              if (sales.pendingCount > 0)
                Card(
                  color: Colors.white,
                  child: ListTile(
                    leading: const Icon(Icons.hourglass_top, color: brandOrange),
                    title: Text('${sales.pendingCount} ${sales.pendingCount == 1 ? 'order' : 'orders'} '
                        '(${peso(sales.pendingPhp)}) not delivered yet'),
                    subtitle: const Text('Added to today\'s sales once marked delivered.'),
                  ),
                ),
              Row(children: [
                Expanded(child: _Tile(label: 'GCash', value: peso(sales.gcashPhp), color: Colors.blue)),
                Expanded(child: _Tile(label: 'Cash on delivery', value: peso(sales.codPhp), color: Colors.green)),
              ]),
              _Section(
                title: 'Cash from delivery staff',
                children: [
                  const Text('Tap "Received" when the cash is in your hands.',
                      style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 4),
                  for (final rider in store.riders) _cashRow(rider, sales),
                ],
              ),
              _Section(
                title: 'Best sellers',
                children: [
                  if (best.isEmpty)
                    const Text('Shows once orders are delivered.', style: TextStyle(color: Colors.black54)),
                  for (final e in best.take(5)) _line(e.key, '${e.value} sold'),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _cashRow(Rider rider, DailySales sales) {
    final onHand = store.cashOnHand(rider.id);
    final collected = sales.cashCollectedByRider[rider.id] ?? 0;
    final remitted = sales.cashRemittedByRider[rider.id] ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(rider.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            Text('Collected today ${peso(collected)} · handed over ${peso(remitted)}',
                style: const TextStyle(color: Colors.black54)),
          ]),
        ),
        if (onHand > 0)
          FilledButton(
            onPressed: () => store.remitCash(rider.id),
            child: Text('Received ${peso(onHand)}'),
          )
        else
          const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.check_circle, color: Colors.green, size: 18),
            SizedBox(width: 4),
            Text('Nothing to hand over', style: TextStyle(color: Colors.green)),
          ]),
      ]),
    );
  }

  Widget _line(String left, String right) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(left, style: const TextStyle(fontSize: 15))),
          Text(right, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ]),
      );
}

class _Tile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Tile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ]),
        ),
      );
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...children,
          ]),
        ),
      );
}
