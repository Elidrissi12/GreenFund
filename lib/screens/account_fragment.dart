import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

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
      appBar: AppBar(title: const Text('Mon Compte')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _logout(context),
          child: const Text('Se déconnecter'),
        ),
      ),
    );
  }
}
