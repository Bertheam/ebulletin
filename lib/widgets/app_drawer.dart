import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(color: colorScheme.primary),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.school, color: Colors.white, size: 40),
                SizedBox(height: 8),
                Text(
                  'eBulletin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Gestion des bulletins',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: const [
                _DrawerItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Tableau de bord',
                  route: '/',
                ),
                _DrawerItem(
                  icon: Icons.people_outline,
                  label: 'Eleves',
                  route: '/students',
                ),
                _DrawerItem(
                  icon: Icons.book_outlined,
                  label: 'Matieres',
                  route: '/subjects',
                ),
                _DrawerItem(
                  icon: Icons.description_outlined,
                  label: 'Notes',
                  route: '/grades',
                ),
                _DrawerItem(
                  icon: Icons.bar_chart_outlined,
                  label: 'Bulletins',
                  route: '/report-cards',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Phase I',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
    final isActive = currentRoute == route;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: isActive ? colorScheme.primary : null),
      title: Text(
        label,
        style: isActive
            ? TextStyle(fontWeight: FontWeight.w600, color: colorScheme.primary)
            : null,
      ),
      selected: isActive,
      onTap: () {
        Navigator.pop(context);
        if (!isActive) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }
}
