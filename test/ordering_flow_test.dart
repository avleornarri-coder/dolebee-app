import 'package:dolebee_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('customer orders with cash on delivery', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DolebeeApp());
    await tester.tap(find.byTooltip('Add 1pc Chicken with Rice'));
    await tester.pump();
    expect(find.textContaining('View cart · 1 items · ₱99'), findsOneWidget);

    await tester.tap(find.textContaining('View cart'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Your name'), 'Ana');
    await tester.enterText(find.widgetWithText(TextFormField, 'Mobile number'), '09171234567');
    await tester.enterText(find.widgetWithText(TextFormField, 'Barangay and street'), 'Poblacion');
    await tester.scrollUntilVisible(find.textContaining('Place order'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.textContaining('Place order · ₱119'), findsOneWidget);

    await tester.tap(find.textContaining('Place order'));
    await tester.pumpAndSettle();
    expect(find.text('Order received'), findsOneWidget);
    expect(find.text('1 × 1pc Chicken with Rice'), findsOneWidget);
  });
}
