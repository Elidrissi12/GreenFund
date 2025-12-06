import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../theme/colors.dart';
import '../theme/styles.dart';

class AccountFragment extends StatelessWidget {
  const AccountFragment({super.key});

  void _logout(BuildContext context) async {
    await AuthService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Compte'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Bouton de déconnexion
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _logout(context),
              style: AppStyles.greenButton,
              child: const Text('Se déconnecter'),
            ),
          ),
        ],
      ),
    );
  }
}
