import 'package:flutter/material.dart';

/// The shop this copy of the app is built for. To make the app for another
/// shop, change these values (and its Firebase settings and app id).
class ShopConfig {
  final String name;
  final String area;
  final String hours;

  const ShopConfig({required this.name, required this.area, required this.hours});
}

const shop = ShopConfig(
  name: 'Dolebee Fried Chicken',
  area: 'Poblacion, Hinunangan',
  hours: 'Open until 9 PM',
);

// Colors are separate constants so screens can use them in const widgets.
const shopBrandColor = Color(0xFFE8740C);
const shopBackground = Color(0xFFFFF6EA);
