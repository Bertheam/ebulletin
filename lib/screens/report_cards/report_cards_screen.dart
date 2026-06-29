import 'package:flutter/material.dart';

import '../../widgets/app_drawer.dart';
import '../../widgets/empty_state.dart';

class ReportCardsScreen extends StatelessWidget {
  const ReportCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulletins'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: const EmptyState(
        icon: Icons.bar_chart_outlined,
        message: 'L\'ecran des bulletins sera implemente dans EB-9.',
      ),
    );
  }
}
