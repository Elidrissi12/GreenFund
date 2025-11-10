import 'package:flutter/material.dart';

/// Profil utilisateur (lecture seule pour l’instant).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nom', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text('Utilisateur Démo', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Text('Email', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text('demo@greenfund.ma', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


