import 'package:flutter/material.dart';

import '../../state/app_store.dart';
import 'menu_editor_screen.dart';
import 'orders_screen.dart';
import 'sales_screen.dart';
import 'shop_screen.dart';

class OwnerHome extends StatefulWidget {
  final AppStore store;
  final VoidCallback? onLogout;
  const OwnerHome({super.key, required this.store, this.onLogout});

  @override
  State<OwnerHome> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHome> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      OrdersScreen(store: widget.store),
      SalesScreen(store: widget.store),
      MenuEditorScreen(store: widget.store),
      ShopScreen(store: widget.store, onLogout: widget.onLogout),
    ];
    return Scaffold(
      body: pages[_tab],
      bottomNavigationBar: ListenableBuilder(
        listenable: widget.store,
        builder: (context, _) {
          final waiting = widget.store.activeOrders.length;
          return NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: [
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: waiting > 0,
                  label: Text('$waiting'),
                  child: const Icon(Icons.receipt_long),
                ),
                label: 'Orders',
              ),
              const NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Sales'),
              const NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
              const NavigationDestination(icon: Icon(Icons.storefront), label: 'Shop'),
            ],
          );
        },
      ),
    );
  }
}
