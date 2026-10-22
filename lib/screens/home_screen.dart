import 'package:flutter/material.dart';

import '../state/cart.dart';
import 'menu_screen.dart';

/// Entry screen. Once Firebase Auth is connected, login routes owners and
/// delivery staff to their own screens; customers land on the menu.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _cart = Cart();

  @override
  void dispose() {
    _cart.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MenuScreen(cart: _cart);
}
