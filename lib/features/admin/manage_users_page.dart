import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/colors.dart';
import '../../theme/styles.dart';

/// Gestion utilisateurs depuis l'API: activer/désactiver.
class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await ApiService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserStatus(String userId, bool active) async {
    try {
      await ApiService.updateUserStatus(userId, active);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Statut utilisateur ${active ? 'activé' : 'désactivé'}'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      _loadUsers(); // Recharger la liste
    } catch (e) {
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
              onPressed: _loadUsers,
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
            Icon(Icons.people_outline, size: 64, color: AppColors.primaryGreen),
            const SizedBox(height: 16),
            Text(
              'Aucun utilisateur',
              style: AppStyles.titleText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Les utilisateurs créés apparaîtront ici avec leur rôle et leur statut.',
              style: AppStyles.subtitleText.copyWith(color: AppColors.textMedium),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    final userId = user['id'].toString();
    final isActive = user['active'] ?? true;
    final role = (user['role'] ?? '').toString();

    IconData roleIcon;
    Color roleColor;
    switch (role) {
      case 'ADMIN':
        roleIcon = Icons.admin_panel_settings;
        roleColor = Colors.deepPurple;
        break;
      case 'OWNER':
        roleIcon = Icons.work_outline;
        roleColor = Colors.orange;
        break;
      default:
        roleIcon = Icons.savings_outlined;
        roleColor = AppColors.primaryGreen;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: roleColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(roleIcon, color: roleColor),
        ),
        title: Text(
          user['name'] ?? 'Utilisateur',
          style: AppStyles.titleText,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user['email'] ?? '',
              style: AppStyles.subtitleText.copyWith(color: AppColors.textMedium),
            ),
            const SizedBox(height: 2),
            Text(
              role,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGreen,
              ),
            ),
          ],
        ),
        value: isActive,
        activeColor: AppColors.primaryGreen,
        onChanged: (value) => _updateUserStatus(userId, value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gérer utilisateurs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _users.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadUsers,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ListView.separated(
                          itemCount: _users.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final user = _users[i];
                            return _buildUserTile(user);
                          },
                        ),
                      ),
                    ),
    );
  }
}


