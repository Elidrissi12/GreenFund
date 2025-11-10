import 'package:flutter/material.dart';
import '../features/investor/home_investor_page.dart';
import '../features/owner/home_owner_page.dart';
import '../features/admin/home_admin_page.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';

/// Helper pour la navigation selon le rôle de l'utilisateur
class NavigationHelper {
  /// Retourne la page d'accueil appropriée selon le rôle de l'utilisateur
  static Future<Widget> getHomePage() async {
    final role = await AuthService.getUserRole();
    
    switch (role?.toUpperCase()) {
      case 'ADMIN':
        return const HomeAdminPage();
      case 'OWNER':
        return const HomeOwnerPage();
      case 'INVESTOR':
        return const HomeInvestorPage();
      default:
        // Si aucun rôle trouvé, rediriger vers la page de connexion
        return const LoginScreen();
    }
  }

  /// Navigue vers la page d'accueil appropriée après connexion
  static Future<void> navigateToHome(BuildContext context, String role) async {
    Widget homePage;
    
    switch (role.toUpperCase()) {
      case 'ADMIN':
        homePage = const HomeAdminPage();
        break;
      case 'OWNER':
        homePage = const HomeOwnerPage();
        break;
      case 'INVESTOR':
        homePage = const HomeInvestorPage();
        break;
      default:
        homePage = const LoginScreen();
    }
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => homePage),
    );
  }
}

