import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/project.dart';

/// Liste de projets en attente avec actions Accepter/Refuser depuis l'API.
class ValidateProjectsPage extends StatefulWidget {
  const ValidateProjectsPage({super.key});

  @override
  State<ValidateProjectsPage> createState() => _ValidateProjectsPageState();
}

class _ValidateProjectsPageState extends State<ValidateProjectsPage> {
  List<Project> _pendingProjects = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPendingProjects();
  }

  Future<void> _loadPendingProjects() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final projects = await ApiService.getPendingProjects();
      setState(() {
        _pendingProjects = projects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _validateProject(String projectId, String status) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await ApiService.validateProject(projectId, status);

      Navigator.pop(context); // Fermer le loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Projet ${status == 'APPROVED' ? 'approuvé' : 'rejeté'} avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      _loadPendingProjects(); // Recharger la liste
    } catch (e) {
      Navigator.pop(context); // Fermer le loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Valider projets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingProjects,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Erreur: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPendingProjects,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _pendingProjects.isEmpty
                  ? const Center(child: Text('Aucun projet en attente'))
                  : RefreshIndicator(
                      onRefresh: _loadPendingProjects,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ListView.separated(
                          itemCount: _pendingProjects.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final project = _pendingProjects[i];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                title: Text(
                                  project.title,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('Porteur: ${project.city} • ${project.energyType}'),
                                trailing: Wrap(
                                  spacing: 8,
                                  children: [
                                    TextButton(
                                      onPressed: () => _validateProject(project.id, 'REJECTED'),
                                      child: const Text('Refuser', style: TextStyle(color: Colors.red)),
                                    ),
                                    TextButton(
                                      onPressed: () => _validateProject(project.id, 'APPROVED'),
                                      child: const Text('Accepter', style: TextStyle(color: Colors.green)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
    );
  }
}


