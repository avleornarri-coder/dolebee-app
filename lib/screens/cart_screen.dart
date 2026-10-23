import 'package:flutter/material.dart';

import '../models/delivery_zone.dart';
import '../models/order.dart';
import '../state/app_store.dart';
import '../state/cart.dart';
import 'gcash_payment_screen.dart';
import 'order_status_screen.dart';
import 'theme.dart';

class CartScreen extends StatefulWidget {
  final AppStore store;
  final Cart cart;
  const CartScreen({super.key, required this.store, required this.cart});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _landmark = TextEditingController();
  // Until the map pin is added, the customer picks their zone by distance.
  DeliveryZone _zone = DeliveryZone.zones.first;
  PaymentMethod _payment = PaymentMethod.cashOnDelivery;

  Cart get cart => widget.cart;

  @override
  void dispose() {
    for (final c in [_name, _phone, _address, _landmark]) {
      c.dispose();
    }
    super.dispose();
  }

  Order _buildOrder() => Order(
        id: newOrderId(),
        customerId: _phone.text.replaceAll(' ', ''),
        customerUid: widget.store.customerUid ?? '',
        customerName: _name.text.trim(),
        lines: cart.toLines(),
        deliveryFeePhp: _zone.feePhp,
        payment: _payment,
        status: _payment == PaymentMethod.gcashQr
            ? OrderStatus.awaitingPayment
            : OrderStatus.received,
        address: _address.text,
        landmark: _landmark.text,
        lat: 0,
        lng: 0,
        createdAt: DateTime.now(),
      );

  void _placeOrder() {
    if (!_form.currentState!.validate()) return;
    final order = _buildOrder();
    final Widget next;
    if (_payment == PaymentMethod.gcashQr) {
      next = GcashPaymentScreen(store: widget.store, order: order, cart: cart);
    } else {
      widget.store
        ..customerPhone = order.customerId
        ..placeOrder(order);
      cart.clear();
      next = OrderStatusScreen(store: widget.store, orderId: order.id);
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => next));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your order')),
      body: ListenableBuilder(
        listenable: cart,
        builder: (context, _) {
          final short = cart.shortOfMinimum(_zone);
          final total = cart.subtotalPhp + _zone.feePhp;
          return Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Section(
                  title: 'Items',
                  child: Column(children: [
                    for (final item in cart.items)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.name),
                        subtitle: Text(peso(item.pricePhp)),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(onPressed: () => cart.remove(item), icon: const Icon(Icons.remove_circle_outline)),
                          Text('${cart.quantityOf(item.id)}'),
                          IconButton(onPressed: () => cart.add(item), icon: const Icon(Icons.add_circle_outline)),
                        ]),
                      ),
                  ]),
                ),
                _Section(
                  title: 'Deliver to',
                  child: Column(children: [
                    _field(_name, 'Your name'),
                    _field(_phone, 'Mobile number', hint: '09XX XXX XXXX', keyboard: TextInputType.phone,
                        validator: (v) => RegExp(r'^09\d{9}$').hasMatch(v!.replaceAll(' ', ''))
                            ? null
                            : 'Enter an 11-digit number starting with 09'),
                    _field(_address, 'Barangay and street'),
                    _field(_landmark, 'Landmark (optional)', hint: 'e.g. beside the chapel, blue gate', required: false),
                    DropdownButtonFormField<DeliveryZone>(
                      initialValue: _zone,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Distance from Poblacion'),
                      items: [
                        for (final z in DeliveryZone.zones)
                          DropdownMenuItem(
                            value: z,
                            child: Text('Up to ${z.maxKm.toStringAsFixed(0)} km · ${peso(z.feePhp)} delivery'),
                          ),
                      ],
                      onChanged: (z) => setState(() => _zone = z!),
                    ),
                  ]),
                ),
                _Section(
                  title: 'Payment',
                  child: RadioGroup<PaymentMethod>(
                    groupValue: _payment,
                    onChanged: (p) => setState(() => _payment = p!),
                    child: const Column(children: [
                      RadioListTile(
                        contentPadding: EdgeInsets.zero,
                        value: PaymentMethod.cashOnDelivery,
                        title: Text('Cash on delivery'),
                        subtitle: Text('Pay the rider when your order arrives'),
                      ),
                      RadioListTile(
                        contentPadding: EdgeInsets.zero,
                        value: PaymentMethod.gcashQr,
                        title: Text('GCash'),
                        subtitle: Text('Scan our QR and enter your reference number'),
                      ),
                    ]),
                  ),
                ),
                _Section(
                  title: 'Summary',
                  child: Column(children: [
                    _row('Subtotal', peso(cart.subtotalPhp)),
                    _row('Delivery fee', peso(_zone.feePhp)),
                    const Divider(),
                    _row('Total', peso(total), bold: true),
                  ]),
                ),
                if (short != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('Add ${peso(short)} more to reach the ${peso(_zone.minOrderPhp)} minimum for this distance.',
                        style: const TextStyle(color: Colors.red)),
                  ),
                FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                  onPressed: cart.isEmpty || short != null ? null : _placeOrder,
                  child: Text('Place order · ${peso(total)}', style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
          {String? hint, TextInputType? keyboard, bool required = true, String? Function(String?)? validator}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextFormField(
          controller: c,
          keyboardType: keyboard,
          decoration: InputDecoration(labelText: label, hintText: hint),
          validator: validator ?? (v) => required && v!.trim().isEmpty ? 'Required' : null,
        ),
      );

  Widget _row(String label, String value, {bool bold = false}) {
    final style = TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: bold ? 18 : 15);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: style),
        Text(value, style: style),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            child,
          ]),
        ),
      );
}
