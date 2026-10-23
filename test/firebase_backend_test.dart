import 'package:orderlokal/data/firebase_backend.dart';
import 'package:orderlokal/models/menu_item.dart';
import 'package:orderlokal/models/order.dart';
import 'package:orderlokal/state/app_store.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

Order _order(String id, String customerUid, DateTime at) => Order(
      id: id,
      customerId: '09171234567',
      customerUid: customerUid,
      customerName: 'Ana',
      lines: const [OrderLine(menuItemId: 'c1', name: '1pc Chicken with Rice', unitPricePhp: 99, quantity: 1)],
      deliveryFeePhp: 20,
      payment: PaymentMethod.cashOnDelivery,
      status: OrderStatus.received,
      address: 'Poblacion',
      landmark: '',
      lat: 0,
      lng: 0,
      createdAt: at,
    );

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  test('owner and customer stores share orders and menu through Firestore', () async {
    final db = FakeFirebaseFirestore();
    await db.collection('users').doc('rider-1').set({'role': 'rider', 'name': 'Jun'});
    final owner = AppStore(backend: FirebaseBackend(db));
    final customer = AppStore(backend: FirebaseBackend(db, customerUid: 'cust-1'), customerUid: 'cust-1');
    final other = AppStore(backend: FirebaseBackend(db, customerUid: 'cust-2'), customerUid: 'cust-2');

    owner.saveMenuItem(const MenuItem(id: 'c1', name: '1pc Chicken with Rice', category: 'Chicken', pricePhp: 105));
    customer.placeOrder(_order('OL-1', 'cust-1', DateTime(2026, 10, 23, 10)));
    await _settle();

    expect(customer.menu.single.pricePhp, 105);
    expect(owner.orders.single.id, 'OL-1');
    expect(owner.riders.single.name, 'Jun');
    expect(customer.customerOrders.single.id, 'OL-1');
    expect(other.customerOrders, isEmpty);

    owner.setStatus('OL-1', OrderStatus.cooking);
    owner.sendOut('OL-1', 'rider-1');
    await _settle();
    expect(customer.customerOrders.single.status, OrderStatus.outForDelivery);

    final rider = AppStore(backend: FirebaseBackend(db, riderUid: 'rider-1'));
    await _settle();
    expect(rider.ordersForRider('rider-1').single.id, 'OL-1');
    rider.markDelivered('OL-1', cashReceived: true);
    await _settle();
    expect(owner.cashOnHand('rider-1'), 119);

    owner.remitCash('rider-1');
    await _settle();
    expect(owner.cashOnHand('rider-1'), 0);
    expect(owner.salesOn(DateTime(2026, 10, 23)).totalPhp, 119);

    for (final s in [owner, customer, other, rider]) {
      s.dispose();
    }
  });

  test('order numbers carry the date and time', () {
    expect(newOrderId(DateTime(2026, 10, 23, 9, 5)), matches(RegExp(r'^OL-1023-0905-\d{3}$')));
  });

  test('the owner sets the shop details and customers see them', () async {
    final db = FakeFirebaseFirestore();
    final owner = AppStore(backend: FirebaseBackend(db));
    final customer = AppStore(backend: FirebaseBackend(db, customerUid: 'cust-1'), customerUid: 'cust-1');
    await _settle();
    expect(customer.shop.name, 'OrderLokal');

    owner.saveShop(const ShopProfile(name: 'Dolebee Fried Chicken', area: 'Poblacion, Hinunangan'));
    await _settle();
    expect(customer.shop.name, 'Dolebee Fried Chicken');
    expect(customer.shop.subtitle, 'Poblacion, Hinunangan');
  });
}
