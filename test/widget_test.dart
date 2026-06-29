import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ebulletin/app.dart';

void main() {
  testWidgets('renders dashboard shell', (WidgetTester tester) async {
    await tester.pumpWidget(const EBulletinApp());

    expect(find.text('Tableau de bord'), findsOneWidget);
    expect(find.text('eBulletin'), findsOneWidget);
  });

  testWidgets('navigates through drawer routes', (WidgetTester tester) async {
    await tester.pumpWidget(const EBulletinApp());

    expect(find.text('Tableau de bord'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: find.byType(Drawer), matching: find.text('Eleves')),
    );
    await tester.pumpAndSettle();
    expect(
      find.text("L'ecran de gestion des eleves sera implemente dans EB-6."),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: find.byType(Drawer), matching: find.text('Matieres')),
    );
    await tester.pumpAndSettle();
    expect(
      find.text("L'ecran de gestion des matieres sera implemente dans EB-7."),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: find.byType(Drawer), matching: find.text('Notes')),
    );
    await tester.pumpAndSettle();
    expect(
      find.text("L'ecran de saisie des notes sera implemente dans EB-8."),
      findsOneWidget,
    );
  });
}
