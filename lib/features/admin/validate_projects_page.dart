import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/project.dart';
import '../../theme/colors.dart';
import '../../theme/styles.dart';

/// Liste de projets en attente avec actions Accepter/Refuser depuis l'API.
class ValidateProjectsPage extends StatefulWidget {
  const ValidateProjectsPage({super.key});

  @override
  State<ValidateProjectsPage> createState() => _ValidateProjectsPageState();
}

class _ValidateProjectsPageState extends State<ValidateProjectsPage> {
  List<Project> _pendingProjects = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPendingProjects();
  }

  Future<void> _loadPendingProjects() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final projects = await ApiService.getPendingProjects();
      setState(() {
        _pendingProjects = projects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _validateProject(String projectId, String status) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await ApiService.validateProject(projectId, status);

      Navigator.pop(context); // Fermer le loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Projet ${status == 'APPROVED' ? 'approuvé' : 'rejeté'} avec succès'),
          backgroundColor: AppColors.successGreen,
        ),
      );

      _loadPendingProjects(); // Recharger la liste
    } catch (e) {
      Navigator.pop(context); // Fermer le loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: AppColors.errorRed,
        ),
      );
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
              onPressed: _loadPendingProjects,
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
            Icon(Icons.inbox_outlined, size: 64, color: AppColors.primaryGreen),
            const SizedBox(height: 16),
            Text(
              'Aucun projet en attente',
              style: AppStyles.titleText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Les nouveaux projets soumis par les propriétaires apparaîtront ici pour validation.',
              style: AppStyles.subtitleText.copyWith(color: AppColors.textMedium),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(Project project) {
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
                  child: const Icon(Icons.pending_actions, color: AppColors.primaryGreen, size: 22),
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
                        '${project.city} • ${project.energyType}',
                        style: AppStyles.subtitleText.copyWith(color: AppColors.textMedium),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cible : ${project.targetAmount.toStringAsFixed(0)} MAD',
                        style: AppStyles.subtitleText.copyWith(
                          color: AppColors.darkGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _validateProject(project.id, 'REJECTED'),
                  icon: const Icon(Icons.close, color: AppColors.errorRed, size: 18),
                  label: const Text(
                    'Refuser',
                    style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _validateProject(project.id, 'APPROVED'),
                  icon: const Icon(Icons.check, color: AppColors.primaryGreen, size: 18),
                  label: const Text(
                    'Accepter',
                    style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
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
        title: const Text('Valider projets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingProjects,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _pendingProjects.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadPendingProjects,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ListView.separated(
                          itemCount: _pendingProjects.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final project = _pendingProjects[i];
                            return _buildProjectCard(project);
                          },
                        ),
                      ),
                    ),
    );
  }
}


