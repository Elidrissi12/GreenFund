import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project.dart';

class ApiService {
  // Configuration de l'URL de base selon la plateforme
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    } else if (Platform.isAndroid) {
      // Pour Android Emulator
      return 'http://10.0.2.2:8080/api';
      // Pour Android device physique, utilisez l'IP de votre machine:
      // return 'http://192.168.x.x:8080/api';
    } else if (Platform.isIOS) {
      // Pour iOS Simulator
      return 'http://localhost:8080/api';
      // Pour iOS device physique, utilisez l'IP de votre machine:
      // return 'http://192.168.x.x:8080/api';
    }
    return 'http://localhost:8080/api';
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final token = await _getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    if (requireAuth) {
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found. Please login again.');
      }
      headers['Authorization'] = 'Bearer $token';
    } else if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Authentication
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during login: $e');
    }
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role.toUpperCase(),
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during registration: $e');
    }
  }

  // Projects
  static Future<List<Project>> getProjects({String? status}) async {
    try {
      final headers = await _getHeaders();
      final url = status != null 
          ? '$baseUrl/projects?status=$status'
          : '$baseUrl/projects';
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Project.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load projects: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading projects: $e');
    }
  }

  static Future<Project> getProjectById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/projects/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Project.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load project: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading project: $e');
    }
  }

  static Future<Project> createProject({
    required String title,
    required String city,
    required String energyType,
    required String description,
    required double targetAmount,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/projects'),
        headers: headers,
        body: jsonEncode({
          'title': title,
          'city': city,
          'energyType': energyType.toUpperCase(),
          'description': description,
          'targetAmount': targetAmount,
        }),
      );

      if (response.statusCode == 200) {
        return Project.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create project: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating project: $e');
    }
  }

  static Future<List<Project>> getMyProjects() async {
    try {
      final headers = await _getHeaders(requireAuth: true);
      final response = await http.get(
        Uri.parse('$baseUrl/projects/my-projects'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Project.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else if (response.statusCode == 403) {
        throw Exception('Accès refusé. Vous devez être propriétaire de projet pour accéder à cette fonctionnalité.');
      } else {
        final errorBody = response.body;
        try {
          final errorJson = jsonDecode(errorBody);
          throw Exception(errorJson['message'] ?? 'Erreur lors du chargement des projets');
        } catch (_) {
          throw Exception('Erreur ${response.statusCode}: ${errorBody}');
        }
      }
    } catch (e) {
      if (e.toString().contains('No authentication token')) {
        rethrow;
      }
      throw Exception('Erreur lors du chargement de vos projets: ${e.toString()}');
    }
  }

  static Future<Project> updateProject({
    required String projectId,
    required String title,
    required String city,
    required String energyType,
    required String description,
    required double targetAmount,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/projects/$projectId'),
        headers: headers,
        body: jsonEncode({
          'title': title,
          'city': city,
          'energyType': energyType.toUpperCase(),
          'description': description,
          'targetAmount': targetAmount,
        }),
      );

      if (response.statusCode == 200) {
        return Project.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update project: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating project: $e');
    }
  }

  // Investments
  static Future<Map<String, dynamic>> investInProject(String projectId, double amount) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/investments/projects/$projectId'),
        headers: headers,
        body: jsonEncode({
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to invest: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during investment: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getMyInvestments() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/investments/my-investments'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => json as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load investments: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading investments: $e');
    }
  }

  // Admin
  static Future<List<Project>> getPendingProjects() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/projects/pending'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Project.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load pending projects: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading pending projects: $e');
    }
  }

  static Future<Project> validateProject(String projectId, String status) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/admin/projects/$projectId/validate?status=$status'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Project.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to validate project: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error validating project: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => json as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load users: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading users: $e');
    }
  }

  static Future<void> updateUserStatus(String userId, bool active) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/admin/users/$userId/status?active=$active'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update user status: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating user status: $e');
    }
  }

  static Future<Map<String, dynamic>> getStats() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load stats: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading stats: $e');
    }
  }

  static Future<List<dynamic>> getAllTransactions() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/transactions'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to load transactions: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading transactions: $e');
    }
  }
}

