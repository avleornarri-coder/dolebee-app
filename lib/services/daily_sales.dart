import '../models/order.dart';

/// Today's numbers for the owner dashboard and the monthly app-fee report.
class DailySales {
  final int orderCount;
  final int totalPhp;
  final int gcashPhp;
  final int codPhp;
  final Map<String, int> cashExpectedByRider;
  final Map<String, int> quantityByItem;

  const DailySales({
    required this.orderCount,
    required this.totalPhp,
    required this.gcashPhp,
    required this.codPhp,
    required this.cashExpectedByRider,
    required this.quantityByItem,
  });

  /// Only delivered orders count as sales.
  factory DailySales.fromOrders(Iterable<Order> orders) {
    var count = 0, total = 0, gcash = 0, cod = 0;
    final byRider = <String, int>{};
    final byItem = <String, int>{};
    for (final o in orders.where((o) => o.status == OrderStatus.delivered)) {
      count++;
      total += o.totalPhp;
      if (o.payment == PaymentMethod.gcashQr) {
        gcash += o.totalPhp;
      } else {
        cod += o.totalPhp;
        final rider = o.riderId ?? 'unassigned';
        byRider[rider] = (byRider[rider] ?? 0) + o.totalPhp;
      }
      for (final line in o.lines) {
        byItem[line.name] = (byItem[line.name] ?? 0) + line.quantity;
      }
    }
    return DailySales(
      orderCount: count,
      totalPhp: total,
      gcashPhp: gcash,
      codPhp: cod,
      cashExpectedByRider: byRider,
      quantityByItem: byItem,
    );
  }
}

/// App fee owed to the app owner for a month: PHP 299 base plus PHP 5 per
/// completed order, waived during the free months.
int monthlyAppFeePhp({required int completedOrders, required bool freeMonth}) =>
    freeMonth ? 0 : 299 + 5 * completedOrders;
