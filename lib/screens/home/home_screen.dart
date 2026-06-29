import 'package:flutter/material.dart';

import '../../widgets/app_drawer.dart';
import '../../widgets/stat_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
      body: SingleChildScrollView(
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
            const SizedBox(height: 4),
            Text(
              'Base du projet Phase I en place. Les ecrans metier arrivent dans les lots suivants.',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: [
                StatCard(
                  label: 'Eleves',
                  value: 0,
                  icon: Icons.people_outline,
                  color: colorScheme.primary,
                ),
                StatCard(
                  label: 'Matieres',
                  value: 0,
                  icon: Icons.book_outlined,
                  color: colorScheme.secondary,
                ),
                const StatCard(
                  label: 'Notes',
                  value: 0,
                  icon: Icons.description_outlined,
                  color: Colors.orange,
                ),
                const StatCard(
                  label: 'Bulletins',
                  value: 0,
                  icon: Icons.bar_chart_outlined,
                  color: Colors.teal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
