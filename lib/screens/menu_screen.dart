import 'package:flutter/material.dart';

import '../data/sample_menu.dart';
import '../models/menu_item.dart';
import '../state/cart.dart';
import 'cart_screen.dart';
import 'theme.dart';

class MenuScreen extends StatefulWidget {
  final Cart cart;
  const MenuScreen({super.key, required this.cart});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _category = 'Chicken';

  List<String> get _categories =>
      sampleMenu.map((m) => m.category).toSet().toList();

  @override
  Widget build(BuildContext context) {
    final items = sampleMenu.where((m) => m.category == _category).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dolebee Fried Chicken', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Poblacion, Hinunangan · Open until 9 PM', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final c in _categories)
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
                        builder: (_) => CartScreen(cart: widget.cart))),
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
