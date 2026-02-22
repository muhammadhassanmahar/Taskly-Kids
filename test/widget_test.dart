import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(MyApp());

    // First frame (Splash screen)
    await tester.pump();

    // Check if MaterialApp is loaded
    expect(find.byType(MaterialApp), findsOneWidget);

    // Check if splash image widget exists
    expect(find.byType(Image), findsOneWidget);
  });
}
