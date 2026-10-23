import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_config.dart';
import 'screens/home_screen.dart';
import 'screens/session_gate.dart';
import 'screens/theme.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AuthService? auth;
  // The web preview always runs offline; phones use Firebase once it's set up.
  if (!kIsWeb && firebaseAndroidOptions != null) {
    await Firebase.initializeApp(options: firebaseAndroidOptions);
    auth = AuthService(FirebaseAuth.instance, FirebaseFirestore.instance);
  }
  runApp(OrderingApp(auth: auth));
}

class OrderingApp extends StatelessWidget {
  /// Null for the offline preview, which lets you switch between roles.
  final AuthService? auth;
  const OrderingApp({super.key, this.auth});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OrderLokal',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      home: auth == null ? const HomeScreen() : SessionGate(auth: auth!),
    );
  }
}
