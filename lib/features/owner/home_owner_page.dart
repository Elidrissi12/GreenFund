import 'package:flutter/material.dart';
import '../../widgets/green_button.dart';
import '../../services/api_service.dart';
import '../../models/project.dart';
import 'create_project_page.dart';
import 'edit_project_page.dart';
import 'fundings_received_page.dart';
import '../../services/auth_service.dart';
import '../../screens/login_screen.dart';

/// Accueil Porteur: navigation vers les écrans du module.
class HomeOwnerPage extends StatefulWidget {
  const HomeOwnerPage({super.key});

  @override
  State<HomeOwnerPage> createState() => _HomeOwnerPageState();
}

class _HomeOwnerPageState extends State<HomeOwnerPage> {
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
      String errorMessage = e.toString();
      // Nettoyer le message d'erreur pour l'affichage
      if (errorMessage.contains('No authentication token') || errorMessage.contains('Session expirée')) {
        errorMessage = 'Session expirée. Veuillez vous reconnecter.';
      } else if (errorMessage.contains('Accès refusé') || errorMessage.contains('403')) {
        errorMessage = 'Accès refusé. Vous devez être propriétaire de projet pour accéder à cette page.';
      } else if (errorMessage.contains('401')) {
        errorMessage = 'Non autorisé. Veuillez vous reconnecter.';
      }
      
      setState(() {
        _error = errorMessage;
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

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous quitter l\'espace porteur ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Porteur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjects,
          ),
          IconButton(
            tooltip: 'Déconnexion',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GreenButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateProjectPage()),
                );
                _loadProjects(); // Rafraîchir après création
              },
              child: const Text('Créer un projet'),
            ),
            const SizedBox(height: 12),
            GreenButton(
              outlined: true,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FundingsReceivedPage()),
              ),
              child: const Text('Financements reçus'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Mes projets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
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
                          ? const Center(child: Text('Aucun projet créé'))
                          : RefreshIndicator(
                              onRefresh: _loadProjects,
                              child: ListView.separated(
                                itemCount: _projects.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, i) {
                                  final project = _projects[i];
                                  return Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        project.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${project.city} - ${project.energyType}'),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${project.raisedAmount.toStringAsFixed(0)} / ${project.targetAmount.toStringAsFixed(0)} MAD',
                                            style: TextStyle(
                                              color: Theme.of(context).primaryColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
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
          ],
        ),
      ),
    );
  }
}


