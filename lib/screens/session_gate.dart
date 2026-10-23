import 'package:flutter/material.dart';

import '../data/firebase_backend.dart';
import '../services/auth_service.dart';
import '../state/app_store.dart';
import '../state/cart.dart';
import 'menu_screen.dart';
import 'owner/owner_home.dart';
import 'rider/rider_home.dart';
import 'staff_login_screen.dart';
import 'theme.dart';

/// Sends each person to their own screens: customers to the menu, the
/// owner to orders and sales, delivery staff to their deliveries.
class SessionGate extends StatefulWidget {
  final AuthService auth;
  const SessionGate({super.key, required this.auth});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  Session? _session;
  AppStore? _store;
  final _cart = Cart();
  String? _error;

  @override
  void initState() {
    super.initState();
    _run(widget.auth.start);
  }

  @override
  void dispose() {
    _store?.dispose();
    _cart.dispose();
    super.dispose();
  }

  Future<void> _run(Future<Session> Function() step) async {
    setState(() => _error = null);
    try {
      _use(await step());
    } catch (e) {
      if (mounted) setState(() => _error = e is AuthMessage ? e.message : 'Can\'t reach the store. Check your internet.');
    }
  }

  void _use(Session session) {
    if (!mounted) return;
    final db = widget.auth.db;
    setState(() {
      _store?.dispose();
      _session = session;
      _store = AppStore(
        backend: FirebaseBackend(db,
            customerUid: session.role == Role.customer ? session.uid : null,
            riderUid: session.role == Role.rider ? session.uid : null),
        customerUid: session.role == Role.customer ? session.uid : null,
      );
    });
  }

  Future<void> _staffLogin() async {
    final session = await Navigator.of(context).push<Session>(
        MaterialPageRoute(builder: (_) => StaffLoginScreen(auth: widget.auth)));
    if (session != null) _use(session);
  }

  void _logout() => _run(widget.auth.signOut);

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final store = _store;
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: () => _run(widget.auth.start), child: const Text('Try again')),
            ]),
          ),
        ),
      );
    }
    if (session == null || store == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: brandOrange)));
    }
    return switch (session.role) {
      Role.customer => MenuScreen(
          key: ValueKey(session.uid), store: store, cart: _cart, onStaffLogin: _staffLogin),
      Role.owner => OwnerHome(key: ValueKey(session.uid), store: store, onLogout: _logout),
      Role.rider => RiderHome(
          key: ValueKey(session.uid), store: store, rider: Rider(session.uid, session.name), onLogout: _logout),
    };
  }
}
