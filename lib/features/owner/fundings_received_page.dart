import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/project.dart';
import 'edit_project_page.dart';

/// Liste des financements reçus depuis l'API.
class FundingsReceivedPage extends StatefulWidget {
  const FundingsReceivedPage({super.key});

  @override
  State<FundingsReceivedPage> createState() => _FundingsReceivedPageState();
}

class _FundingsReceivedPageState extends State<FundingsReceivedPage> {
  List<Project> _projects = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final projects = await ApiService.getMyProjects();
      setState(() {
        _projects = projects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _editProject(Project project) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProjectPage(project: project),
      ),
    );
    // Rafraîchir la liste si le projet a été modifié
    if (result == true) {
      _loadProjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financements reçus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjects,
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
                        onPressed: _loadProjects,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _projects.isEmpty
                  ? const Center(child: Text('Aucun projet'))
                  : RefreshIndicator(
                      onRefresh: _loadProjects,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ListView.separated(
                          itemCount: _projects.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final project = _projects[i];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                title: Text(
                                  project.title,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('Collecté: ${project.raisedAmount.toStringAsFixed(0)} / ${project.targetAmount.toStringAsFixed(0)} MAD'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${(project.progress * 100).toStringAsFixed(0)}%',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _editProject(project),
                                      tooltip: 'Modifier',
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


