/// Delivery zones measured by distance from the store in Poblacion,
/// Hinunangan. Fees and minimums are in Philippine pesos.
class DeliveryZone {
  final int number;
  final double maxKm;
  final int feePhp;
  final int minOrderPhp;

  const DeliveryZone({
    required this.number,
    required this.maxKm,
    required this.feePhp,
    required this.minOrderPhp,
  });

  static const zones = [
    DeliveryZone(number: 1, maxKm: 2, feePhp: 20, minOrderPhp: 0),
    DeliveryZone(number: 2, maxKm: 5, feePhp: 40, minOrderPhp: 200),
    DeliveryZone(number: 3, maxKm: 8, feePhp: 60, minOrderPhp: 400),
  ];

  /// Returns the zone for a distance, or null when it is outside delivery
  /// range (pickup or bulk order by arrangement only).
  static DeliveryZone? forDistance(double km) {
    for (final zone in zones) {
      if (km <= zone.maxKm) return zone;
    }
    return null;
  }
}
