import 'package:dolebee_app/models/delivery_zone.dart';
import 'package:dolebee_app/models/order.dart';
import 'package:dolebee_app/services/daily_sales.dart';
import 'package:flutter_test/flutter_test.dart';

Order _order(PaymentMethod payment, OrderStatus status, {String? rider}) =>
    Order(
      id: 'o',
      customerId: 'c',
      lines: const [
        OrderLine(
            menuItemId: 'm1', name: '1pc Chicken', unitPricePhp: 99, quantity: 2),
      ],
      deliveryFeePhp: 20,
      payment: payment,
      status: status,
      address: 'Poblacion',
      landmark: '',
      lat: 0,
      lng: 0,
      createdAt: DateTime(2026, 10, 22),
      riderId: rider,
    );

void main() {
  test('delivery zones by distance', () {
    expect(DeliveryZone.forDistance(1.5)!.feePhp, 20);
    expect(DeliveryZone.forDistance(4)!.feePhp, 40);
    expect(DeliveryZone.forDistance(8)!.feePhp, 60);
    expect(DeliveryZone.forDistance(8.1), isNull);
  });

  test('daily sales counts only delivered orders', () {
    final sales = DailySales.fromOrders([
      _order(PaymentMethod.gcashQr, OrderStatus.delivered),
      _order(PaymentMethod.cashOnDelivery, OrderStatus.delivered, rider: 'r1'),
      _order(PaymentMethod.cashOnDelivery, OrderStatus.cancelled, rider: 'r1'),
    ]);
    expect(sales.orderCount, 2);
    expect(sales.totalPhp, 436);
    expect(sales.gcashPhp, 218);
    expect(sales.cashExpectedByRider['r1'], 218);
    expect(sales.quantityByItem['1pc Chicken'], 4);
  });

  test('monthly app fee', () {
    expect(monthlyAppFeePhp(completedOrders: 600, freeMonth: false), 3299);
    expect(monthlyAppFeePhp(completedOrders: 600, freeMonth: true), 0);
  });
}
