import 'package:flutter/foundation.dart';
import 'dart:convert';

/// Modèle représentant un projet d'énergie renouvelable.
class Project {
  final String id;
  final String title;
  final String city;
  final String energyType; // e.g. SOLAIRE, EOLIENNE, BIOGAZ
  final String description;
  final double targetAmount; // Objectif (MAD)
  final double raisedAmount; // Montant collecté (MAD)
  final String? status;
  final double? progressPercentage;

  Project({
    required this.id,
    required this.title,
    required this.city,
    required this.energyType,
    required this.description,
    required this.targetAmount,
    required this.raisedAmount,
    this.status,
    this.progressPercentage,
  });

  /// Progression entre 0 et 1, clampée.
  double get progress {
    if (progressPercentage != null) {
      return (progressPercentage! / 100).clamp(0.0, 1.0);
    }
    if (targetAmount <= 0) return 0;
    final ratio = raisedAmount / targetAmount;
    if (ratio < 0) return 0;
    if (ratio > 1) return 1;
    return ratio;
  }

  /// Créer un Project depuis JSON
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      city: json['city'] ?? '',
      energyType: json['energyType'] ?? '',
      description: json['description'] ?? '',
      targetAmount: (json['targetAmount'] is int)
          ? (json['targetAmount'] as int).toDouble()
          : (json['targetAmount'] as num).toDouble(),
      raisedAmount: (json['raisedAmount'] is int)
          ? (json['raisedAmount'] as int).toDouble()
          : (json['raisedAmount'] as num).toDouble(),
      status: json['status'],
      progressPercentage: json['progress'] != null
          ? (json['progress'] is int)
              ? (json['progress'] as int).toDouble()
              : (json['progress'] as num).toDouble()
          : null,
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'city': city,
      'energyType': energyType,
      'description': description,
      'targetAmount': targetAmount,
      'raisedAmount': raisedAmount,
      'status': status,
      'progress': progressPercentage,
    };
  }

  Project copyWith({
    String? id,
    String? title,
    String? city,
    String? energyType,
    String? description,
    double? targetAmount,
    double? raisedAmount,
    String? status,
    double? progressPercentage,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      city: city ?? this.city,
      energyType: energyType ?? this.energyType,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      raisedAmount: raisedAmount ?? this.raisedAmount,
      status: status ?? this.status,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }
}


