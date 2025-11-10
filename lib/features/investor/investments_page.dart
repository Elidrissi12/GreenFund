import 'package:flutter/material.dart';
import '../../services/api_service.dart';

/// Liste des investissements depuis l'API.
class InvestmentsPage extends StatefulWidget {
  const InvestmentsPage({super.key});

  @override
  State<InvestmentsPage> createState() => _InvestmentsPageState();
}

class _InvestmentsPageState extends State<InvestmentsPage> {
  List<Map<String, dynamic>> _investments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInvestments();
  }

  Future<void> _loadInvestments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final investments = await ApiService.getMyInvestments();
      setState(() {
        _investments = investments;
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
        title: const Text('Mes investissements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInvestments,
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
                        onPressed: _loadInvestments,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _investments.isEmpty
                  ? const Center(child: Text('Aucun investissement'))
                  : RefreshIndicator(
                      onRefresh: _loadInvestments,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ListView.separated(
                          itemCount: _investments.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final investment = _investments[i];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                title: Text(
                                  investment['projectTitle'] ?? 'Projet',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('${(investment['amount'] ?? 0).toStringAsFixed(0)} MAD'),
                                trailing: Text(
                                  investment['createdAt'] != null
                                      ? DateTime.parse(investment['createdAt']).toString().split(' ')[0]
                                      : '',
                                  style: Theme.of(context).textTheme.bodySmall,
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


