import 'package:flutter/material.dart';

import 'screens/grades/grades_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/report_cards/report_cards_screen.dart';
import 'screens/students/students_screen.dart';
import 'screens/subjects/subjects_screen.dart';
import 'utils/constants.dart';

class EBulletinApp extends StatelessWidget {
  const EBulletinApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(AppConstants.primaryColor),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'eBulletin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.surface,
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
        cardTheme: const CardThemeData(elevation: 1, margin: EdgeInsets.zero),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colorScheme.surfaceContainerLowest,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/students': (context) => const StudentsScreen(),
        '/subjects': (context) => const SubjectsScreen(),
        '/grades': (context) => const GradesScreen(),
        '/report-cards': (context) => const ReportCardsScreen(),
      },
    );
  }
}
