import 'package:flutter/material.dart';
import '../../widgets/green_button.dart';
import 'manage_transactions_page.dart';
import 'manage_users_page.dart';
import 'stats_page.dart';
import 'validate_projects_page.dart';
import '../../services/auth_service.dart';
import '../../screens/login_screen.dart';

/// Accueil Admin: accès aux différents écrans d'administration.
class HomeAdminPage extends StatelessWidget {
  const HomeAdminPage({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vous déconnecter de l\'espace admin ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Admin'),
        actions: [
          IconButton(
            tooltip: 'Déconnexion',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
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


