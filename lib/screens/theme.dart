import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const brandOrange = Color(0xFFE8740C);
const brandCream = Color(0xFFFFF6EA);

final _peso = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 0);
String peso(int amount) => _peso.format(amount);

ThemeData dolebeeTheme() => ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: brandOrange, primary: brandOrange),
      scaffoldBackgroundColor: brandCream,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: brandOrange,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
    );

IconData iconForCategory(String category) => switch (category) {
      'Buckets' => Icons.takeout_dining,
      'Sides' => Icons.rice_bowl,
      'Drinks' => Icons.local_drink,
      _ => Icons.set_meal,
    };
