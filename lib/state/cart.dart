import 'package:flutter/foundation.dart';

import '../models/delivery_zone.dart';
import '../models/menu_item.dart';
import '../models/order.dart';

class Cart extends ChangeNotifier {
  final Map<String, MenuItem> _items = {};
  final Map<String, int> _quantities = {};

  List<MenuItem> get items => _items.values.toList();
  int quantityOf(String itemId) => _quantities[itemId] ?? 0;
  int get itemCount => _quantities.values.fold(0, (a, b) => a + b);
  bool get isEmpty => _quantities.isEmpty;

  int get subtotalPhp => _items.values
      .fold(0, (sum, item) => sum + item.pricePhp * quantityOf(item.id));

  void add(MenuItem item) {
    _items[item.id] = item;
    _quantities[item.id] = quantityOf(item.id) + 1;
    notifyListeners();
  }

  void remove(MenuItem item) {
    final qty = quantityOf(item.id) - 1;
    if (qty <= 0) {
      _items.remove(item.id);
      _quantities.remove(item.id);
    } else {
      _quantities[item.id] = qty;
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _quantities.clear();
    notifyListeners();
  }

  /// Null when the order meets the zone minimum, otherwise how much more
  /// the customer needs to add.
  int? shortOfMinimum(DeliveryZone zone) {
    final short = zone.minOrderPhp - subtotalPhp;
    return short > 0 ? short : null;
  }

  List<OrderLine> toLines() => _items.values
      .map((item) => OrderLine(
            menuItemId: item.id,
            name: item.name,
            unitPricePhp: item.pricePhp,
            quantity: quantityOf(item.id),
          ))
      .toList();
}
