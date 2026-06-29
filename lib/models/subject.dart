import 'package:hive/hive.dart';

part 'subject.g.dart';

@HiveType(typeId: 1)
class Subject extends HiveObject {
  Subject({
    required this.id,
    required this.code,
    required this.libelle,
    required this.coefficient,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String code;

  @HiveField(2)
  final String libelle;

  @HiveField(3)
  final double coefficient;

  Subject copyWith({
    String? id,
    String? code,
    String? libelle,
    double? coefficient,
  }) {
    return Subject(
      id: id ?? this.id,
      code: code ?? this.code,
      libelle: libelle ?? this.libelle,
      coefficient: coefficient ?? this.coefficient,
    );
  }
}
