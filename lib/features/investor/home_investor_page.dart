import 'package:flutter/material.dart';
import '../../models/project.dart';
import '../../widgets/green_button.dart';
import '../../services/api_service.dart';
import '../../theme/colors.dart';
import '../common/profile_page.dart';
import '../common/settings_page.dart';
import 'investments_page.dart';
import 'project_detail_page.dart';

/// Accueil investisseur avec NavigationBar (Projets / Compte) et liste depuis API.
class HomeInvestorPage extends StatefulWidget {
  const HomeInvestorPage({super.key});

  @override
  State<HomeInvestorPage> createState() => _HomeInvestorPageState();
}

class _HomeInvestorPageState extends State<HomeInvestorPage> {
  int _index = 0;
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
    final pages = [
      _ProjectsList(projects: _projects, isLoading: _isLoading, error: _error, onRefresh: _loadProjects),
      _AccountMenu(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('GreenFund'),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: _loadProjects,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Investissements',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvestmentsPage())),
            icon: const Icon(Icons.trending_up),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'profile') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
              } else if (v == 'settings') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'profile', child: Text('Profil')),
              PopupMenuItem(value: 'settings', child: Text('Paramètres')),
            ],
          ),
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        indicatorColor: AppColors.lightGreen,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.bolt),
            selectedIcon: Icon(Icons.bolt, color: AppColors.primaryGreen),
            label: 'Projets',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle),
            selectedIcon: Icon(Icons.account_circle, color: AppColors.primaryGreen),
            label: 'Compte',
          ),
        ],
        onDestinationSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _ProjectsList extends StatelessWidget {
  final List<Project> projects;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;
  
  const _ProjectsList({
    required this.projects,
    required this.isLoading,
    this.error,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Erreur: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }
    
    if (projects.isEmpty) {
      return const Center(child: Text('Aucun projet disponible'));
    }
    
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: projects.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final p = projects[i];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectDetailPage(project: p)));
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(p.title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        subtitle: Text('${p.energyType} • ${p.city}', style: textTheme.bodySmall),
                        trailing: const Text('Voir'),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: p.progress),
                      const SizedBox(height: 8),
                      Text('${p.raisedAmount.toStringAsFixed(0)} / ${p.targetAmount.toStringAsFixed(0)} MAD', style: textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AccountMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GreenButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())), child: const Text('Profil')),
          const SizedBox(height: 12),
          GreenButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())), child: const Text('Paramètres')),
          const SizedBox(height: 12),
          GreenButton(outlined: true, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvestmentsPage())), child: const Text('Mes investissements')),
        ],
      ),
    );
  }
}


