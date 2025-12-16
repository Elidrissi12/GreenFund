import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/project.dart';
import '../../theme/colors.dart';
import '../../theme/styles.dart';
import 'edit_project_page.dart';

/// Liste des financements reçus depuis l'API (projets de l'OWNER).
class FundingsReceivedPage extends StatefulWidget {
  const FundingsReceivedPage({super.key});

  @override
  State<FundingsReceivedPage> createState() => _FundingsReceivedPageState();
}

class _FundingsReceivedPageState extends State<FundingsReceivedPage> {
  List<Project> _projects = [];
  bool _isLoading = true;
  String? _error;
  double _totalRaised = 0;
  double _totalTarget = 0;

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
      double raised = 0;
      double target = 0;
      for (final p in projects) {
        raised += p.raisedAmount;
        target += p.targetAmount;
      }

      setState(() {
        _projects = projects;
        _totalRaised = raised;
        _totalTarget = target;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
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
    if (result == true) {
      _loadProjects();
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.errorRed),
            const SizedBox(height: 16),
            Text('Une erreur est survenue', style: AppStyles.titleText, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              style: AppStyles.subtitleText.copyWith(color: AppColors.textMedium),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProjects,
              style: AppStyles.greenButton,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.energy_savings_leaf_outlined, size: 64, color: AppColors.primaryGreen),
            const SizedBox(height: 16),
            Text(
              'Aucun financement pour le moment',
              style: AppStyles.titleText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Créez et partagez vos projets d’énergie renouvelable pour commencer à recevoir des financements.',
              style: AppStyles.subtitleText.copyWith(color: AppColors.textMedium),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final progress = _totalTarget > 0 ? (_totalRaised / _totalTarget).clamp(0.0, 1.0) : 0.0;
    final progressPercent = (progress * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.elevatedShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total financé sur vos projets',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_totalRaised.toStringAsFixed(0)} MAD',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _totalTarget > 0
                          ? 'Objectif global : ${_totalTarget.toStringAsFixed(0)} MAD'
                          : 'Aucun objectif défini pour l’instant',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$progressPercent% de vos objectifs globaux atteints',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Project project) {
    final progress = project.progress; // 0..1 déjà clampé côté modèle
    final progressPercent = (progress * 100).toStringAsFixed(0);

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.eco, color: AppColors.primaryGreen, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title,
                        style: AppStyles.titleText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        project.city,
                        style: AppStyles.subtitleText.copyWith(color: AppColors.textMedium),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Collecté : ${project.raisedAmount.toStringAsFixed(0)} / ${project.targetAmount.toStringAsFixed(0)} MAD',
                        style: AppStyles.subtitleText.copyWith(
                          color: AppColors.darkGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$progressPercent%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.primaryGreen),
                      onPressed: () => _editProject(project),
                      tooltip: 'Modifier le projet',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.lightGreen,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Financements reçus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjects,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _projects.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadProjects,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ListView.separated(
                          itemCount: _projects.length + 1,
                          separatorBuilder: (_, index) =>
                              index == 0 ? const SizedBox(height: 16) : const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            if (i == 0) {
                              return _buildSummaryCard();
                            }
                            final project = _projects[i - 1];
                            return _buildProjectCard(project);
                          },
                        ),
                      ),
                    ),
    );
  }
}


