import 'package:flutter/material.dart';

import '../../models/student.dart';
import '../../services/student_service.dart';
import '../../utils/constants.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/empty_state.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final StudentService _service = StudentService();
  final TextEditingController _searchCtrl = TextEditingController();

  List<Student> _all = [];
  List<Student> _displayed = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _load() {
    setState(() {
      _all = _service.getAll();
      _displayed = List<Student>.from(_all);
    });
  }

  void _onSearch(String query) {
    setState(() {
      _displayed = query.isEmpty
          ? List<Student>.from(_all)
          : _service.search(query);
    });
  }

  void _openForm({Student? student}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _StudentForm(student: student, onSaved: _load),
    );
  }

  void _confirmDelete(Student student) {
    final messenger = ScaffoldMessenger.of(context);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Supprimer ${student.fullName} ?\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _service.delete(student.id);
              _load();
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Élève supprimé'),
                  backgroundColor: Colors.red,
                ),
              );
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
        title: Text('Élèves (${_all.length})'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Rechercher par nom, classe, matricule...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchCtrl.clear();
                          _onSearch('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          Expanded(
            child: _displayed.isEmpty
                ? EmptyState(
                    icon: Icons.people_outline,
                    message: _searchCtrl.text.isNotEmpty
                        ? 'Aucun résultat pour "${_searchCtrl.text}"'
                        : 'Aucun élève. Appuyez sur + pour en ajouter.',
                  )
                : ListView.builder(
                    itemCount: _displayed.length,
                    itemBuilder: (context, index) {
                      final student = _displayed[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            child: Text(student.prenom[0].toUpperCase()),
                          ),
                          title: Text(
                            student.fullName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${student.classe}  •  ${student.matricule}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _openForm(student: student),
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.blue,
                                ),
                              ),
                              IconButton(
                                onPressed: () => _confirmDelete(student),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StudentForm extends StatefulWidget {
  const _StudentForm({this.student, required this.onSaved});

  final Student? student;
  final VoidCallback onSaved;

  @override
  State<_StudentForm> createState() => _StudentFormState();
}

class _StudentFormState extends State<_StudentForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nomCtrl = TextEditingController();
  final TextEditingController _prenomCtrl = TextEditingController();
  final TextEditingController _matricCtrl = TextEditingController();
  final TextEditingController _dateCtrl = TextEditingController();
  final StudentService _service = StudentService();

  String _classe = AppConstants.classes.first;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      final student = widget.student!;
      _nomCtrl.text = student.nom;
      _prenomCtrl.text = student.prenom;
      _matricCtrl.text = student.matricule;
      _dateCtrl.text = student.dateNaissance;
      _classe = student.classe;
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _matricCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (widget.student == null) {
        await _service.add(
          matricule: _matricCtrl.text.trim(),
          nom: _nomCtrl.text.trim(),
          prenom: _prenomCtrl.text.trim(),
          classe: _classe,
          dateNaissance: _dateCtrl.text,
        );
      } else {
        await _service.update(
          widget.student!.copyWith(
            matricule: _matricCtrl.text.trim(),
            nom: _nomCtrl.text.trim(),
            prenom: _prenomCtrl.text.trim(),
            classe: _classe,
            dateNaissance: _dateCtrl.text,
          ),
        );
      }
    } on DuplicateStudentMatriculeException catch (error) {
      setState(() => _saving = false);
      messenger.showSnackBar(
        SnackBar(content: Text('Matricule déjà utilisé : ${error.matricule}')),
      );
      return;
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
                widget.student == null
                    ? 'Ajouter un élève'
                    : 'Modifier l\'élève',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              const SizedBox(height: 8),
              TextFormField(
                controller: _matricCtrl,
                decoration: const InputDecoration(
                  labelText: 'Matricule *',
                  hintText: 'EL-2024-001',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Obligatoire' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nomCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nom *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Obligatoire' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _prenomCtrl,
                decoration: const InputDecoration(
                  labelText: 'Prénom *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Obligatoire' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _classe,
                decoration: const InputDecoration(
                  labelText: 'Classe *',
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.classes
                    .map(
                      (classe) =>
                          DropdownMenuItem(value: classe, child: Text(classe)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _classe = value!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date de naissance',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2005),
                    firstDate: DateTime(1980),
                    lastDate: DateTime.now(),
                  );

                  if (date != null) {
                    setState(() {
                      _dateCtrl.text =
                          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          widget.student == null ? 'Ajouter' : 'Enregistrer',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
