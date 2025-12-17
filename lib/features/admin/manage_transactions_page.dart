import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/investment.dart';
import '../../theme/colors.dart';
import '../../theme/styles.dart';

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
  double _totalAmount = 0;

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
      final txs = data.map((json) => Investment.fromJson(json)).toList();
      txs.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      final total = txs.fold<double>(0, (sum, tx) => sum + tx.amount);

      setState(() {
        _transactions = txs;
        _totalAmount = total;
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

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.errorRed),
            const SizedBox(height: 16),
            Text('Une erreur est survenue', style: AppStyles.titleText, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              style: AppStyles.subtitleText.copyWith(color: AppColors.textMedium),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTransactions,
              style: AppStyles.greenButton,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.primaryGreen),
            const SizedBox(height: 16),
            Text(
              'Aucune transaction',
              style: AppStyles.titleText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Les investissements réalisés apparaîtront ici avec le détail complet.',
              style: AppStyles.subtitleText.copyWith(color: AppColors.textMedium),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.elevatedShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.swap_horiz, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transactions totales',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_totalAmount.toStringAsFixed(0)} MAD',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_transactions.length} transaction(s)',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Investment tx) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.payments, color: AppColors.primaryGreen, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#TX${tx.id} • ${tx.amount.toStringAsFixed(0)} MAD',
                        style: AppStyles.titleText,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Investisseur : ${tx.investorName}',
                        style: AppStyles.subtitleText.copyWith(color: AppColors.textMedium),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Projet : ${tx.projectTitle}',
                        style: AppStyles.subtitleText.copyWith(color: AppColors.textMedium),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.check_circle, color: AppColors.successGreen),
              ],
            ),
            const SizedBox(height: 8),
            if (tx.createdAt != null)
              Text(
                _formatDate(tx.createdAt),
                style: AppStyles.subtitleText.copyWith(
                  fontSize: 12,
                  color: AppColors.textMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
              ? _buildErrorState()
              : _transactions.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadTransactions,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ListView.separated(
                          itemCount: _transactions.length + 1,
                          separatorBuilder: (_, index) =>
                              index == 0 ? const SizedBox(height: 16) : const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            if (i == 0) {
                              return _buildSummaryCard();
                            }
                            final tx = _transactions[i - 1];
                            return _buildTransactionCard(tx);
                          },
                        ),
                      ),
                    ),
    );
  }
}


