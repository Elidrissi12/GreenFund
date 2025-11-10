import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../screens/login_screen.dart';
import '../../theme/colors.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SwitchListTile(
              title: const Text('Mode sombre'),
              value: _darkMode,
              activeColor: AppColors.primaryGreen,
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
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: const Text('Langue'),
              subtitle: Text(_lang == 'FR' ? 'Français' : 'Anglais'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _chooseLanguage,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const ListTile(
              title: Text('Notifications'),
              subtitle: Text('À venir'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: const Text('Déconnexion'),
              subtitle: const Text('Se déconnecter de votre compte'),
              trailing: const Icon(Icons.logout, color: AppColors.primaryGreen),
              onTap: _logout,
            ),
          ),
        ],
      ),
    );
  }
}


