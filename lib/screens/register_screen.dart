import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../theme/colors.dart';
import '../theme/styles.dart';
import '../services/auth_service.dart';
import '../utils/navigation_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  String _selectedRole = 'Investisseur';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Afficher un indicateur de chargement
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        // Convertir le rôle
        String role = _selectedRole == 'Investisseur' ? 'INVESTOR' : 'OWNER';

        final response = await AuthService.register(
          nameController.text.trim(),
          emailController.text.trim(),
          passwordController.text,
          role,
        );

        // Fermer l'indicateur de chargement
        Navigator.pop(context);

        if (response.containsKey('token')) {
          // Récupérer le rôle de l'utilisateur depuis la réponse
          final userRole = response['role']?.toString() ?? role;
          
          // Naviguer vers la page appropriée selon le rôle
          await NavigationHelper.navigateToHome(context, userRole);
          
          // Afficher un message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inscription réussie !'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Fermer l'indicateur de chargement
        Navigator.pop(context);

        // Afficher un message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'inscription: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: AppStyles.inputDecoration('Nom complet'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le nom est requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: AppStyles.inputDecoration('Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'L\'email est requis';
                    }
                    if (!value.contains('@')) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: AppStyles.inputDecoration('Mot de passe'),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: AppStyles.inputDecoration('Rôle'),
                  items: const [
                    DropdownMenuItem(value: 'Investisseur', child: Text('Investisseur')),
                    DropdownMenuItem(value: 'Porteur', child: Text('Porteur de projet')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value ?? 'Investisseur';
                    });
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _register,
                    style: AppStyles.greenButton,
                    child: const Text('Créer un compte'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Déjà un compte ? Se connecter',
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
