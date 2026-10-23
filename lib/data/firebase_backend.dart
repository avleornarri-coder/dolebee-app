import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/menu_item.dart';
import '../models/order.dart';
import 'backend.dart';

/// Stores the menu, orders, and staff in Cloud Firestore.
///
/// Collections: `menu/{itemId}`, `orders/{orderId}`, and `users/{uid}` with
/// a `role` of owner, rider, or customer. See firestore.rules.
class FirebaseBackend implements Backend {
  final FirebaseFirestore db;

  /// Set for a customer, so they only load their own orders.
  final String? customerUid;

  /// Set for a delivery staff member, so they only load orders given to them.
  final String? riderUid;

  FirebaseBackend(this.db, {this.customerUid, this.riderUid});

  @override
  Stream<List<MenuItem>> watchMenu() => db.collection('menu').orderBy('name').snapshots().map(
      (s) => s.docs.map((d) => MenuItem.fromMap(d.id, d.data())).toList());

  @override
  Stream<List<Order>> watchOrders() {
    final orders = db.collection('orders');
    // Customers and delivery staff only see their own orders. Those lists are
    // short, so they're sorted on the phone, which avoids extra Firestore
    // indexes.
    final Query<Map<String, dynamic>> q = customerUid != null
        ? orders.where('customerUid', isEqualTo: customerUid)
        : riderUid != null
            ? orders.where('riderId', isEqualTo: riderUid)
            // ISO dates sort in time order; the newest 300 cover several busy days.
            : orders.orderBy('createdAt', descending: true).limit(300);
    return q.snapshots().map((s) => s.docs.map((d) => Order.fromMap(d.id, d.data())).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt)));
  }

  @override
  Stream<List<Rider>> watchRiders() {
    if (customerUid != null || riderUid != null) return Stream.value(const []);
    return db.collection('users').where('role', isEqualTo: 'rider').snapshots().map((s) =>
        s.docs.map((d) => Rider(d.id, d.data()['name'] as String? ?? 'Delivery staff')).toList());
  }

  @override
  Future<void> saveOrder(Order order) =>
      db.collection('orders').doc(order.id).set(order.toMap());

  @override
  Future<void> saveMenuItem(MenuItem item) =>
      db.collection('menu').doc(item.id).set(item.toMap());

  @override
  Future<void> deleteMenuItem(String id) => db.collection('menu').doc(id).delete();

  @override
  Future<void> addRider({required String name, required String email, required String password}) async {
    // Creating a user signs that user in, so use a second Firebase app to keep
    // the owner logged in.
    final helper = await Firebase.initializeApp(
        name: 'staff-${DateTime.now().millisecondsSinceEpoch}', options: Firebase.app().options);
    try {
      final cred = await FirebaseAuth.instanceFor(app: helper)
          .createUserWithEmailAndPassword(email: email, password: password);
      await db.collection('users').doc(cred.user!.uid).set({'role': 'rider', 'name': name, 'email': email});
    } finally {
      await helper.delete();
    }
  }
}
