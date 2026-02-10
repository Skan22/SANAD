import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:second_voice/main.dart';

void main() {
  testWidgets('App renders with title and empty state', (tester) async {
    await tester.pumpWidget(const SecondVoiceApp());
    await tester.pumpAndSettle();

    // App bar title
    expect(find.text('Second Voice'), findsOneWidget);

    // Empty state prompt
    expect(find.text('Tap the microphone to start'), findsOneWidget);

    // Mic button is present
    expect(find.byIcon(Icons.mic), findsOneWidget);
  });
}
