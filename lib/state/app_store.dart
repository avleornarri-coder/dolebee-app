import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/backend.dart';
import '../data/sample_menu.dart';
import '../models/menu_item.dart';
import '../models/order.dart';
import '../models/shop_profile.dart';
import '../services/daily_sales.dart';

export '../data/backend.dart' show Rider;
export '../models/shop_profile.dart';

/// Menu, orders, and delivery staff shared by the customer, owner, and
/// delivery staff screens. With a [Backend] (Firebase on phones) every
/// change is saved there and shared across phones; without one, as in the
/// web preview and tests, everything stays in memory.
class AppStore extends ChangeNotifier {
  final Backend? backend;
  final List<MenuItem> _menu;
  final List<Order> _orders = [];
  final List<Rider> _riders;
  final List<StreamSubscription> _subs = [];
  ShopProfile _shop = ShopProfile.empty;

  /// Firebase account of the customer on this phone, when signed in.
  final String? customerUid;

  AppStore({this.backend, this.customerUid})
      : _menu = backend == null ? [...sampleMenu] : [],
        _riders = backend == null ? [const Rider('r1', 'Jun'), const Rider('r2', 'Rey')] : [] {
    final b = backend;
    if (b == null) return;
    _subs
      ..add(b.watchShop().listen((shop) {
        _shop = shop;
        notifyListeners();
      }))
      ..add(b.watchMenu().listen((items) => _replace(_menu, items)))
      ..add(b.watchOrders().listen((orders) => _replace(_orders, orders)))
      ..add(b.watchRiders().listen((riders) => _replace(_riders, riders)));
  }

  void _replace<T>(List<T> list, List<T> items) {
    list
      ..clear()
      ..addAll(items);
    notifyListeners();
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  ShopProfile get shop => _shop;

  void saveShop(ShopProfile shop) {
    if (backend != null) {
      backend!.saveShop(shop);
      return;
    }
    _shop = shop;
    notifyListeners();
  }

  List<Rider> get riders => List.unmodifiable(_riders);

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
  List<Order> get customerOrders => orders
      .where((o) => customerUid != null ? o.customerUid == customerUid : o.customerId == customerPhone)
      .toList();

  List<Order> get customerActiveOrders => customerOrders
      .where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled)
      .toList();

  void placeOrder(Order order) {
    if (backend != null) {
      backend!.saveOrder(order);
      return;
    }
    _orders.add(order);
    notifyListeners();
  }

  void _update(String id, Order Function(Order) change) {
    final i = _orders.indexWhere((o) => o.id == id);
    if (i < 0) return;
    final updated = change(_orders[i]);
    if (backend != null) {
      backend!.saveOrder(updated);
      return;
    }
    _orders[i] = updated;
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
    final held = _orders.where((o) => o.riderId == riderId && o.cashCollected && !o.cashRemitted).toList();
    for (final o in held) {
      _update(o.id, (o) => o.copyWith(cashRemitted: true));
    }
  }

  /// Creates a delivery staff login. In the preview it only adds the name.
  Future<void> addRider({required String name, required String email, required String password}) async {
    if (backend != null) {
      await backend!.addRider(name: name, email: email, password: password);
      return;
    }
    _riders.add(Rider('r${_riders.length + 1}', name));
    notifyListeners();
  }

  /// Fills an empty menu with the sample items, so a new store has
  /// something to edit.
  void loadSampleMenu() {
    for (final item in sampleMenu) {
      saveMenuItem(item);
    }
  }

  void saveMenuItem(MenuItem item) {
    if (backend != null) {
      backend!.saveMenuItem(item);
      return;
    }
    final i = _menu.indexWhere((m) => m.id == item.id);
    if (i < 0) {
      _menu.add(item);
    } else {
      _menu[i] = item;
    }
    notifyListeners();
  }

  void deleteMenuItem(String id) {
    if (backend != null) {
      backend!.deleteMenuItem(id);
      return;
    }
    _menu.removeWhere((m) => m.id == id);
    notifyListeners();
  }
}
