import '../models/order.dart';

/// Today's numbers for the owner dashboard and the monthly app-fee report.
class DailySales {
  final int orderCount;
  final int totalPhp;
  final int gcashPhp;
  final int codPhp;
  final Map<String, int> cashExpectedByRider;
  final Map<String, int> cashCollectedByRider;
  final Map<String, int> cashRemittedByRider;
  final Map<String, int> quantityByItem;

  /// Orders placed today that are not delivered yet; they join the sales
  /// total once delivered.
  final int pendingCount;
  final int pendingPhp;

  /// Cash a delivery staff member has collected but not yet handed over.
  int cashOnHand(String riderId) =>
      (cashCollectedByRider[riderId] ?? 0) - (cashRemittedByRider[riderId] ?? 0);

  const DailySales({
    required this.orderCount,
    required this.totalPhp,
    required this.gcashPhp,
    required this.codPhp,
    required this.cashExpectedByRider,
    required this.cashCollectedByRider,
    required this.cashRemittedByRider,
    required this.quantityByItem,
    required this.pendingCount,
    required this.pendingPhp,
  });

  /// Only delivered orders count as sales.
  factory DailySales.fromOrders(Iterable<Order> orders) {
    var count = 0, total = 0, gcash = 0, cod = 0;
    final byRider = <String, int>{};
    final collected = <String, int>{};
    final remitted = <String, int>{};
    final byItem = <String, int>{};
    var pendingCount = 0, pendingPhp = 0;
    for (final o in orders) {
      if (o.status == OrderStatus.cancelled) continue;
      if (o.status != OrderStatus.delivered) {
        pendingCount++;
        pendingPhp += o.totalPhp;
        continue;
      }
      count++;
      total += o.totalPhp;
      if (o.payment == PaymentMethod.gcashQr) {
        gcash += o.totalPhp;
      } else {
        cod += o.totalPhp;
        final rider = o.riderId ?? 'unassigned';
        byRider[rider] = (byRider[rider] ?? 0) + o.totalPhp;
        if (o.cashCollected) {
          collected[rider] = (collected[rider] ?? 0) + o.totalPhp;
        }
        if (o.cashRemitted) {
          remitted[rider] = (remitted[rider] ?? 0) + o.totalPhp;
        }
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
      cashCollectedByRider: collected,
      cashRemittedByRider: remitted,
      quantityByItem: byItem,
      pendingCount: pendingCount,
      pendingPhp: pendingPhp,
    );
  }
}

/// App fee owed to the app owner for a month: PHP 299 base plus PHP 5 per
/// completed order, waived during the free months.
int monthlyAppFeePhp({required int completedOrders, required bool freeMonth}) =>
    freeMonth ? 0 : 299 + 5 * completedOrders;
