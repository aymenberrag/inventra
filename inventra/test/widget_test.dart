import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:inventra/main.dart';

void main() {
  testWidgets('App loads auth gate', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: InventraApp(),
      ),
    );

    expect(find.text('Inventra'), findsOneWidget);
  });
}
