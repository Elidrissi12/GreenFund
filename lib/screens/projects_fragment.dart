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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projets disponibles'),
        backgroundColor: AppColors.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjects,
          ),
          IconButton(
            tooltip: 'Filtres',
            onPressed: _openFilters,
            icon: _hasActiveFilters
                ? const Icon(Icons.filter_list, color: Colors.white)
                : const Icon(Icons.filter_list),
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
