import 'package:flutter/material.dart';

import '../../models/student.dart';
import '../../services/grade_service.dart';
import '../../services/student_service.dart';
import '../../services/subject_service.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StudentService _studentService = StudentService();
  final SubjectService _subjectService = SubjectService();
  final GradeService _gradeService = GradeService();

  int _totalStudents = 0;
  int _totalSubjects = 0;
  int _totalGrades = 0;
  List<Student> _recentStudents = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final students = _studentService.getAll();

    if (!mounted) {
      return;
    }

    setState(() {
      _totalStudents = students.length;
      _totalSubjects = _subjectService.getAll().length;
      _totalGrades = _gradeService.getAll().length;
      _recentStudents = students.reversed.take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'eBulletin',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Gestion des bulletins scolaires',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.3,
                children: [
                  StatCard(
                    label: 'Élèves',
                    value: _totalStudents,
                    icon: Icons.people,
                    color: colorScheme.primary,
                  ),
                  StatCard(
                    label: 'Matières',
                    value: _totalSubjects,
                    icon: Icons.book,
                    color: colorScheme.secondary,
                  ),
                  StatCard(
                    label: 'Notes',
                    value: _totalGrades,
                    icon: Icons.description,
                    color: Colors.orange,
                  ),
                  const StatCard(
                    label: 'Bulletins',
                    value: 0,
                    icon: Icons.bar_chart,
                    color: Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Derniers élèves ajoutés',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_recentStudents.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Aucun élève enregistré.',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  ),
                )
              else
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentStudents.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final student = _recentStudents[index];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(
                            student.prenom[0].toUpperCase(),
                            style: TextStyle(color: colorScheme.primary),
                          ),
                        ),
                        title: Text(
                          student.fullName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${student.classe}  •  ${student.matricule}',
                        ),
                        trailing: Chip(
                          label: Text(
                            student.classe,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
