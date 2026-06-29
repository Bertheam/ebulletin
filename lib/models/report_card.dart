class ReportCardLine {
  const ReportCardLine({
    required this.subject,
    required this.code,
    required this.coefficient,
    required this.note,
    required this.noteCoeff,
    required this.appreciation,
  });

  final String subject;
  final String code;
  final double coefficient;
  final double note;
  final double noteCoeff;
  final String appreciation;
}

class ReportCard {
  const ReportCard({
    required this.student,
    required this.matricule,
    required this.classe,
    required this.periode,
    required this.lines,
    required this.moyenne,
    required this.mention,
    this.rang,
  });

  final String student;
  final String matricule;
  final String classe;
  final String periode;
  final List<ReportCardLine> lines;
  final double moyenne;
  final String mention;
  final int? rang;
}
