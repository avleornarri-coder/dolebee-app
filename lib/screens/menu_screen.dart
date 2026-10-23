import 'package:flutter/material.dart';

import '../models/menu_item.dart';
import '../models/order.dart';
import '../state/app_store.dart';
import '../state/cart.dart';
import 'cart_screen.dart';
import 'my_orders_screen.dart';
import 'order_status_screen.dart';
import 'theme.dart';

class MenuScreen extends StatefulWidget {
  final AppStore store;
  final Cart cart;

  /// Opens the owner and delivery staff login; only on phones with Firebase.
  final VoidCallback? onStaffLogin;
  const MenuScreen({super.key, required this.store, required this.cart, this.onStaffLogin});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _category = 'Chicken';

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: widget.store,
        builder: (context, _) => _build(context),
      );

  Widget _build(BuildContext context) {
    final categories = widget.store.categories;
    if (!categories.contains(_category) && categories.isNotEmpty) _category = categories.first;
    final items = widget.store.menu.where((m) => m.category == _category).toList();
    final active = widget.store.customerActiveOrders;
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dolebee Fried Chicken', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Poblacion, Hinunangan · Open until 9 PM', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'My orders',
            icon: Badge(
              isLabelVisible: active.isNotEmpty,
              label: Text('${active.length}'),
              child: const Icon(Icons.receipt_long),
            ),
            onPressed: () => _openMyOrders(context),
          ),
          if (widget.onStaffLogin != null)
            PopupMenuButton<void>(
              tooltip: 'More',
              itemBuilder: (_) => [
                PopupMenuItem(onTap: widget.onStaffLogin, child: const Text('Staff login')),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          if (active.isNotEmpty) _ActiveOrderBanner(store: widget.store, order: active.first),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final c in categories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: c == _category,
                      onSelected: (_) => setState(() => _category = c),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: widget.cart,
              builder: (context, _) => ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) => _MenuCard(item: items[i], cart: widget.cart),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: ListenableBuilder(
        listenable: widget.cart,
        builder: (context, _) => widget.cart.isEmpty
            ? const SizedBox.shrink()
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: FilledButton(
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => CartScreen(store: widget.store, cart: widget.cart))),
                    child: Text(
                      'View cart · ${widget.cart.itemCount} items · ${peso(widget.cart.subtotalPhp)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  void _openMyOrders(BuildContext context) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => MyOrdersScreen(store: widget.store)));
}

/// Shows the customer's latest order in progress so they can get back to
/// its status at any time.
class _ActiveOrderBanner extends StatelessWidget {
  final AppStore store;
  final Order order;
  const _ActiveOrderBanner({required this.store, required this.order});

  @override
  Widget build(BuildContext context) => Material(
        color: brandOrange.withValues(alpha: 0.12),
        child: InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => OrderStatusScreen(store: store, orderId: order.id))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              const Icon(Icons.delivery_dining, color: brandOrange),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Order ${order.id}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(customerStatusLabel(order.status)),
                ]),
              ),
              const Text('View status', style: TextStyle(color: brandOrange, fontWeight: FontWeight.w600)),
              const Icon(Icons.chevron_right, color: brandOrange),
            ]),
          ),
        ),
      );
}

class _MenuCard extends StatelessWidget {
  final MenuItem item;
  final Cart cart;
  const _MenuCard({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    final qty = cart.quantityOf(item.id);
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: brandOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconForCategory(item.category), color: brandOrange, size: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(item.soldOut ? 'Sold out today' : peso(item.pricePhp),
                      style: TextStyle(color: item.soldOut ? Colors.grey : brandOrange)),
                ],
              ),
            ),
            if (!item.soldOut)
              qty == 0
                  ? IconButton.filled(
                      tooltip: 'Add ${item.name}',
                      onPressed: () => cart.add(item),
                      icon: const Icon(Icons.add),
                    )
                  : Row(children: [
                      IconButton(onPressed: () => cart.remove(item), icon: const Icon(Icons.remove)),
                      Text('$qty', style: const TextStyle(fontSize: 16)),
                      IconButton(onPressed: () => cart.add(item), icon: const Icon(Icons.add)),
                    ]),
          ],
        ),
      ),
    );
  }
}
