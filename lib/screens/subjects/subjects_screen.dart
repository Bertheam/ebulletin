import 'package:flutter/material.dart';

import '../../models/subject.dart';
import '../../services/subject_service.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/empty_state.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final SubjectService _service = SubjectService();
  List<Subject> _subjects = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() => _subjects = _service.getAll());
  }

  Color _coeffColor(double coeff) {
    if (coeff >= 4) {
      return Colors.red.shade600;
    }
    if (coeff >= 3) {
      return Colors.orange.shade600;
    }
    return Colors.green.shade600;
  }

  void _openForm({Subject? subject}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SubjectForm(subject: subject, onSaved: _load),
    );
  }

  void _confirmDelete(Subject subject) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la matiere'),
        content: Text('Supprimer ${subject.libelle} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _service.delete(subject.id);
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
        title: Text('Matieres (${_subjects.length})'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: _subjects.isEmpty
          ? const EmptyState(
              icon: Icons.book_outlined,
              message: 'Aucune matiere.',
            )
          : ListView.builder(
              itemCount: _subjects.length,
              itemBuilder: (context, index) {
                final subject = _subjects[index];
                final coeffColor = _coeffColor(subject.coefficient);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: coeffColor.withValues(alpha: 0.15),
                      child: Text(
                        subject.code.substring(0, 2),
                        style: TextStyle(
                          color: coeffColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(
                      subject.libelle,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('Code : ${subject.code}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: coeffColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: coeffColor),
                          ),
                          child: Text(
                            'Coef. ${subject.coefficient}',
                            style: TextStyle(
                              color: coeffColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _openForm(subject: subject),
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.blue,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _confirmDelete(subject),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SubjectForm extends StatefulWidget {
  const _SubjectForm({this.subject, required this.onSaved});

  final Subject? subject;
  final VoidCallback onSaved;

  @override
  State<_SubjectForm> createState() => _SubjectFormState();
}

class _SubjectFormState extends State<_SubjectForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _codeCtrl = TextEditingController();
  final TextEditingController _libCtrl = TextEditingController();
  final TextEditingController _coeffCtrl = TextEditingController();
  final SubjectService _service = SubjectService();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.subject != null) {
      _codeCtrl.text = widget.subject!.code;
      _libCtrl.text = widget.subject!.libelle;
      _coeffCtrl.text = widget.subject!.coefficient.toString();
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _libCtrl.dispose();
    _coeffCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _saving = true);
    final coeff = double.tryParse(_coeffCtrl.text) ?? 1.0;

    if (widget.subject == null) {
      await _service.add(
        code: _codeCtrl.text.trim().toUpperCase(),
        libelle: _libCtrl.text.trim(),
        coefficient: coeff,
      );
    } else {
      await _service.update(
        widget.subject!.copyWith(
          code: _codeCtrl.text.trim().toUpperCase(),
          libelle: _libCtrl.text.trim(),
          coefficient: coeff,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.subject == null
                  ? 'Ajouter une matiere'
                  : 'Modifier la matiere',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 8),
            TextFormField(
              controller: _codeCtrl,
              decoration: const InputDecoration(
                labelText: 'Code *',
                hintText: 'MATH',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Obligatoire' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _libCtrl,
              decoration: const InputDecoration(
                labelText: 'Libelle *',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Obligatoire' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _coeffCtrl,
              decoration: const InputDecoration(
                labelText: 'Coefficient * (1-10)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Obligatoire';
                }
                final coeff = double.tryParse(value);
                if (coeff == null || coeff < 1 || coeff > 10) {
                  return 'Entre 1 et 10';
                }
                return null;
              },
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
                    : Text(widget.subject == null ? 'Ajouter' : 'Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
