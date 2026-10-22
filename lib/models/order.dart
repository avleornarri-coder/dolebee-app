enum PaymentMethod { gcashQr, cashOnDelivery }

/// Order lifecycle. GCash orders wait in [awaitingPayment] until the owner
/// checks the reference number; COD orders go straight to [received].
enum OrderStatus {
  awaitingPayment,
  received,
  cooking,
  outForDelivery,
  delivered,
  cancelled,
}

class OrderLine {
  final String menuItemId;
  final String name;
  final int unitPricePhp;
  final int quantity;

  const OrderLine({
    required this.menuItemId,
    required this.name,
    required this.unitPricePhp,
    required this.quantity,
  });

  int get totalPhp => unitPricePhp * quantity;

  Map<String, dynamic> toMap() => {
        'menuItemId': menuItemId,
        'name': name,
        'unitPricePhp': unitPricePhp,
        'quantity': quantity,
      };

  factory OrderLine.fromMap(Map<String, dynamic> data) => OrderLine(
        menuItemId: data['menuItemId'] as String,
        name: data['name'] as String,
        unitPricePhp: (data['unitPricePhp'] as num).toInt(),
        quantity: (data['quantity'] as num).toInt(),
      );
}

class Order {
  final String id;
  final String customerId;
  final String customerName;
  final List<OrderLine> lines;
  final int deliveryFeePhp;
  final PaymentMethod payment;
  final OrderStatus status;
  final String address;
  final String landmark;
  final double lat;
  final double lng;
  final String? gcashReference;
  final String? receiptPhotoUrl;
  final String? riderId;
  final bool cashCollected;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.customerId,
    this.customerName = '',
    required this.lines,
    required this.deliveryFeePhp,
    required this.payment,
    required this.status,
    required this.address,
    required this.landmark,
    required this.lat,
    required this.lng,
    required this.createdAt,
    this.gcashReference,
    this.receiptPhotoUrl,
    this.riderId,
    this.cashCollected = false,
  });

  int get subtotalPhp => lines.fold(0, (sum, line) => sum + line.totalPhp);
  int get totalPhp => subtotalPhp + deliveryFeePhp;

  Order copyWith({
    OrderStatus? status,
    String? riderId,
    bool? cashCollected,
    String? gcashReference,
    String? receiptPhotoUrl,
  }) =>
      Order(
        id: id,
        customerId: customerId,
        customerName: customerName,
        lines: lines,
        deliveryFeePhp: deliveryFeePhp,
        payment: payment,
        status: status ?? this.status,
        address: address,
        landmark: landmark,
        lat: lat,
        lng: lng,
        createdAt: createdAt,
        gcashReference: gcashReference ?? this.gcashReference,
        receiptPhotoUrl: receiptPhotoUrl ?? this.receiptPhotoUrl,
        riderId: riderId ?? this.riderId,
        cashCollected: cashCollected ?? this.cashCollected,
      );

  Map<String, dynamic> toMap() => {
        'customerId': customerId,
        'customerName': customerName,
        'lines': lines.map((l) => l.toMap()).toList(),
        'deliveryFeePhp': deliveryFeePhp,
        'payment': payment.name,
        'status': status.name,
        'address': address,
        'landmark': landmark,
        'lat': lat,
        'lng': lng,
        'gcashReference': gcashReference,
        'receiptPhotoUrl': receiptPhotoUrl,
        'riderId': riderId,
        'cashCollected': cashCollected,
        'subtotalPhp': subtotalPhp,
        'totalPhp': totalPhp,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Order.fromMap(String id, Map<String, dynamic> data) => Order(
        id: id,
        customerId: data['customerId'] as String,
        customerName: data['customerName'] as String? ?? '',
        lines: (data['lines'] as List)
            .map((l) => OrderLine.fromMap(Map<String, dynamic>.from(l)))
            .toList(),
        deliveryFeePhp: (data['deliveryFeePhp'] as num).toInt(),
        payment: PaymentMethod.values.byName(data['payment'] as String),
        status: OrderStatus.values.byName(data['status'] as String),
        address: data['address'] as String,
        landmark: data['landmark'] as String? ?? '',
        lat: (data['lat'] as num).toDouble(),
        lng: (data['lng'] as num).toDouble(),
        gcashReference: data['gcashReference'] as String?,
        receiptPhotoUrl: data['receiptPhotoUrl'] as String?,
        riderId: data['riderId'] as String?,
        cashCollected: data['cashCollected'] as bool? ?? false,
        createdAt: DateTime.parse(data['createdAt'] as String),
      );
}
