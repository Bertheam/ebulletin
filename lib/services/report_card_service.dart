import '../models/grade.dart';
import '../models/report_card.dart';
import '../models/student.dart';
import '../models/subject.dart';
import 'grade_service.dart';
import 'student_service.dart';
import 'subject_service.dart';

class ReportCardService {
  ReportCardService({
    required GradeService gradeService,
    required SubjectService subjectService,
    required StudentService studentService,
  }) : _gradeService = gradeService,
       _subjectService = subjectService,
       _studentService = studentService;

  final GradeService _gradeService;
  final SubjectService _subjectService;
  final StudentService _studentService;

  ReportCard? generate(String studentId, String periode) {
    final Student? student = _studentService.getById(studentId);
    if (student == null) {
      return null;
    }

    final List<Grade> grades = _gradeService.getByStudentAndPeriode(
      studentId,
      periode,
    );
    final List<Subject> subjects = _subjectService.getAll();

    final List<ReportCardLine> lines = [];
    double totalPoints = 0;
    double totalCoeff = 0;

    for (final grade in grades) {
      Subject? subject;
      try {
        subject = subjects.firstWhere((item) => item.id == grade.subjectId);
      } catch (_) {
        continue;
      }

      final noteCoeff = grade.note * subject.coefficient;
      totalPoints += noteCoeff;
      totalCoeff += subject.coefficient;

      lines.add(
        ReportCardLine(
          subject: subject.libelle,
          code: subject.code,
          coefficient: subject.coefficient,
          note: grade.note,
          noteCoeff: double.parse(noteCoeff.toStringAsFixed(2)),
          appreciation: grade.appreciation.isNotEmpty
              ? grade.appreciation
              : getAppreciation(grade.note),
        ),
      );
    }

    lines.sort((left, right) => left.subject.compareTo(right.subject));

    final moyenne = totalCoeff > 0
        ? double.parse((totalPoints / totalCoeff).toStringAsFixed(2))
        : 0.0;

    return ReportCard(
      student: student.fullName,
      matricule: student.matricule,
      classe: student.classe,
      periode: periode,
      lines: lines,
      moyenne: moyenne,
      mention: getMention(moyenne),
    );
  }

  Map<String, int> getRanks(String classe, String periode) {
    final students = _studentService.getByClasse(classe);
    final moyennes = students
        .map(
          (student) => {
            'studentId': student.id,
            'moyenne': generate(student.id, periode)?.moyenne ?? 0.0,
          },
        )
        .toList();

    moyennes.sort(
      (left, right) =>
          (right['moyenne'] as double).compareTo(left['moyenne'] as double),
    );

    final ranks = <String, int>{};
    for (var index = 0; index < moyennes.length; index++) {
      ranks[moyennes[index]['studentId'] as String] = index + 1;
    }

    return ranks;
  }

  String getMention(double moyenne) {
    if (moyenne >= 16) {
      return 'Très Bien';
    }
    if (moyenne >= 14) {
      return 'Bien';
    }
    if (moyenne >= 12) {
      return 'Assez Bien';
    }
    if (moyenne >= 10) {
      return 'Passable';
    }
    return 'Insuffisant';
  }

  String getAppreciation(double note) {
    if (note >= 18) {
      return 'Excellent';
    }
    if (note >= 16) {
      return 'Très bien';
    }
    if (note >= 14) {
      return 'Bien';
    }
    if (note >= 12) {
      return 'Assez bien';
    }
    if (note >= 10) {
      return 'Passable';
    }
    return 'Insuffisant';
  }
}
