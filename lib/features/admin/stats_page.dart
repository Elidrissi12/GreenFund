import 'package:flutter/material.dart';
import '../../services/api_service.dart';

/// Statistiques depuis l'API: affiche des KPIs.
class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await ApiService.getStats();
      setState(() {
        _stats = stats;
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
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
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
                        onPressed: _loadStats,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _stats == null
                  ? const Center(child: Text('Aucune statistique disponible'))
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _KpiCard(
                                title: 'Total projets',
                                value: '${_stats!['totalProjects'] ?? 0}',
                              ),
                              _KpiCard(
                                title: 'Projets actifs',
                                value: '${_stats!['activeProjects'] ?? 0}',
                              ),
                              _KpiCard(
                                title: 'Projets en attente',
                                value: '${_stats!['pendingProjects'] ?? 0}',
                              ),
                              _KpiCard(
                                title: 'Projets complétés',
                                value: '${_stats!['completedProjects'] ?? 0}',
                              ),
                              _KpiCard(
                                title: 'Total utilisateurs',
                                value: '${_stats!['totalUsers'] ?? 0}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Center(
                                child: Text(
                                  'Graphique des financements (à implémenter)',
                                  style: textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  const _KpiCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: 180,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.bodySmall),
              const SizedBox(height: 8),
              Text(value, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}


