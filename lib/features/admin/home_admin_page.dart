import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/styles.dart';
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
            style: TextButton.styleFrom(foregroundColor: AppColors.primaryGreen),
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

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? startColor,
    Color? endColor,
  }) {
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        startColor ?? AppColors.primaryGreen,
        endColor ?? AppColors.primaryGreenLight,
      ],
    );

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColors.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppStyles.titleText,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppStyles.subtitleText.copyWith(color: AppColors.textMedium),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMedium),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.elevatedShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Tableau de bord admin',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Gérez les projets, utilisateurs, transactions et statistiques de la plateforme.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildMenuCard(
              icon: Icons.fact_check,
              title: 'Valider projets',
              subtitle: 'Approuver ou rejeter les nouveaux projets soumis.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ValidateProjectsPage()),
              ),
              startColor: const Color(0xFF4CAF50),
              endColor: const Color(0xFF81C784),
            ),
            const SizedBox(height: 14),
            _buildMenuCard(
              icon: Icons.people_alt,
              title: 'Gérer utilisateurs',
              subtitle: 'Activer, désactiver et consulter les comptes utilisateurs.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageUsersPage()),
              ),
              startColor: const Color(0xFF1E88E5),
              endColor: const Color(0xFF42A5F5),
            ),
            const SizedBox(height: 14),
            _buildMenuCard(
              icon: Icons.swap_horiz,
              title: 'Transactions',
              subtitle: 'Voir l’historique complet des investissements.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageTransactionsPage()),
              ),
              startColor: const Color(0xFF8E24AA),
              endColor: const Color(0xFFBA68C8),
            ),
            const SizedBox(height: 14),
            _buildMenuCard(
              icon: Icons.bar_chart,
              title: 'Statistiques',
              subtitle: 'Accéder aux KPI et à la vue globale de GreenFund.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsPage()),
              ),
              startColor: const Color(0xFFFFA000),
              endColor: const Color(0xFFFFC107),
            ),
          ],
        ),
      ),
    );
  }
}


