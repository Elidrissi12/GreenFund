import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/colors.dart';

/// Profil utilisateur avec données réelles depuis la base de données.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userData = await ApiService.getUserProfile();
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getRoleDisplayName(String? role) {
    if (role == null) return 'Non défini';
    switch (role.toUpperCase()) {
      case 'INVESTOR':
        return 'Investisseur';
      case 'OWNER':
        return 'Porteur de projet';
      case 'ADMIN':
        return 'Administrateur';
      default:
        return role;
    }
  }

  IconData _getRoleIcon(String? role) {
    if (role == null) return Icons.person;
    switch (role.toUpperCase()) {
      case 'INVESTOR':
        return Icons.trending_up;
      case 'OWNER':
        return Icons.business;
      case 'ADMIN':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserProfile,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textMedium),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUserProfile,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Avatar et nom
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getRoleIcon(_userData?['role']),
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _userData?['name'] ?? 'Non défini',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getRoleDisplayName(_userData?['role']),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Informations détaillées
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
                              const Text(
                                'Informations personnelles',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildInfoRow(
                                icon: Icons.email,
                                label: 'Email',
                                value: _userData?['email'] ?? 'Non défini',
                              ),
                              const Divider(height: 32),
                              _buildInfoRow(
                                icon: Icons.person,
                                label: 'Nom complet',
                                value: _userData?['name'] ?? 'Non défini',
                              ),
                              const Divider(height: 32),
                              _buildInfoRow(
                                icon: Icons.badge,
                                label: 'Rôle',
                                value: _getRoleDisplayName(_userData?['role']),
                              ),
                              if (_userData?['createdAt'] != null) ...[
                                const Divider(height: 32),
                                _buildInfoRow(
                                  icon: Icons.calendar_today,
                                  label: 'Membre depuis',
                                  value: _formatDate(_userData!['createdAt']),
                                ),
                              ],
                              if (_userData?['active'] != null) ...[
                                const Divider(height: 32),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: _userData!['active'] == true
                                          ? AppColors.successGreen
                                          : AppColors.errorRed,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Statut du compte',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppColors.textMedium,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _userData!['active'] == true
                                                ? 'Actif'
                                                : 'Inactif',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: _userData!['active'] == true
                                                  ? AppColors.successGreen
                                                  : AppColors.errorRed,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryGreen, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic dateValue) {
    try {
      if (dateValue is String) {
        // Format ISO: "2024-01-15T10:30:00"
        final dateStr = dateValue.split('T')[0];
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          final months = [
            'Janvier',
            'Février',
            'Mars',
            'Avril',
            'Mai',
            'Juin',
            'Juillet',
            'Août',
            'Septembre',
            'Octobre',
            'Novembre',
            'Décembre'
          ];
          final month = months[int.parse(parts[1]) - 1];
          return '${parts[2]} $month ${parts[0]}';
        }
      }
      return dateValue.toString();
    } catch (e) {
      return dateValue.toString();
    }
  }
}


