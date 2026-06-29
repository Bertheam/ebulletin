import 'package:hive/hive.dart';

part 'grade.g.dart';

@HiveType(typeId: 2)
class Grade extends HiveObject {
  Grade({
    required this.id,
    required this.studentId,
    required this.subjectId,
    required this.note,
    required this.appreciation,
    required this.periode,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String studentId;

  @HiveField(2)
  final String subjectId;

  @HiveField(3)
  final double note;

  @HiveField(4)
  final String appreciation;

  @HiveField(5)
  final String periode;

  Grade copyWith({
    String? id,
    String? studentId,
    String? subjectId,
    double? note,
    String? appreciation,
    String? periode,
  }) {
    return Grade(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      subjectId: subjectId ?? this.subjectId,
      note: note ?? this.note,
      appreciation: appreciation ?? this.appreciation,
      periode: periode ?? this.periode,
    );
  }
}
