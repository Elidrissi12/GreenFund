import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../screens/login_screen.dart';
import '../../theme/colors.dart';
import '../../theme/styles.dart';

/// Page des paramètres avec déconnexion fonctionnelle.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  String _lang = 'FR';

  void _chooseLanguage() async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        String? selected = _lang;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Choisir la langue'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('Français'),
                  value: 'FR',
                  groupValue: selected,
                  activeColor: AppColors.primaryGreen,
                  onChanged: (v) {
                    setState(() => selected = v);
                    Navigator.pop(ctx, v);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Anglais'),
                  value: 'EN',
                  groupValue: selected,
                  activeColor: AppColors.primaryGreen,
                  onChanged: (v) {
                    setState(() => selected = v);
                    Navigator.pop(ctx, v);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
    if (result != null) {
      setState(() => _lang = result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Langue réglée sur ${result == 'FR' ? 'Français' : 'Anglais'}'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }

  void _logout() async {
    // Afficher une boîte de dialogue de confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Déconnecter l'utilisateur
      await AuthService.logout();
      
      // Naviguer vers la page de connexion
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildHeaderCard() {
    return Container(
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
            child: const Icon(Icons.settings, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Paramètres GreenFund',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Personnalisez votre expérience et gérez votre compte.',
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
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
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
            color: AppColors.primaryGreen.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryGreen),
        ),
        title: Text(title, style: AppStyles.titleText),
        subtitle: Text(
          subtitle,
          style: AppStyles.subtitleText.copyWith(color: AppColors.textMedium),
        ),
        value: value,
        activeColor: AppColors.primaryGreen,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Color iconColor = AppColors.primaryGreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: AppStyles.titleText),
        subtitle: Text(
          subtitle,
          style: AppStyles.subtitleText.copyWith(color: AppColors.textMedium),
        ),
        trailing: onTap != null
            ? const Icon(Icons.chevron_right, color: AppColors.textMedium)
            : null,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Paramètres')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            _buildSwitchTile(
              icon: Icons.dark_mode,
              title: 'Mode sombre',
              subtitle: 'Expérience visuelle plus reposante (mock)',
              value: _darkMode,
              onChanged: (v) {
                setState(() => _darkMode = v);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Mode sombre ${v ? 'activé' : 'désactivé'} (mock)'),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildSettingTile(
              icon: Icons.language,
              title: 'Langue',
              subtitle: _lang == 'FR' ? 'Français' : 'Anglais',
              onTap: _chooseLanguage,
            ),
            const SizedBox(height: 12),
            _buildSettingTile(
              icon: Icons.notifications_active_outlined,
              title: 'Notifications',
              subtitle: 'Personnalisation à venir',
              onTap: null,
            ),
            const SizedBox(height: 20),
            _buildSettingTile(
              icon: Icons.logout,
              title: 'Déconnexion',
              subtitle: 'Se déconnecter de votre compte',
              iconColor: AppColors.errorRed,
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}


