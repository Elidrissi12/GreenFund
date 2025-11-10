import 'package:flutter/material.dart';
import '../../widgets/green_button.dart';
import '../../widgets/green_text_field.dart';

/// Page d'inscription (UI uniquement, sans backend).
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'Investisseur';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // TODO: appeler API register
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inscription réussie (mock)')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GreenTextField(
                  controller: _nameController,
                  label: 'Nom complet',
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
                ),
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
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _role,
                  decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Rôle'),
                  items: const [
                    DropdownMenuItem(value: 'Investisseur', child: Text('Investisseur')),
                    DropdownMenuItem(value: 'Porteur', child: Text('Porteur de projet')),
                  ],
                  onChanged: (v) => setState(() => _role = v ?? 'Investisseur'),
                ),
                const SizedBox(height: 16),
                GreenButton(onPressed: _submit, child: const Text('S’inscrire')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


