import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/grade.dart';
import '../utils/constants.dart';

class GradeService {
  Box<Grade> get _box => Hive.box<Grade>(AppConstants.gradesBox);

  final Uuid _uuid = const Uuid();

  List<Grade> getAll() => _box.values.toList();

  List<Grade> getByStudent(String studentId) =>
      _box.values.where((grade) => grade.studentId == studentId).toList();

  List<Grade> getByStudentAndPeriode(String studentId, String periode) {
    return _box.values
        .where(
          (grade) => grade.studentId == studentId && grade.periode == periode,
        )
        .toList();
  }

  Future<Grade> add({
    required String studentId,
    required String subjectId,
    required double note,
    required String periode,
    String appreciation = '',
  }) async {
    final grade = Grade(
      id: _uuid.v4(),
      studentId: studentId,
      subjectId: subjectId,
      note: note,
      appreciation: appreciation,
      periode: periode,
    );

    await _box.put(grade.id, grade);
    return grade;
  }

  Future<void> update(Grade grade) async {
    await _box.put(grade.id, grade);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
