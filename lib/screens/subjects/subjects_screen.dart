import 'package:flutter/material.dart';

import '../../widgets/app_drawer.dart';
import '../../widgets/empty_state.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matieres'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: const EmptyState(
        icon: Icons.book_outlined,
        message: 'L\'ecran de gestion des matieres sera implemente dans EB-7.',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
