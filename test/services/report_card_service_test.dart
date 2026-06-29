import 'dart:io';

import 'package:ebulletin/models/grade.dart';
import 'package:ebulletin/models/student.dart';
import 'package:ebulletin/models/subject.dart';
import 'package:ebulletin/services/grade_service.dart';
import 'package:ebulletin/services/report_card_service.dart';
import 'package:ebulletin/services/student_service.dart';
import 'package:ebulletin/services/subject_service.dart';
import 'package:ebulletin/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late Directory tempDir;
  late StudentService studentService;
  late SubjectService subjectService;
  late GradeService gradeService;
  late ReportCardService reportCardService;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('ebulletin_test_');
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

  setUp(() async {
    await Hive.box<Student>(AppConstants.studentsBox).clear();
    await Hive.box<Subject>(AppConstants.subjectsBox).clear();
    await Hive.box<Grade>(AppConstants.gradesBox).clear();

    studentService = StudentService();
    subjectService = SubjectService();
    gradeService = GradeService();
    reportCardService = ReportCardService(
      gradeService: gradeService,
      subjectService: subjectService,
      studentService: studentService,
    );
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('initDefaults seeds the seven default subjects once', () async {
    await subjectService.initDefaults();
    expect(subjectService.getAll(), hasLength(7));

    await subjectService.initDefaults();
    expect(subjectService.getAll(), hasLength(7));
  });

  test('generate computes moyenne mention and rank from stored data', () async {
    final math = await subjectService.add(
      code: 'MATH',
      libelle: 'Mathematiques',
      coefficient: 4,
    );
    final french = await subjectService.add(
      code: 'FRAN',
      libelle: 'Francais',
      coefficient: 2,
    );

    final studentA = await studentService.add(
      matricule: 'EL-001',
      nom: 'Diallo',
      prenom: 'Awa',
      classe: 'Terminale A',
      dateNaissance: '2005-02-01',
    );
    final studentB = await studentService.add(
      matricule: 'EL-002',
      nom: 'Traore',
      prenom: 'Moussa',
      classe: 'Terminale A',
      dateNaissance: '2004-11-09',
    );

    await gradeService.add(
      studentId: studentA.id,
      subjectId: math.id,
      note: 15,
      periode: 'Trimestre 1',
    );
    await gradeService.add(
      studentId: studentA.id,
      subjectId: french.id,
      note: 12,
      periode: 'Trimestre 1',
      appreciation: 'Bon effort',
    );
    await gradeService.add(
      studentId: studentB.id,
      subjectId: math.id,
      note: 10,
      periode: 'Trimestre 1',
    );
    await gradeService.add(
      studentId: studentB.id,
      subjectId: french.id,
      note: 11,
      periode: 'Trimestre 1',
    );

    final reportCard = reportCardService.generate(studentA.id, 'Trimestre 1');
    final ranks = reportCardService.getRanks('Terminale A', 'Trimestre 1');

    expect(reportCard, isNotNull);
    expect(reportCard!.student, 'Awa Diallo');
    expect(reportCard.moyenne, 14.0);
    expect(reportCard.mention, 'Bien');
    expect(reportCard.lines, hasLength(2));
    expect(reportCard.lines.first.subject, 'Francais');
    expect(reportCard.lines.first.appreciation, 'Bon effort');
    expect(reportCard.lines.last.noteCoeff, 60.0);
    expect(ranks[studentA.id], 1);
    expect(ranks[studentB.id], 2);
  });
}
