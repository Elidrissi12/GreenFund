import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/colors.dart';

/// Statistiques depuis l'API: affiche des KPIs avec design moderne.
class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await ApiService.getStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                            onPressed: _loadStats,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _stats == null
                    ? Center(
                        child: Text(
                          'Aucune statistique disponible',
                          style: TextStyle(color: AppColors.textMedium),
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // En-tête
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.analytics,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Vue d\'ensemble',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Statistiques de la plateforme',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Grille de KPIs
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.1,
                              children: [
                                _KpiCard(
                                  title: 'Total projets',
                                  value: '${_stats!['totalProjects'] ?? 0}',
                                  icon: Icons.folder_special,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                                  ),
                                ),
                                _KpiCard(
                                  title: 'Projets actifs',
                                  value: '${_stats!['activeProjects'] ?? 0}',
                                  icon: Icons.play_circle_filled,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
                                  ),
                                ),
                                _KpiCard(
                                  title: 'En attente',
                                  value: '${_stats!['pendingProjects'] ?? 0}',
                                  icon: Icons.hourglass_empty,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                                  ),
                                ),
                                _KpiCard(
                                  title: 'Complétés',
                                  value: '${_stats!['completedProjects'] ?? 0}',
                                  icon: Icons.check_circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                                  ),
                                ),
                                _KpiCard(
                                  title: 'Total utilisateurs',
                                  value: '${_stats!['totalUsers'] ?? 0}',
                                  icon: Icons.people,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                                  ),
                                ),
                                _KpiCard(
                                  title: 'Montant investi',
                                  value: _formatAmount(_stats!['totalInvestedAmount'] ?? 0),
                                  icon: Icons.account_balance_wallet,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Section graphiques
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
                                  Row(
                                    children: [
                                      Icon(Icons.bar_chart, color: AppColors.primaryGreen),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Analyse détaillée',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  // Distribution par statut
                                  _buildStatDistribution(
                                    'Distribution des projets',
                                    [
                                      _StatItem('Actifs', _stats!['activeProjects'] ?? 0, AppColors.successGreen),
                                      _StatItem('En attente', _stats!['pendingProjects'] ?? 0, AppColors.warningOrange),
                                      _StatItem('Complétés', _stats!['completedProjects'] ?? 0, AppColors.primaryGreen),
                                    ],
                                    _stats!['totalProjects'] ?? 1,
                                  ),
                                  const SizedBox(height: 16),
                                  // Répartition des utilisateurs
                                  _buildUserDistribution(_stats!),
                                  const SizedBox(height: 16),
                                  // Indicateurs de performance
                                  _buildPerformanceIndicators(_stats!),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
      ),
    );
  }

  String _formatAmount(dynamic amount) {
    try {
      double value = 0;
      if (amount is num) {
        value = amount.toDouble();
      } else if (amount is String) {
        value = double.tryParse(amount) ?? 0;
      }
      
      if (value >= 1000000) {
        return '${(value / 1000000).toStringAsFixed(1)}M MAD';
      } else if (value >= 1000) {
        return '${(value / 1000).toStringAsFixed(1)}K MAD';
      }
      return '${value.toStringAsFixed(0)} MAD';
    } catch (e) {
      return '0 MAD';
    }
  }

  Widget _buildStatDistribution(String title, List<_StatItem> items, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${item.value} (${total > 0 ? ((item.value / total) * 100).toStringAsFixed(1) : 0}%)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: total > 0 ? item.value / total : 0,
                  backgroundColor: AppColors.lightGreen,
                  valueColor: AlwaysStoppedAnimation<Color>(item.color),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildUserDistribution(Map<String, dynamic> stats) {
    final totalUsers = stats['totalUsers'] ?? 0;
    final investors = stats['investorCount'] ?? 0;
    final owners = stats['ownerCount'] ?? 0;
    final admins = stats['adminCount'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people_outline, color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Répartition des utilisateurs',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildUserTypeRow('Investisseurs', investors, totalUsers, Icons.savings_outlined, AppColors.primaryGreen),
          const SizedBox(height: 12),
          _buildUserTypeRow('Propriétaires', owners, totalUsers, Icons.work_outline, AppColors.accentGreen),
          const SizedBox(height: 12),
          _buildUserTypeRow('Administrateurs', admins, totalUsers, Icons.admin_panel_settings, AppColors.primaryGreenDark),
        ],
      ),
    );
  }

  Widget _buildUserTypeRow(String label, int count, int total, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
            ),
          ),
        ),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceIndicators(Map<String, dynamic> stats) {
    final totalProjects = stats['totalProjects'] ?? 0;
    final completedProjects = stats['completedProjects'] ?? 0;
    final totalInvested = stats['totalInvestedAmount'] ?? 0;
    
    final completionRate = totalProjects > 0 ? (completedProjects / totalProjects) * 100 : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Indicateurs de performance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildIndicatorRow(
            'Taux de complétion',
            '${completionRate.toStringAsFixed(1)}%',
            completionRate / 100,
            Icons.check_circle_outline,
          ),
          const SizedBox(height: 12),
          _buildIndicatorRow(
            'Montant moyen par projet',
            totalProjects > 0 ? _formatAmount(totalInvested / totalProjects) : '0 MAD',
            null,
            Icons.account_balance_wallet_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorRow(String label, String value, double? progress, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryGreen, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
        if (progress != null) ...[
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.lightGreen,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              minHeight: 6,
            ),
          ),
        ],
      ],
    );
  }
}

class _StatItem {
  final String label;
  final int value;
  final Color color;

  _StatItem(this.label, this.value, this.color);
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


