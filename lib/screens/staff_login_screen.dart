import 'package:flutter/material.dart';

import '../services/auth_service.dart';

/// Login for the owner and delivery staff. The very first time, the owner
/// creates their account here instead.
class StaffLoginScreen extends StatefulWidget {
  final AuthService auth;
  const StaffLoginScreen({super.key, required this.auth});

  @override
  State<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends State<StaffLoginScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _settingUpOwner = false;
  bool _canSetUpOwner = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.auth.storeHasOwner().then((has) {
      if (mounted) setState(() => _canSetUpOwner = !has);
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final session = _settingUpOwner
          ? await widget.auth.setUpOwner(_name.text.trim(), _email.text, _password.text)
          : await widget.auth.signIn(_email.text, _password.text);
      if (mounted) Navigator.of(context).pop(session);
    } catch (e) {
      if (mounted) setState(() => _error = e is AuthMessage ? e.message : 'Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_settingUpOwner ? 'Set up owner account' : 'Staff login')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              _settingUpOwner
                  ? 'Create the owner\'s login. Do this once; the owner then adds delivery staff from the Team tab.'
                  : 'For the store owner and delivery staff. Customers don\'t need to log in.',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            if (_settingUpOwner)
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Your name'),
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              ),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) => v!.contains('@') ? null : 'Enter an email address',
            ),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (v) => v!.length >= 6 ? null : 'At least 6 characters',
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              onPressed: _busy ? null : _submit,
              child: Text(_busy ? 'Please wait…' : (_settingUpOwner ? 'Create owner account' : 'Log in')),
            ),
            if (_canSetUpOwner)
              TextButton(
                onPressed: () => setState(() => _settingUpOwner = !_settingUpOwner),
                child: Text(_settingUpOwner ? 'I already have an account' : 'First time? Set up the owner account'),
              ),
          ],
        ),
      ),
    );
  }
}
