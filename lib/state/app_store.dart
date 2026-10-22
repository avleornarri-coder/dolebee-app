import 'package:flutter/foundation.dart';

import '../data/sample_menu.dart';
import '../models/menu_item.dart';
import '../models/order.dart';
import '../services/daily_sales.dart';

class Rider {
  final String id;
  final String name;
  const Rider(this.id, this.name);
}

/// Menu, orders, and delivery staff shared by the customer, owner, and
/// delivery staff screens. Kept in memory for now; the same methods will
/// read and write Firestore once Firebase is connected.
class AppStore extends ChangeNotifier {
  final List<MenuItem> _menu = [...sampleMenu];
  final List<Order> _orders = [];
  final List<Rider> riders = const [Rider('r1', 'Jun'), Rider('r2', 'Rey')];

  /// The customer using this phone. Until login is added, the mobile
  /// number from their last order stands in for their account.
  String? customerPhone;

  List<MenuItem> get menu => List.unmodifiable(_menu);
  List<Order> get orders => List.unmodifiable(_orders.reversed);

  List<String> get categories => _menu.map((m) => m.category).toSet().toList();

  Order? orderById(String id) {
    for (final o in _orders) {
      if (o.id == id) return o;
    }
    return null;
  }

  String riderName(String? id) {
    for (final r in riders) {
      if (r.id == id) return r.name;
    }
    return 'Unassigned';
  }

  /// Orders still in progress, oldest first so the owner works in order.
  List<Order> get activeOrders => _orders
      .where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled)
      .toList();

  List<Order> ordersForRider(String riderId) => _orders
      .where((o) => o.riderId == riderId && o.status == OrderStatus.outForDelivery)
      .toList();

  DailySales salesOn(DateTime day) => DailySales.fromOrders(_orders.where((o) =>
      o.createdAt.year == day.year &&
      o.createdAt.month == day.month &&
      o.createdAt.day == day.day));

  /// This customer's orders, newest first.
  List<Order> get customerOrders =>
      orders.where((o) => o.customerId == customerPhone).toList();

  List<Order> get customerActiveOrders => customerOrders
      .where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled)
      .toList();

  void placeOrder(Order order) {
    _orders.add(order);
    notifyListeners();
  }

  void _update(String id, Order Function(Order) change) {
    final i = _orders.indexWhere((o) => o.id == id);
    if (i < 0) return;
    _orders[i] = change(_orders[i]);
    notifyListeners();
  }

  void setStatus(String id, OrderStatus status) =>
      _update(id, (o) => o.copyWith(status: status));

  void sendOut(String id, String riderId) => _update(
      id, (o) => o.copyWith(riderId: riderId, status: OrderStatus.outForDelivery));

  void markDelivered(String id, {required bool cashReceived}) => _update(
      id,
      (o) => o.copyWith(
            status: OrderStatus.delivered,
            cashCollected: o.payment == PaymentMethod.cashOnDelivery && cashReceived,
          ));

  /// Cash this delivery staff member collected and still holds.
  int cashOnHand(String riderId) => _orders
      .where((o) => o.riderId == riderId && o.cashCollected && !o.cashRemitted)
      .fold(0, (sum, o) => sum + o.totalPhp);

  /// The owner received all the cash this delivery staff member holds.
  void remitCash(String riderId) {
    for (var i = 0; i < _orders.length; i++) {
      final o = _orders[i];
      if (o.riderId == riderId && o.cashCollected && !o.cashRemitted) {
        _orders[i] = o.copyWith(cashRemitted: true);
      }
    }
    notifyListeners();
  }

  void saveMenuItem(MenuItem item) {
    final i = _menu.indexWhere((m) => m.id == item.id);
    if (i < 0) {
      _menu.add(item);
    } else {
      _menu[i] = item;
    }
    notifyListeners();
  }

  void deleteMenuItem(String id) {
    _menu.removeWhere((m) => m.id == id);
    notifyListeners();
  }
}
