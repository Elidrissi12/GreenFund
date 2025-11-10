import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static const _tokenKey = 'jwt_token';
  static const _userKey = 'user_data';
  static const _roleKey = 'user_role';

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) != null;
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
    
    // Sauvegarder le rôle séparément pour un accès rapide
    if (userData.containsKey('role')) {
      await prefs.setString(_roleKey, userData['role'].toString().toUpperCase());
    }
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataStr = prefs.getString(_userKey);
    if (userDataStr != null) {
      try {
        return jsonDecode(userDataStr) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await ApiService.login(email, password);
      if (response.containsKey('token')) {
        await saveToken(response['token']);
        await saveUserData(response);
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
    try {
      final response = await ApiService.register(name, email, password, role);
      if (response.containsKey('token')) {
        await saveToken(response['token']);
        await saveUserData(response);
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_roleKey);
  }
}
