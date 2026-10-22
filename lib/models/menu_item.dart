class MenuItem {
  final String id;
  final String name;
  final String category;
  final int pricePhp;
  final String? photoUrl;
  final bool soldOut;

  const MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.pricePhp,
    this.photoUrl,
    this.soldOut = false,
  });

  factory MenuItem.fromMap(String id, Map<String, dynamic> data) => MenuItem(
        id: id,
        name: data['name'] as String,
        category: data['category'] as String? ?? 'Chicken',
        pricePhp: (data['pricePhp'] as num).toInt(),
        photoUrl: data['photoUrl'] as String?,
        soldOut: data['soldOut'] as bool? ?? false,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'category': category,
        'pricePhp': pricePhp,
        'photoUrl': photoUrl,
        'soldOut': soldOut,
      };
}
