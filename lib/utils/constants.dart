class AppConstants {
  const AppConstants._();

  static const String studentsBox = 'students';
  static const String subjectsBox = 'subjects';
  static const String gradesBox = 'grades';

  static const List<String> periodes = [
    'Trimestre 1',
    'Trimestre 2',
    'Trimestre 3',
  ];

  static const List<String> classes = [
    '6eme',
    '5eme',
    '4eme',
    '3eme',
    'Seconde',
    'Premiere',
    'Terminale A',
    'Terminale C',
    'Terminale D',
  ];

  static const List<Map<String, dynamic>> defaultSubjects = [
    {'code': 'MATH', 'libelle': 'Mathematiques', 'coefficient': 4.0},
    {'code': 'PHYS', 'libelle': 'Physique-Chimie', 'coefficient': 3.0},
    {'code': 'SVT', 'libelle': 'Sciences de la Vie', 'coefficient': 2.0},
    {'code': 'FRAN', 'libelle': 'Francais', 'coefficient': 4.0},
    {'code': 'HIST', 'libelle': 'Histoire-Geographie', 'coefficient': 2.0},
    {'code': 'ANGL', 'libelle': 'Anglais', 'coefficient': 3.0},
    {'code': 'EPS', 'libelle': 'Education Physique', 'coefficient': 1.0},
  ];

  static const int primaryColor = 0xFF0553B1;
  static const int secondaryColor = 0xFF00B4AB;
  static const int accentColor = 0xFF54C5F8;
}
