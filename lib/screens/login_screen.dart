import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/navigation_helper.dart';
import 'register_screen.dart';
import '../theme/styles.dart';
import '../theme/colors.dart';
import 'dart:io';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _login() async {
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final response = await AuthService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      // Fermer l'indicateur de chargement
      Navigator.pop(context);

      if (response.containsKey('token')) {
        // Récupérer le rôle de l'utilisateur
        final role = response['role']?.toString() ?? 'INVESTOR';
        
        // Naviguer vers la page appropriée selon le rôle
        await NavigationHelper.navigateToHome(context, role);
      }
    } catch (e) {
      // Fermer l'indicateur de chargement
      Navigator.pop(context);
      
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de connexion: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Connexion',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  decoration: AppStyles.inputDecoration('Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: AppStyles.inputDecoration('Mot de passe'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: AppStyles.greenButton,
                    child: const Text('Se connecter'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()));
                  },
                  child: const Text(
                    'Créer un compte',
                    style: TextStyle(color: AppColors.primaryGreen),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
