import 'package:flutter/material.dart';

import '../../models/grade.dart';
import '../../models/student.dart';
import '../../models/subject.dart';
import '../../services/grade_service.dart';
import '../../services/student_service.dart';
import '../../services/subject_service.dart';
import '../../utils/constants.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/empty_state.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  final GradeService _gradeService = GradeService();
  final StudentService _studentService = StudentService();
  final SubjectService _subjectService = SubjectService();

  List<Grade> _grades = [];
  List<Student> _students = [];
  List<Subject> _subjects = [];
  String _selectedPeriode = AppConstants.periodes.first;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _students = _studentService.getAll();
      _subjects = _subjectService.getAll();
      _grades = _gradeService
          .getAll()
          .where((grade) => grade.periode == _selectedPeriode)
          .toList();
    });
  }

  String _studentName(String id) {
    try {
      return _students.firstWhere((student) => student.id == id).fullName;
    } catch (_) {
      return 'Eleve inconnu';
    }
  }

  String _subjectName(String id) {
    try {
      return _subjects.firstWhere((subject) => subject.id == id).libelle;
    } catch (_) {
      return 'Matiere inconnue';
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

  void _openForm({Grade? grade}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _GradeForm(
        grade: grade,
        students: _students,
        subjects: _subjects,
        defaultPeriode: _selectedPeriode,
        onSaved: _load,
      ),
    );
  }

  void _confirmDelete(Grade grade) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la note'),
        content: const Text('Supprimer cette note definitivement ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _gradeService.delete(grade.id);
              _load();
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes (${_grades.length})'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Theme.of(context).colorScheme.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: AppConstants.periodes.map((periode) {
                final isSelected = _selectedPeriode == periode;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedPeriode = periode;
                    _load();
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: isSelected
                          ? const Border(
                              bottom: BorderSide(color: Colors.white, width: 3),
                            )
                          : null,
                    ),
                    child: Text(
                      periode,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white60,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: _grades.isEmpty
          ? EmptyState(
              icon: Icons.description_outlined,
              message: 'Aucune note pour $_selectedPeriode',
            )
          : ListView.builder(
              itemCount: _grades.length,
              itemBuilder: (context, index) {
                final grade = _grades[index];
                final noteColor = _noteColor(grade.note);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: noteColor.withValues(alpha: 0.15),
                      child: Text(
                        grade.note.toStringAsFixed(1),
                        style: TextStyle(
                          color: noteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(
                      _studentName(grade.studentId),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_subjectName(grade.subjectId)),
                        if (grade.appreciation.isNotEmpty)
                          Text(
                            grade.appreciation,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: noteColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${grade.note}/20',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _openForm(grade: grade),
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.blue,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _confirmDelete(grade),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: grade.appreciation.isNotEmpty,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _GradeForm extends StatefulWidget {
  const _GradeForm({
    this.grade,
    required this.students,
    required this.subjects,
    required this.defaultPeriode,
    required this.onSaved,
  });

  final Grade? grade;
  final List<Student> students;
  final List<Subject> subjects;
  final String defaultPeriode;
  final VoidCallback onSaved;

  @override
  State<_GradeForm> createState() => _GradeFormState();
}

class _GradeFormState extends State<_GradeForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _noteCtrl = TextEditingController();
  final TextEditingController _appCtrl = TextEditingController();
  final GradeService _service = GradeService();

  String? _studentId;
  String? _subjectId;
  late String _periode;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _periode = widget.defaultPeriode;
    if (widget.grade != null) {
      final grade = widget.grade!;
      _studentId = grade.studentId;
      _subjectId = grade.subjectId;
      _noteCtrl.text = grade.note.toString();
      _appCtrl.text = grade.appreciation;
      _periode = grade.periode;
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _appCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_studentId == null || _subjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selectionnez un eleve et une matiere')),
      );
      return;
    }

    setState(() => _saving = true);
    final note = double.parse(_noteCtrl.text);

    if (widget.grade == null) {
      await _service.add(
        studentId: _studentId!,
        subjectId: _subjectId!,
        note: note,
        periode: _periode,
        appreciation: _appCtrl.text.trim(),
      );
    } else {
      await _service.update(
        widget.grade!.copyWith(
          studentId: _studentId,
          subjectId: _subjectId,
          note: note,
          periode: _periode,
          appreciation: _appCtrl.text.trim(),
        ),
      );
    }

    if (mounted) {
      Navigator.pop(context);
    }
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.grade == null ? 'Saisir une note' : 'Modifier la note',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _studentId,
                decoration: const InputDecoration(
                  labelText: 'Eleve *',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Choisir un eleve'),
                items: widget.students
                    .map(
                      (student) => DropdownMenuItem(
                        value: student.id,
                        child: Text('${student.fullName} - ${student.classe}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _studentId = value),
                validator: (value) =>
                    value == null ? 'Selectionnez un eleve' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _subjectId,
                decoration: const InputDecoration(
                  labelText: 'Matiere *',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Choisir une matiere'),
                items: widget.subjects
                    .map(
                      (subject) => DropdownMenuItem(
                        value: subject.id,
                        child: Text(
                          '${subject.libelle} (Coef. ${subject.coefficient})',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _subjectId = value),
                validator: (value) =>
                    value == null ? 'Selectionnez une matiere' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _periode,
                decoration: const InputDecoration(
                  labelText: 'Periode *',
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.periodes
                    .map(
                      (periode) => DropdownMenuItem(
                        value: periode,
                        child: Text(periode),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _periode = value!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Note /20 *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Obligatoire';
                  }
                  final note = double.tryParse(value);
                  if (note == null || note < 0 || note > 20) {
                    return 'Entre 0 et 20';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _appCtrl,
                decoration: const InputDecoration(
                  labelText: 'Appreciation (optionnelle)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.grade == null ? 'Enregistrer' : 'Modifier'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
