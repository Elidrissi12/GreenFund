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

  String? _filterKeyword;
  String? _filterCity;
  String? _filterEnergyType;
  String? _filterStatus;
  double? _filterMinTarget;
  double? _filterMaxTarget;

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
      final projects = await ApiService.getProjects(
        keyword: _filterKeyword,
        city: _filterCity,
        energyType: _filterEnergyType,
        projectStatus: _filterStatus,
        minTargetAmount: _filterMinTarget,
        maxTargetAmount: _filterMaxTarget,
      );
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

  void _openFilters() {
    final keywordController = TextEditingController(text: _filterKeyword ?? '');
    final cityController = TextEditingController(text: _filterCity ?? '');
    final minTargetController = TextEditingController(text: _filterMinTarget?.toString() ?? '');
    final maxTargetController = TextEditingController(text: _filterMaxTarget?.toString() ?? '');
    String? selectedEnergy = _filterEnergyType;
    String? selectedStatus = _filterStatus;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Filtres',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Réinitialiser',
                          onPressed: () {
                            keywordController.clear();
                            cityController.clear();
                            minTargetController.clear();
                            maxTargetController.clear();
                            setModalState(() {
                              selectedEnergy = null;
                              selectedStatus = null;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: keywordController,
                      decoration: const InputDecoration(
                        labelText: 'Recherche (titre, description, ville)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: cityController,
                      decoration: const InputDecoration(
                        labelText: 'Ville',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedEnergy,
                      decoration: const InputDecoration(
                        labelText: 'Type d\'énergie',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'SOLAIRE', child: Text('Solaire')),
                        DropdownMenuItem(value: 'EOLIENNE', child: Text('Éolienne')),
                        DropdownMenuItem(value: 'BIOGAZ', child: Text('Biogaz')),
                      ],
                      onChanged: (value) => setModalState(() => selectedEnergy = value),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Statut',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'PENDING', child: Text('En attente')),
                        DropdownMenuItem(value: 'APPROVED', child: Text('Approuvé')),
                        DropdownMenuItem(value: 'ACTIVE', child: Text('Actif')),
                        DropdownMenuItem(value: 'COMPLETED', child: Text('Terminé')),
                        DropdownMenuItem(value: 'REJECTED', child: Text('Rejeté')),
                        DropdownMenuItem(value: 'CANCELLED', child: Text('Annulé')),
                      ],
                      onChanged: (value) => setModalState(() => selectedStatus = value),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minTargetController,
                            decoration: const InputDecoration(
                              labelText: 'Montant cible min (MAD)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: maxTargetController,
                            decoration: const InputDecoration(
                              labelText: 'Montant cible max (MAD)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {
                                _filterKeyword = keywordController.text.trim().isEmpty ? null : keywordController.text.trim();
                                _filterCity = cityController.text.trim().isEmpty ? null : cityController.text.trim();
                                _filterEnergyType = selectedEnergy;
                                _filterStatus = selectedStatus;
                                _filterMinTarget = minTargetController.text.trim().isEmpty
                                    ? null
                                    : double.tryParse(minTargetController.text.trim());
                                _filterMaxTarget = maxTargetController.text.trim().isEmpty
                                    ? null
                                    : double.tryParse(maxTargetController.text.trim());
                              });
                              _loadProjects();
                            },
                            child: const Text('Appliquer'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        );
      },
    ).whenComplete(() {
      keywordController.dispose();
      cityController.dispose();
      minTargetController.dispose();
      maxTargetController.dispose();
    });
  }

  bool get _hasActiveFilters {
    return _filterKeyword != null ||
        _filterCity != null ||
        _filterEnergyType != null ||
        _filterStatus != null ||
        _filterMinTarget != null ||
        _filterMaxTarget != null;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _ProjectsList(
        projects: _projects,
        isLoading: _isLoading,
        error: _error,
        onRefresh: _loadProjects,
      ),
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
            tooltip: 'Filtres',
            onPressed: _openFilters,
            icon: _hasActiveFilters
                ? const Icon(Icons.filter_list, color: Colors.white)
                : const Icon(Icons.filter_list),
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


