import 'package:flutter/material.dart';

import '../state/app_store.dart';
import '../state/cart.dart';
import 'menu_screen.dart';
import 'owner/owner_home.dart';
import 'rider/rider_home.dart';
import 'theme.dart';

/// Preview entry: pick who you are. Once Firebase Auth is connected, login
/// sends each person straight to their own screens instead.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _store = AppStore();
  final _cart = Cart();

  @override
  void dispose() {
    _cart.dispose();
    _store.dispose();
    super.dispose();
  }

  void _open(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            const Icon(Icons.set_meal, size: 72, color: brandOrange),
            const Text('OrderLokal',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const Text('Ordering and delivery for local shops',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 32),
            const Text('Preview as:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _RoleButton(
              icon: Icons.shopping_bag,
              title: 'Customer',
              subtitle: 'Order from the menu',
              onTap: () => _open(MenuScreen(store: _store, cart: _cart)),
            ),
            _RoleButton(
              icon: Icons.storefront,
              title: 'Owner',
              subtitle: 'Orders, daily sales, menu',
              onTap: () => _open(OwnerHome(store: _store)),
            ),
            for (final rider in _store.riders)
              _RoleButton(
                icon: Icons.delivery_dining,
                title: 'Delivery staff: ${rider.name}',
                subtitle: 'Assigned deliveries',
                onTap: () => _open(RiderHome(store: _store, rider: rider)),
              ),
          ],
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _RoleButton({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
        color: Colors.white,
        child: ListTile(
          leading: Icon(icon, color: brandOrange, size: 32),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      );
}
