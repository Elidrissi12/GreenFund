import 'package:flutter/material.dart';
import '../../models/project.dart';
import '../../widgets/green_button.dart';
import '../../services/api_service.dart';

/// Détails d'un projet avec progression et action Financer (bottom sheet).
class ProjectDetailPage extends StatelessWidget {
  final Project project;
  const ProjectDetailPage({super.key, required this.project});

  Future<void> _showInvestSheet(BuildContext context) async {
    final controller = TextEditingController();
    final amount = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        final viewInsets = MediaQuery.of(ctx).viewInsets;
        return Padding(
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Financer le projet', style: Theme.of(ctx).textTheme.titleMedium),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Montant (MAD)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: GreenButton(outlined: true, onPressed: () => Navigator.pop(ctx), child: const Text('Annuler'))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GreenButton(
                        onPressed: () {
                          final value = double.tryParse(controller.text.replaceAll(',', '.'));
                          Navigator.pop(ctx, value);
                        },
                        child: const Text('Financer'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (amount != null && amount > 0) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
        
        await ApiService.investInProject(project.id, amount);
        
        Navigator.pop(context); // Fermer le loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Investissement de ${amount.toStringAsFixed(0)} MAD enregistré avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Rafraîchir les données du projet si nécessaire
        Navigator.pop(context); // Fermer la page de détails
      } catch (e) {
        Navigator.pop(context); // Fermer le loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'investissement: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Détails du projet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.title, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('${project.energyType} • ${project.city}', style: textTheme.bodySmall),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(value: project.progress),
                    const SizedBox(height: 8),
                    Text('${project.raisedAmount.toStringAsFixed(0)} / ${project.targetAmount.toStringAsFixed(0)} MAD', style: textTheme.bodySmall),
                    const SizedBox(height: 12),
                    Text(project.description, style: textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            const Spacer(),
            GreenButton(onPressed: () => _showInvestSheet(context), child: const Text('Financer')),
          ],
        ),
      ),
    );
  }
}


