import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gida_dedektifi/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen shows title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    // Verify that the title is shown.
    expect(find.text('Gıda Dedektifi'), findsOneWidget);
    expect(find.textContaining('İsrafı önlemek'), findsOneWidget);
  });
}
