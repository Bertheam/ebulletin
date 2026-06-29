import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/student.dart';
import '../utils/constants.dart';

class DuplicateStudentMatriculeException implements Exception {
  const DuplicateStudentMatriculeException(this.matricule);

  final String matricule;
}

class StudentService {
  Box<Student> get _box => Hive.box<Student>(AppConstants.studentsBox);

  final Uuid _uuid = const Uuid();

  List<Student> getAll() => _box.values.toList();

  Student? getById(String id) {
    try {
      return _box.values.firstWhere((student) => student.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Student> getByClasse(String classe) =>
      _box.values.where((student) => student.classe == classe).toList();

  List<Student> search(String query) {
    final normalized = query.toLowerCase().trim();
    if (normalized.isEmpty) {
      return getAll();
    }

    return _box.values.where((student) {
      return student.nom.toLowerCase().contains(normalized) ||
          student.prenom.toLowerCase().contains(normalized) ||
          student.matricule.toLowerCase().contains(normalized) ||
          student.classe.toLowerCase().contains(normalized);
    }).toList();
  }

  List<String> getClasses() {
    final classes = _box.values
        .map((student) => student.classe)
        .toSet()
        .toList();
    classes.sort();
    return classes;
  }

  Future<Student> add({
    required String matricule,
    required String nom,
    required String prenom,
    required String classe,
    required String dateNaissance,
  }) async {
    final normalizedMatricule = matricule.trim().toLowerCase();
    final exists = _box.values.any(
      (student) =>
          student.matricule.trim().toLowerCase() == normalizedMatricule,
    );
    if (exists) {
      throw DuplicateStudentMatriculeException(matricule.trim());
    }

    final student = Student(
      id: _uuid.v4(),
      matricule: matricule.trim(),
      nom: nom,
      prenom: prenom,
      classe: classe,
      dateNaissance: dateNaissance,
    );

    await _box.put(student.id, student);
    return student;
  }

  Future<void> update(Student student) async {
    final normalizedMatricule = student.matricule.trim().toLowerCase();
    final exists = _box.values.any(
      (item) =>
          item.id != student.id &&
          item.matricule.trim().toLowerCase() == normalizedMatricule,
    );
    if (exists) {
      throw DuplicateStudentMatriculeException(student.matricule.trim());
    }

    await _box.put(student.id, student);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
