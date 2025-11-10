import 'package:flutter/material.dart';
import '../../widgets/green_button.dart';
import 'manage_transactions_page.dart';
import 'manage_users_page.dart';
import 'stats_page.dart';
import 'validate_projects_page.dart';

/// Accueil Admin: accès aux différents écrans d'administration.
class HomeAdminPage extends StatelessWidget {
  const HomeAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Espace Admin')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GreenButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ValidateProjectsPage())), child: const Text('Valider projets')),
            const SizedBox(height: 12),
            GreenButton(outlined: true, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersPage())), child: const Text('Gérer utilisateurs')),
            const SizedBox(height: 12),
            GreenButton(outlined: true, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageTransactionsPage())), child: const Text('Transactions')),
            const SizedBox(height: 12),
            GreenButton(outlined: true, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsPage())), child: const Text('Statistiques')),
          ],
        ),
      ),
    );
  }
}


