import 'package:flutter_test/flutter_test.dart';

import 'package:ebulletin/app.dart';

void main() {
  testWidgets('renders dashboard shell', (WidgetTester tester) async {
    await tester.pumpWidget(const EBulletinApp());

    expect(find.text('Tableau de bord'), findsOneWidget);
    expect(find.text('eBulletin'), findsOneWidget);
  });
}
