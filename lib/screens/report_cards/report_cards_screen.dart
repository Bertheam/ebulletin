import 'package:flutter/material.dart';

import '../../models/report_card.dart';
import '../../models/student.dart';
import '../../services/grade_service.dart';
import '../../services/report_card_service.dart';
import '../../services/student_service.dart';
import '../../services/subject_service.dart';
import '../../utils/constants.dart';
import '../../widgets/app_drawer.dart';

class ReportCardsScreen extends StatefulWidget {
  const ReportCardsScreen({super.key});

  @override
  State<ReportCardsScreen> createState() => _ReportCardsScreenState();
}

class _ReportCardsScreenState extends State<ReportCardsScreen> {
  late final ReportCardService _reportCardService;
  final StudentService _studentService = StudentService();

  List<Student> _students = [];
  Student? _selectedStudent;
  String _selectedPeriode = AppConstants.periodes.first;
  ReportCard? _reportCard;
  int? _rang;

  @override
  void initState() {
    super.initState();
    _reportCardService = ReportCardService(
      gradeService: GradeService(),
      subjectService: SubjectService(),
      studentService: _studentService,
    );
    _students = _studentService.getAll();
  }

  void _generate() {
    if (_selectedStudent == null) {
      setState(() {
        _reportCard = null;
        _rang = null;
      });
      return;
    }

    final reportCard = _reportCardService.generate(
      _selectedStudent!.id,
      _selectedPeriode,
    );

    int? rank;
    if (reportCard != null) {
      final ranks = _reportCardService.getRanks(
        reportCard.classe,
        _selectedPeriode,
      );
      rank = ranks[_selectedStudent!.id];
    }

    setState(() {
      _reportCard = reportCard;
      _rang = rank;
    });
  }

  Color _mentionColor(String mention) {
    switch (mention) {
      case 'Très Bien':
        return Colors.green.shade700;
      case 'Bien':
        return Colors.blue.shade700;
      case 'Assez Bien':
        return Colors.teal.shade700;
      case 'Passable':
        return Colors.orange.shade700;
      default:
        return Colors.red.shade700;
    }
  }

  Color _noteColor(double note) {
    if (note >= 14) {
      return Colors.green;
    }
    if (note >= 10) {
      return Colors.orange;
    }
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulletins'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_reportCard != null)
            IconButton(
              icon: const Icon(Icons.print),
              tooltip: 'Imprimer',
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Impression en cours...')),
              ),
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<Student>(
              initialValue: _selectedStudent,
              decoration: const InputDecoration(
                labelText: 'Sélectionner un élève',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              hint: const Text('Choisir un élève...'),
              items: _students
                  .map(
                    (student) => DropdownMenuItem<Student>(
                      value: student,
                      child: Text('${student.fullName} - ${student.classe}'),
                    ),
                  )
                  .toList(),
              onChanged: (student) {
                setState(() => _selectedStudent = student);
                _generate();
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedPeriode,
              decoration: const InputDecoration(
                labelText: 'Période',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              items: AppConstants.periodes
                  .map(
                    (periode) => DropdownMenuItem<String>(
                      value: periode,
                      child: Text(periode),
                    ),
                  )
                  .toList(),
              onChanged: (periode) {
                setState(() => _selectedPeriode = periode!);
                _generate();
              },
            ),
            const SizedBox(height: 20),
            if (_selectedStudent == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'Sélectionnez un élève pour générer son bulletin.',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else if (_reportCard == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Aucune note pour cette période.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BULLETIN DE NOTES SCOLAIRES',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${_reportCard!.classe}  •  ${_reportCard!.periode}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Élève : ${_reportCard!.student}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text('Matricule : ${_reportCard!.matricule}'),
                    if (_rang != null) Text('Rang : ${_rang}e dans la classe'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    Container(
                      color: Colors.grey.shade100,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              'Matière',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: Text(
                              'Coef',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            child: Text(
                              'Note',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            child: Text(
                              'Pts',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    ..._reportCard!.lines.asMap().entries.map((entry) {
                      final index = entry.key;
                      final line = entry.value;
                      return Container(
                        color: index.isEven
                            ? Colors.white
                            : Colors.grey.shade50,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    line.subject,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    line.appreciation,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                '${line.coefficient}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            SizedBox(
                              width: 50,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _noteColor(line.note),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${line.note}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 50,
                              child: Text(
                                '${line.noteCoeff}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'MOYENNE',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            '${_reportCard!.moyenne}/20',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'MENTION',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _mentionColor(
                                _reportCard!.mention,
                              ).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _mentionColor(_reportCard!.mention),
                              ),
                            ),
                            child: Text(
                              _reportCard!.mention,
                              style: TextStyle(
                                color: _mentionColor(_reportCard!.mention),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
