import 'package:flutter/material.dart';

import '../../state/app_store.dart';

/// Delivery staff accounts, and logging out.
class TeamScreen extends StatelessWidget {
  final AppStore store;
  final VoidCallback? onLogout;
  const TeamScreen({super.key, required this.store, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 4, 4, 8),
              child: Text('Delivery staff', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Card(
              color: Colors.white,
              child: Column(children: [
                if (store.riders.isEmpty)
                  const ListTile(title: Text('No delivery staff yet.')),
                for (final rider in store.riders)
                  ListTile(leading: const Icon(Icons.delivery_dining), title: Text(rider.name)),
              ]),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => _addRider(context),
              icon: const Icon(Icons.person_add),
              label: const Text('Add delivery staff'),
            ),
            if (onLogout != null) ...[
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _addRider(BuildContext context) async {
    final name = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();
    final form = GlobalKey<FormState>();
    String? error;
    var busy = false;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add delivery staff'),
          content: Form(
            key: form,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('They log in with this email and password on their own phone.',
                  style: TextStyle(color: Colors.black54)),
              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v!.contains('@') ? null : 'Enter an email address',
              ),
              TextFormField(
                controller: password,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (v) => v!.length >= 6 ? null : 'At least 6 characters',
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(error!, style: const TextStyle(color: Colors.red)),
                ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            FilledButton(
              onPressed: busy
                  ? null
                  : () async {
                      if (!form.currentState!.validate()) return;
                      setState(() => busy = true);
                      try {
                        await store.addRider(
                            name: name.text.trim(), email: email.text.trim(), password: password.text);
                        if (context.mounted) Navigator.of(context).pop();
                      } catch (e) {
                        setState(() {
                          busy = false;
                          error = 'Couldn\'t add them. Check the email isn\'t already used.';
                        });
                      }
                    },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
