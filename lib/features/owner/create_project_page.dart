import 'package:flutter/material.dart';
import '../../widgets/green_button.dart';
import '../../widgets/green_text_field.dart';
import '../../services/api_service.dart';

/// Création de projet (UI, mock).
class CreateProjectPage extends StatefulWidget {
  const CreateProjectPage({super.key});

  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _city = TextEditingController();
  final _description = TextEditingController();
  final _target = TextEditingController();
  String _energy = 'Solaire';

  @override
  void dispose() {
    _title.dispose();
    _city.dispose();
    _description.dispose();
    _target.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
        
        final targetAmount = double.tryParse(_target.text.replaceAll(',', '.')) ?? 0.0;
        
        await ApiService.createProject(
          title: _title.text.trim(),
          city: _city.text.trim(),
          energyType: _energy,
          description: _description.text.trim(),
          targetAmount: targetAmount,
        );
        
        Navigator.pop(context); // Fermer le loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Projet créé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context); // Retourner à la page précédente
      } catch (e) {
        Navigator.pop(context); // Fermer le loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un projet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GreenTextField(controller: _title, label: 'Titre', validator: (v) => (v==null||v.isEmpty)?'Titre requis':null),
              const SizedBox(height: 12),
              GreenTextField(controller: _city, label: 'Ville', validator: (v) => (v==null||v.isEmpty)?'Ville requise':null),
              const SizedBox(height: 12),
              GreenTextField(
                controller: _description,
                label: 'Description',
                maxLines: 4,
                validator: (v) => (v==null||v.isEmpty)?'Description requise':null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _energy,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Type d\'énergie'),
                items: const [
                  DropdownMenuItem(value: 'Solaire', child: Text('Solaire')),
                  DropdownMenuItem(value: 'Éolienne', child: Text('Éolienne')),
                  DropdownMenuItem(value: 'Biogaz', child: Text('Biogaz')),
                ],
                onChanged: (v) => setState(() => _energy = v ?? 'Solaire'),
              ),
              const SizedBox(height: 12),
              GreenTextField(
                controller: _target,
                label: 'Objectif (MAD)',
                keyboardType: TextInputType.number,
                validator: (v) => (double.tryParse((v??'').replaceAll(',', '.')) == null) ? 'Montant invalide' : null,
              ),
              const SizedBox(height: 16),
              GreenButton(onPressed: _submit, child: const Text('Soumettre')),
            ],
          ),
        ),
      ),
    );
  }
}


