import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/subject.dart';
import '../utils/constants.dart';

class DuplicateSubjectCodeException implements Exception {
  const DuplicateSubjectCodeException(this.code);

  final String code;
}

class SubjectService {
  Box<Subject> get _box => Hive.box<Subject>(AppConstants.subjectsBox);

  final Uuid _uuid = const Uuid();

  List<Subject> getAll() => _box.values.toList();

  Subject? getById(String id) {
    try {
      return _box.values.firstWhere((subject) => subject.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Subject> add({
    required String code,
    required String libelle,
    required double coefficient,
  }) async {
    final normalizedCode = code.trim().toUpperCase();
    final exists = _box.values.any(
      (subject) => subject.code.trim().toUpperCase() == normalizedCode,
    );
    if (exists) {
      throw DuplicateSubjectCodeException(normalizedCode);
    }

    final subject = Subject(
      id: _uuid.v4(),
      code: normalizedCode,
      libelle: libelle,
      coefficient: coefficient,
    );

    await _box.put(subject.id, subject);
    return subject;
  }

  Future<void> update(Subject subject) async {
    final normalizedCode = subject.code.trim().toUpperCase();
    final exists = _box.values.any(
      (item) =>
          item.id != subject.id &&
          item.code.trim().toUpperCase() == normalizedCode,
    );
    if (exists) {
      throw DuplicateSubjectCodeException(normalizedCode);
    }

    await _box.put(subject.id, subject);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> initDefaults() async {
    if (_box.isNotEmpty) {
      return;
    }

    for (final item in AppConstants.defaultSubjects) {
      await add(
        code: item['code'] as String,
        libelle: item['libelle'] as String,
        coefficient: item['coefficient'] as double,
      );
    }
  }
}
