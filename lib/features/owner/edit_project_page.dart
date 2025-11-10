import 'package:flutter/material.dart';
import '../../widgets/green_button.dart';
import '../../widgets/green_text_field.dart';
import '../../models/project.dart';
import '../../services/api_service.dart';

/// Édition de projet connectée à l'API.
class EditProjectPage extends StatefulWidget {
  final Project project;

  const EditProjectPage({super.key, required this.project});

  @override
  State<EditProjectPage> createState() => _EditProjectPageState();
}

class _EditProjectPageState extends State<EditProjectPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _city;
  late final TextEditingController _target;
  late final TextEditingController _description;
  late String _energy;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.project.title);
    _city = TextEditingController(text: widget.project.city);
    _target = TextEditingController(text: widget.project.targetAmount.toStringAsFixed(0));
    _description = TextEditingController(text: widget.project.description);
    // Convertir le type d'énergie du backend vers le format d'affichage
    _energy = _convertEnergyTypeToDisplay(widget.project.energyType);
  }

  String _convertEnergyTypeToDisplay(String backendType) {
    switch (backendType.toUpperCase()) {
      case 'SOLAIRE':
        return 'Solaire';
      case 'EOLIENNE':
        return 'Éolienne';
      case 'BIOGAZ':
        return 'Biogaz';
      default:
        return 'Solaire';
    }
  }

  String _convertDisplayToEnergyType(String displayType) {
    switch (displayType) {
      case 'Solaire':
        return 'SOLAIRE';
      case 'Éolienne':
        return 'EOLIENNE';
      case 'Biogaz':
        return 'BIOGAZ';
      default:
        return 'SOLAIRE';
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _city.dispose();
    _target.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Vérifier si le projet a déjà des investissements
    if (widget.project.raisedAmount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de modifier un projet qui a déjà reçu des investissements'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final targetAmount = double.tryParse(_target.text.replaceAll(',', '.')) ?? 0.0;
      
      await ApiService.updateProject(
        projectId: widget.project.id,
        title: _title.text.trim(),
        city: _city.text.trim(),
        energyType: _convertDisplayToEnergyType(_energy),
        description: _description.text.trim(),
        targetAmount: targetAmount,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Projet mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Retourner true pour indiquer une mise à jour
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier un projet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (widget.project.raisedAmount > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ce projet a déjà reçu des investissements. La modification n\'est pas autorisée.',
                          style: TextStyle(color: Colors.orange.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              GreenTextField(
                controller: _title,
                label: 'Titre',
                validator: (v) => (v == null || v.isEmpty) ? 'Titre requis' : null,
                enabled: widget.project.raisedAmount == 0,
              ),
              const SizedBox(height: 12),
              GreenTextField(
                controller: _city,
                label: 'Ville',
                validator: (v) => (v == null || v.isEmpty) ? 'Ville requise' : null,
                enabled: widget.project.raisedAmount == 0,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _energy,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Type d\'énergie',
                ),
                items: const [
                  DropdownMenuItem(value: 'Solaire', child: Text('Solaire')),
                  DropdownMenuItem(value: 'Éolienne', child: Text('Éolienne')),
                  DropdownMenuItem(value: 'Biogaz', child: Text('Biogaz')),
                ],
                onChanged: widget.project.raisedAmount == 0
                    ? (v) => setState(() => _energy = v ?? 'Solaire')
                    : null,
              ),
              const SizedBox(height: 12),
              GreenTextField(
                controller: _description,
                label: 'Description',
                maxLines: 4,
                validator: (v) => (v == null || v.isEmpty) ? 'Description requise' : null,
                enabled: widget.project.raisedAmount == 0,
              ),
              const SizedBox(height: 12),
              GreenTextField(
                controller: _target,
                label: 'Objectif (MAD)',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Montant requis';
                  final amount = double.tryParse(v.replaceAll(',', '.'));
                  if (amount == null || amount <= 0) return 'Montant invalide';
                  return null;
                },
                enabled: widget.project.raisedAmount == 0,
              ),
              const SizedBox(height: 16),
              GreenButton(
                onPressed: _isLoading || widget.project.raisedAmount > 0 ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


