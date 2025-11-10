import 'dart:convert';

/// Modèle représentant un investissement.
class Investment {
  final String id;
  final double amount;
  final String projectId;
  final String projectTitle;
  final String investorId;
  final String investorName;
  final DateTime? createdAt;

  Investment({
    required this.id,
    required this.amount,
    required this.projectId,
    required this.projectTitle,
    required this.investorId,
    required this.investorName,
    this.createdAt,
  });

  /// Créer un Investment depuis JSON
  factory Investment.fromJson(Map<String, dynamic> json) {
    DateTime? createdAt;
    if (json['createdAt'] != null) {
      if (json['createdAt'] is String) {
        createdAt = DateTime.tryParse(json['createdAt']);
      } else if (json['createdAt'] is Map) {
        // Format avec année, mois, jour, etc.
        final dateMap = json['createdAt'] as Map<String, dynamic>;
        createdAt = DateTime(
          dateMap['year'] ?? DateTime.now().year,
          dateMap['monthValue'] ?? DateTime.now().month,
          dateMap['dayOfMonth'] ?? DateTime.now().day,
          dateMap['hour'] ?? 0,
          dateMap['minute'] ?? 0,
          dateMap['second'] ?? 0,
        );
      }
    }

    return Investment(
      id: json['id'].toString(),
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : (json['amount'] as num).toDouble(),
      projectId: json['projectId'].toString(),
      projectTitle: json['projectTitle'] ?? '',
      investorId: json['investorId'].toString(),
      investorName: json['investorName'] ?? '',
      createdAt: createdAt,
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'projectId': projectId,
      'projectTitle': projectTitle,
      'investorId': investorId,
      'investorName': investorName,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

