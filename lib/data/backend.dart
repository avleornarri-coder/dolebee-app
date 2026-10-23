import '../models/menu_item.dart';
import '../models/order.dart';

class Rider {
  final String id;
  final String name;
  const Rider(this.id, this.name);
}

/// Where the menu, orders, and delivery staff are stored. The app uses
/// Firebase on phones; the web preview and tests keep everything in memory.
abstract class Backend {
  Stream<List<MenuItem>> watchMenu();

  /// All orders for the owner and delivery staff; only their own orders for
  /// a customer.
  Stream<List<Order>> watchOrders();

  Stream<List<Rider>> watchRiders();

  Future<void> saveOrder(Order order);
  Future<void> saveMenuItem(MenuItem item);
  Future<void> deleteMenuItem(String id);

  /// Creates a login for a new delivery staff member.
  Future<void> addRider({required String name, required String email, required String password});
}
