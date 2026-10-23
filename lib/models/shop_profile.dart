/// The shop's details that customers see. The owner sets them in the Shop
/// tab, so the same app works for any shop.
class ShopProfile {
  final String name;
  final String area;
  final String hours;

  const ShopProfile({required this.name, this.area = '', this.hours = ''});

  /// Shown until the owner enters the shop's details.
  static const empty = ShopProfile(name: 'OrderLokal');

  /// The area and hours on one line, leaving out whichever is blank.
  String get subtitle => [area, hours].where((s) => s.isNotEmpty).join(' · ');

  factory ShopProfile.fromMap(Map<String, dynamic> data) => ShopProfile(
        name: data['name'] as String? ?? empty.name,
        area: data['area'] as String? ?? '',
        hours: data['hours'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {'name': name, 'area': area, 'hours': hours};
}
