import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/investment.dart';

/// Transactions connectées à l'API.
class ManageTransactionsPage extends StatefulWidget {
  const ManageTransactionsPage({super.key});

  @override
  State<ManageTransactionsPage> createState() => _ManageTransactionsPageState();
}

class _ManageTransactionsPageState extends State<ManageTransactionsPage> {
  List<Investment> _transactions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiService.getAllTransactions();
      setState(() {
        _transactions = data.map((json) => Investment.fromJson(json)).toList();
        // Trier par date de création (plus récent en premier)
        _transactions.sort((a, b) {
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date inconnue';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactions,
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
                        onPressed: _loadTransactions,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _transactions.isEmpty
                  ? const Center(child: Text('Aucune transaction'))
                  : RefreshIndicator(
                      onRefresh: _loadTransactions,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ListView.separated(
                          itemCount: _transactions.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final tx = _transactions[i];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(
                                  '#TX${tx.id} • ${tx.amount.toStringAsFixed(0)} MAD',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Investisseur: ${tx.investorName}'),
                                    const SizedBox(height: 4),
                                    Text('Projet: ${tx.projectTitle}'),
                                    if (tx.createdAt != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDate(tx.createdAt),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: Icon(
                                  Icons.check_circle,
                                  color: Colors.green.shade600,
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


