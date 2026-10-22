import 'package:dolebee_app/models/order.dart';
import 'package:dolebee_app/screens/owner/menu_editor_screen.dart';
import 'package:dolebee_app/screens/owner/orders_screen.dart';
import 'package:dolebee_app/screens/owner/sales_screen.dart';
import 'package:dolebee_app/screens/rider/rider_home.dart';
import 'package:dolebee_app/state/app_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Order _order(String id, PaymentMethod payment) => Order(
      id: id,
      customerId: '09171234567',
      customerName: 'Ana',
      lines: const [OrderLine(menuItemId: 'c1', name: '1pc Chicken with Rice', unitPricePhp: 99, quantity: 2)],
      deliveryFeePhp: 20,
      payment: payment,
      status: payment == PaymentMethod.gcashQr ? OrderStatus.awaitingPayment : OrderStatus.received,
      address: 'Poblacion',
      landmark: '',
      lat: 0,
      lng: 0,
      createdAt: DateTime.now(),
      gcashReference: payment == PaymentMethod.gcashQr ? '1234567890123' : null,
    );

Future<void> _show(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: screen));
}

void main() {
  testWidgets('owner moves a cash order from new to out for delivery', (tester) async {
    final store = AppStore()..placeOrder(_order('DB-1', PaymentMethod.cashOnDelivery));
    await _show(tester, OrdersScreen(store: store));

    await tester.tap(find.text('Start cooking'));
    await tester.pump();
    expect(store.orderById('DB-1')!.status, OrderStatus.cooking);

    await tester.tap(find.text('Jun'));
    await tester.pump();
    expect(store.orderById('DB-1')!.status, OrderStatus.outForDelivery);
    expect(store.orderById('DB-1')!.riderId, 'r1');
  });

  testWidgets('owner confirms a GCash payment', (tester) async {
    final store = AppStore()..placeOrder(_order('DB-2', PaymentMethod.gcashQr));
    await _show(tester, OrdersScreen(store: store));
    expect(find.textContaining('GCash ref: 1234567890123'), findsOneWidget);

    await tester.tap(find.text('Payment confirmed'));
    await tester.pump();
    expect(store.orderById('DB-2')!.status, OrderStatus.received);
  });

  testWidgets('delivery staff finishes a cash delivery and sales update', (tester) async {
    final store = AppStore()
      ..placeOrder(_order('DB-3', PaymentMethod.cashOnDelivery))
      ..sendOut('DB-3', 'r1');
    await _show(tester, RiderHome(store: store, rider: store.riders.first));
    expect(find.text('Collect ₱218 cash'), findsOneWidget);

    await tester.tap(find.text('Delivered, cash received'));
    await tester.pump();
    expect(find.text('No deliveries assigned to you right now.'), findsOneWidget);

    expect(find.text('Cash on hand: ₱218'), findsOneWidget);

    await _show(tester, SalesScreen(store: store));
    expect(find.text('₱218'), findsWidgets);
    expect(find.text('2 sold'), findsOneWidget);
    expect(find.text('Collected today ₱218 · handed over ₱0'), findsOneWidget);

    // The owner confirms the cash was handed over.
    await tester.tap(find.text('Received ₱218'));
    await tester.pump();
    expect(find.text('Collected today ₱218 · handed over ₱218'), findsOneWidget);
    expect(store.cashOnHand('r1'), 0);
  });

  testWidgets('sales show orders not yet delivered, and the owner can mark one delivered',
      (tester) async {
    final store = AppStore()
      ..placeOrder(_order('DB-4', PaymentMethod.cashOnDelivery))
      ..sendOut('DB-4', 'r1');
    await _show(tester, SalesScreen(store: store));
    expect(find.text('1 order (₱218) not delivered yet'), findsOneWidget);
    expect(find.text('0 delivered orders'), findsOneWidget);

    await _show(tester, OrdersScreen(store: store));
    await tester.tap(find.text('Mark delivered (cash with Jun)'));
    await tester.pump();
    expect(store.orderById('DB-4')!.status, OrderStatus.delivered);
    expect(store.cashOnHand('r1'), 218);
  });

  testWidgets('owner changes a price and marks an item sold out', (tester) async {
    final store = AppStore();
    await _show(tester, MenuEditorScreen(store: store));

    await tester.tap(find.text('1pc Chicken with Rice'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Price'), '105');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(store.menu.firstWhere((m) => m.id == 'c1').pricePhp, 105);

    await tester.tap(find.byType(Switch).first);
    await tester.pump();
    expect(store.menu.firstWhere((m) => m.id == 'c1').soldOut, isTrue);
  });
}
