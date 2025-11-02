import 'package:flutter/material.dart';
import '../widgets/project_card.dart';

class ProjectsFragment extends StatelessWidget {
  const ProjectsFragment({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulation de projets
    final projects = [
      {'title': 'Panneaux solaires Marrakech', 'energy': 'Solaire'},
      {'title': 'Mini-éolienne Agadir', 'energy': 'Éolienne'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Projets disponibles')),
      body: ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, i) {
          final p = projects[i];
          return ProjectCard(title: p['title']!, energy: p['energy']!);
        },
      ),
    );
  }
}
