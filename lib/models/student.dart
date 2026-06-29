import 'package:hive/hive.dart';

part 'student.g.dart';

@HiveType(typeId: 0)
class Student extends HiveObject {
  Student({
    required this.id,
    required this.matricule,
    required this.nom,
    required this.prenom,
    required this.classe,
    required this.dateNaissance,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String matricule;

  @HiveField(2)
  final String nom;

  @HiveField(3)
  final String prenom;

  @HiveField(4)
  final String classe;

  @HiveField(5)
  final String dateNaissance;

  String get fullName => '$prenom $nom';

  Student copyWith({
    String? id,
    String? matricule,
    String? nom,
    String? prenom,
    String? classe,
    String? dateNaissance,
  }) {
    return Student(
      id: id ?? this.id,
      matricule: matricule ?? this.matricule,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      classe: classe ?? this.classe,
      dateNaissance: dateNaissance ?? this.dateNaissance,
    );
  }
}
