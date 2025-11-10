import 'package:flutter/material.dart';
import '../../widgets/green_button.dart';
import '../../widgets/green_text_field.dart';

/// Page de connexion (UI uniquement, sans backend).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // TODO: appeler API login
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connexion réussie (mock)')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Bienvenue sur GreenFund', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  GreenTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email requis';
                      if (!v.contains('@')) return 'Email invalide';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  GreenTextField(
                    controller: _passwordController,
                    label: 'Mot de passe',
                    obscureText: true,
                    validator: (v) => (v == null || v.length < 6) ? '6 caractères minimum' : null,
                  ),
                  const SizedBox(height: 16),
                  GreenButton(onPressed: _submit, child: const Text('Se connecter')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


