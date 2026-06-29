import 'dart:io';

import 'package:ebulletin/models/grade.dart';
import 'package:ebulletin/models/student.dart';
import 'package:ebulletin/models/subject.dart';
import 'package:ebulletin/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:ebulletin/app.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('ebulletin_widget_test_');
    Hive.init(tempDir.path);

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(StudentAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SubjectAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(GradeAdapter());
    }

    await Hive.openBox<Student>(AppConstants.studentsBox);
    await Hive.openBox<Subject>(AppConstants.subjectsBox);
    await Hive.openBox<Grade>(AppConstants.gradesBox);
  });

  tearDown(() async {
    await Hive.box<Student>(AppConstants.studentsBox).clear();
    await Hive.box<Subject>(AppConstants.subjectsBox).clear();
    await Hive.box<Grade>(AppConstants.gradesBox).clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  testWidgets('renders dashboard shell', (WidgetTester tester) async {
    await tester.pumpWidget(const EBulletinApp());

    expect(find.text('Tableau de bord'), findsOneWidget);
    expect(find.text('eBulletin'), findsOneWidget);
    expect(find.text('Derniers eleves ajoutes'), findsOneWidget);
    expect(find.text('Aucun eleve enregistre.'), findsOneWidget);
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
    expect(find.text('Eleves (0)'), findsOneWidget);
    expect(
      find.text('Aucun eleve. Appuyez sur + pour en ajouter.'),
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
