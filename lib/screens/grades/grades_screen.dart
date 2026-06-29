import 'package:flutter/material.dart';

import '../../widgets/app_drawer.dart';
import '../../widgets/empty_state.dart';

class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: const EmptyState(
        icon: Icons.description_outlined,
        message: 'L\'ecran de saisie des notes sera implemente dans EB-8.',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
