import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/theme.dart';

// Firebase is added once the Firebase project exists: run
// `flutterfire configure`, then call Firebase.initializeApp here.
void main() {
  runApp(const DolebeeApp());
}

class DolebeeApp extends StatelessWidget {
  const DolebeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dolebee',
      debugShowCheckedModeBanner: false,
      theme: dolebeeTheme(),
      home: const HomeScreen(),
    );
  }
}
