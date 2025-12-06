import 'package:flutter/material.dart';
import '../../models/project.dart';
import '../../widgets/green_button.dart';
import '../../services/api_service.dart';
import '../../theme/colors.dart';

/// Détails d'un projet avec progression et action Financer (bottom sheet).
class ProjectDetailPage extends StatelessWidget {
  final Project project;
  const ProjectDetailPage({super.key, required this.project});

  Future<void> _showInvestSheet(BuildContext context) async {
    final controller = TextEditingController();
    final amount = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        final viewInsets = MediaQuery.of(ctx).viewInsets;
        return Padding(
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Financer le projet', style: Theme.of(ctx).textTheme.titleMedium),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Montant (MAD)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: GreenButton(outlined: true, onPressed: () => Navigator.pop(ctx), child: const Text('Annuler'))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GreenButton(
                        onPressed: () {
                          final value = double.tryParse(controller.text.replaceAll(',', '.'));
                          Navigator.pop(ctx, value);
                        },
                        child: const Text('Financer'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (amount != null && amount > 0) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
        
        await ApiService.investInProject(project.id, amount);
        
        Navigator.pop(context); // Fermer le loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Investissement de ${amount.toStringAsFixed(0)} MAD enregistré avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Rafraîchir les données du projet si nécessaire
        Navigator.pop(context); // Fermer la page de détails
      } catch (e) {
        Navigator.pop(context); // Fermer le loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'investissement: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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
    final textTheme = Theme.of(context).textTheme;
    final energyColor = _getEnergyColor(project.energyType);
    final energyIcon = _getEnergyIcon(project.energyType);
    final progressPercent = (project.progress * 100).toStringAsFixed(0);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      energyColor.withOpacity(0.8),
                      energyColor,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(energyIcon, size: 80, color: Colors.white),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et localisation
                  Text(
                    project.title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 18, color: AppColors.textMedium),
                      const SizedBox(width: 4),
                      Text(
                        '${project.city} • ${project.energyType}',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Carte de progression
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.cardGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$progressPercent% financé',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${project.raisedAmount.toStringAsFixed(0)} / ${project.targetAmount.toStringAsFixed(0)} MAD',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: project.progress,
                            minHeight: 12,
                            backgroundColor: AppColors.lightGreen,
                            valueColor: AlwaysStoppedAnimation<Color>(energyColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Description
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          project.description,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Bouton d'investissement
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => _showInvestSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.trending_up, color: Colors.white),
                          SizedBox(width: 12),
                          Text(
                            'Financer ce projet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


