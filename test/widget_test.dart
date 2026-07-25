import 'package:flutter_test/flutter_test.dart';

import 'package:portal_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PortalApp());
    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(PortalApp), findsOneWidget);
  });
}
