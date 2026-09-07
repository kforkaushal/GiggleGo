import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gigglego/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GiggleGoApp());
    // The app should render without throwing.
    expect(find.byType(MaterialApp), findsOneWidget);

    // Fast forward past splash timer and verify home renders
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
