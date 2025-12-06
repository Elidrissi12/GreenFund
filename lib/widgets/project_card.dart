import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ProjectCard extends StatelessWidget {
  final String title;
  final String energy;
  final String? city;
  final double? progress;
  final double? raisedAmount;
  final double? targetAmount;
  final VoidCallback? onTap;

  const ProjectCard({
    super.key,
    required this.title,
    required this.energy,
    this.city,
    this.progress,
    this.raisedAmount,
    this.targetAmount,
    this.onTap,
  });

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
    final energyColor = _getEnergyColor(energy);
    final energyIcon = _getEnergyIcon(energy);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
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
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (city != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 14, color: AppColors.textMedium),
                                const SizedBox(width: 4),
                                Text(
                                  '$city • $energy',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textMedium,
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            const SizedBox(height: 4),
                            Text(
                              energy,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textMedium,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Voir',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                if (progress != null && raisedAmount != null && targetAmount != null) ...[
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(progress! * 100).toStringAsFixed(0)}% financé',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          Text(
                            '${raisedAmount!.toStringAsFixed(0)} / ${targetAmount!.toStringAsFixed(0)} MAD',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: AppColors.lightGreen,
                          valueColor: AlwaysStoppedAnimation<Color>(energyColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
