import 'package:flutter/material.dart';

import '../../widgets/app_drawer.dart';
import '../../widgets/empty_state.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eleves'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: const EmptyState(
        icon: Icons.people_outline,
        message: 'L\'ecran de gestion des eleves sera implemente dans EB-6.',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
