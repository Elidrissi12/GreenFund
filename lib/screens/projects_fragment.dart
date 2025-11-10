import 'package:flutter/material.dart';
import '../widgets/project_card.dart';
import '../theme/colors.dart';
import '../features/investor/home_investor_page.dart';
import '../features/owner/home_owner_page.dart';
import '../features/admin/home_admin_page.dart';
import '../services/api_service.dart';
import '../models/project.dart';

class ProjectsFragment extends StatefulWidget {
  const ProjectsFragment({super.key});

  @override
  State<ProjectsFragment> createState() => _ProjectsFragmentState();
}

class _ProjectsFragmentState extends State<ProjectsFragment> {
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
      final projects = await ApiService.getProjects();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projets disponibles'),
        backgroundColor: AppColors.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjects,
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'investor') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeInvestorPage()));
              } else if (v == 'owner') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeOwnerPage()));
              } else if (v == 'admin') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeAdminPage()));
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'investor', child: Text('Espace Investisseur')),
              PopupMenuItem(value: 'owner', child: Text('Espace Porteur')),
              PopupMenuItem(value: 'admin', child: Text('Espace Admin')),
            ],
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
                  ? const Center(child: Text('Aucun projet disponible'))
                  : RefreshIndicator(
                      onRefresh: _loadProjects,
                      child: ListView.builder(
                        itemCount: _projects.length,
                        itemBuilder: (context, i) {
                          final project = _projects[i];
                          return ProjectCard(
                            title: project.title,
                            energy: project.energyType,
                          );
                        },
                      ),
                    ),
    );
  }
}
