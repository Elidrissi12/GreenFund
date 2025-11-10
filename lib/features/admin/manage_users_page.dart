import 'package:flutter/material.dart';
import '../../services/api_service.dart';

/// Gestion utilisateurs depuis l'API: activer/désactiver.
class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await ApiService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserStatus(String userId, bool active) async {
    try {
      await ApiService.updateUserStatus(userId, active);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Statut utilisateur ${active ? 'activé' : 'désactivé'}'),
          backgroundColor: Colors.green,
        ),
      );
      _loadUsers(); // Recharger la liste
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer utilisateurs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
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
                        onPressed: _loadUsers,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _users.isEmpty
                  ? const Center(child: Text('Aucun utilisateur'))
                  : RefreshIndicator(
                      onRefresh: _loadUsers,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ListView.separated(
                          itemCount: _users.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final user = _users[i];
                            final userId = user['id'].toString();
                            final isActive = user['active'] ?? true;
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: SwitchListTile(
                                title: Text(
                                  user['name'] ?? 'Utilisateur',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('${user['email'] ?? ''} • ${user['role'] ?? ''}'),
                                value: isActive,
                                onChanged: (value) => _updateUserStatus(userId, value),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
    );
  }
}


