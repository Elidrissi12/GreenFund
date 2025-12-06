import 'package:flutter/material.dart';
import '../../widgets/green_button.dart';
import '../../services/api_service.dart';
import '../../models/project.dart';
import '../../theme/colors.dart';
import 'create_project_page.dart';
import 'edit_project_page.dart';
import 'fundings_received_page.dart';
import '../../services/auth_service.dart';
import '../../screens/login_screen.dart';

/// Accueil Porteur: navigation vers les écrans du module.
class HomeOwnerPage extends StatefulWidget {
  const HomeOwnerPage({super.key});

  @override
  State<HomeOwnerPage> createState() => _HomeOwnerPageState();
}

class _HomeOwnerPageState extends State<HomeOwnerPage> {
  List<Project> _projects = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final projects = await ApiService.getMyProjects();
      setState(() {
        _projects = projects;
        _isLoading = false;
      });
    } catch (e) {
      String errorMessage = e.toString();
      // Nettoyer le message d'erreur pour l'affichage
      if (errorMessage.contains('No authentication token') || errorMessage.contains('Session expirée')) {
        errorMessage = 'Session expirée. Veuillez vous reconnecter.';
      } else if (errorMessage.contains('Accès refusé') || errorMessage.contains('403')) {
        errorMessage = 'Accès refusé. Vous devez être propriétaire de projet pour accéder à cette page.';
      } else if (errorMessage.contains('401')) {
        errorMessage = 'Non autorisé. Veuillez vous reconnecter.';
      }
      
      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });
    }
  }

  Future<void> _editProject(Project project) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProjectPage(project: project),
      ),
    );
    // Rafraîchir la liste si le projet a été modifié
    if (result == true) {
      _loadProjects();
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous quitter l\'espace porteur ?'),
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

  IconData _getEnergyIcon(String energy) {
    switch (energy.toUpperCase()) {
      case 'SOLAIRE':
        return Icons.wb_sunny;
      case 'EOLIENNE':
        return Icons.air;
      case 'BIOGAZ':
        return Icons.local_gas_station;
      default:
        return Icons.energy_savings_leaf;
    }
  }

  Color _getEnergyColor(String energy) {
    switch (energy.toUpperCase()) {
      case 'SOLAIRE':
        return const Color(0xFFFFC107);
      case 'EOLIENNE':
        return const Color(0xFF2196F3);
      case 'BIOGAZ':
        return const Color(0xFF9C27B0);
      default:
        return AppColors.primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Porteur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjects,
            tooltip: 'Actualiser',
          ),
          IconButton(
            tooltip: 'Déconnexion',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProjects,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section des actions principales
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CreateProjectPage()),
                          );
                          _loadProjects();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
                        label: const Text(
                          'Créer un projet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryGreen, width: 2),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FundingsReceivedPage()),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: Icon(Icons.account_balance_wallet, color: AppColors.primaryGreen, size: 24),
                        label: Text(
                          'Financements reçus',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Titre de section
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.folder_special, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Mes projets',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  if (_projects.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_projects.length}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Liste des projets
              _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _error != null
                      ? Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: AppColors.errorRed,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Erreur',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.textMedium),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _loadProjects,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                ),
                                child: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        )
                      : _projects.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: AppColors.cardShadow,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: 64,
                                    color: AppColors.textLight,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucun projet créé',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Créez votre premier projet pour commencer',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: AppColors.textMedium),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: _projects.map((project) {
                                final energyColor = _getEnergyColor(project.energyType);
                                final energyIcon = _getEnergyIcon(project.energyType);
                                final progressPercent = (project.progress * 100).toStringAsFixed(0);
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.cardGradient,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: AppColors.cardShadow,
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () => _editProject(project),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: energyColor.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Icon(energyIcon, color: energyColor, size: 24),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        project.title,
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                          color: AppColors.textDark,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          Icon(Icons.location_on, size: 14, color: AppColors.textMedium),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            '${project.city} • ${project.energyType}',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: AppColors.textMedium,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.edit),
                                                  onPressed: () => _editProject(project),
                                                  tooltip: 'Modifier',
                                                  color: AppColors.primaryGreen,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  '$progressPercent% financé',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.primaryGreen,
                                                  ),
                                                ),
                                                Text(
                                                  '${project.raisedAmount.toStringAsFixed(0)} / ${project.targetAmount.toStringAsFixed(0)} MAD',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: AppColors.textMedium,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: LinearProgressIndicator(
                                                value: project.progress,
                                                minHeight: 8,
                                                backgroundColor: AppColors.lightGreen,
                                                valueColor: AlwaysStoppedAnimation<Color>(energyColor),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
            ],
          ),
        ),
      ),
    );
  }
}


