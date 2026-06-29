import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'models/grade.dart';
import 'models/student.dart';
import 'models/subject.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(StudentAdapter());
  Hive.registerAdapter(SubjectAdapter());
  Hive.registerAdapter(GradeAdapter());

  await Hive.openBox<Student>(AppConstants.studentsBox);
  await Hive.openBox<Subject>(AppConstants.subjectsBox);
  await Hive.openBox<Grade>(AppConstants.gradesBox);

  runApp(const EBulletinApp());
}
