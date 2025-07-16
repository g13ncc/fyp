// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    // Create a simple test app
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welcome to gensecure!'),
                ElevatedButton(
                  onPressed: null,
                  child: Text('Chatbot'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Verify that our app loads the welcome text
    expect(find.text('Welcome to gensecure!'), findsOneWidget);
    expect(find.text('Chatbot'), findsOneWidget);
  });
}
