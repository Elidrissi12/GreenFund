import 'package:flutter/material.dart';

class ProjectCard extends StatelessWidget {
  final String title;
  final String energy;

  const ProjectCard({super.key, required this.title, required this.energy});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 3,
      child: ListTile(
        leading: const Icon(Icons.energy_savings_leaf, color: Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Type d’énergie : $energy'),
        trailing: TextButton(
          onPressed: () {},
          child: const Text('Voir'),
        ),
      ),
    );
  }
}
