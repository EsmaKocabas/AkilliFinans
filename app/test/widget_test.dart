// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:akilli_finans_mobile/akilli_finans_app.dart';

void main() {
  testWidgets('Akilli Finans app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AkilliFinansApp());
    await tester.pumpAndSettle();

    // Verify that core shell widgets are rendered.
    expect(find.textContaining('Akilli Finans -'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
