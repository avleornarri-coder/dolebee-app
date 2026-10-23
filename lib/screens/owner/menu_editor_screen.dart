import 'package:flutter/material.dart';

import '../../models/menu_item.dart';
import '../../state/app_store.dart';
import '../theme.dart';

/// Lets the owner set real names and prices, mark items sold out, and add
/// or remove items without any coding.
const _defaultCategories = ['Chicken', 'Buckets', 'Sides', 'Drinks'];

class MenuEditorScreen extends StatelessWidget {
  final AppStore store;
  const MenuEditorScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Add item'),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => store.menu.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('Your menu is empty. Add your items one by one, or start from the '
                        'sample menu and change the names and prices.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: store.loadSampleMenu, child: const Text('Load sample menu')),
                  ]),
                ),
              )
            : ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
          children: [
            for (final category in store.categories) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
                child: Text(category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              Card(
                color: Colors.white,
                child: Column(children: [
                  for (final item in store.menu.where((m) => m.category == category))
                    ListTile(
                      title: Text(item.name),
                      subtitle: Text(item.soldOut ? '${peso(item.pricePhp)} · Sold out' : peso(item.pricePhp)),
                      onTap: () => _edit(context, item),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Text('Available', style: TextStyle(fontSize: 12)),
                        Switch(
                          value: !item.soldOut,
                          onChanged: (on) => store.saveMenuItem(item.copyWith(soldOut: !on)),
                        ),
                      ]),
                    ),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context, MenuItem? item) async {
    final name = TextEditingController(text: item?.name);
    final price = TextEditingController(text: item?.pricePhp.toString());
    final categories = {..._defaultCategories, ...store.categories}.toList();
    var category = item?.category ?? categories.first;
    final form = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(item == null ? 'Add item' : 'Edit item'),
          content: Form(
            key: form,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price', prefixText: '₱ '),
                validator: (v) => (int.tryParse(v!) ?? 0) > 0 ? null : 'Enter a price',
              ),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  for (final c in categories) DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (c) => setState(() => category = c!),
              ),
            ]),
          ),
          actions: [
            if (item != null)
              TextButton(
                onPressed: () {
                  store.deleteMenuItem(item.id);
                  Navigator.of(context).pop();
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (!form.currentState!.validate()) return;
                store.saveMenuItem(MenuItem(
                  id: item?.id ?? 'm${DateTime.now().millisecondsSinceEpoch}',
                  name: name.text.trim(),
                  category: category,
                  pricePhp: int.parse(price.text),
                  photoUrl: item?.photoUrl,
                  soldOut: item?.soldOut ?? false,
                ));
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
