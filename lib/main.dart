import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'utils/navigation_helper.dart';
import 'services/auth_service.dart';
import 'theme/colors.dart';
import 'theme/styles.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenFund',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryGreen,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          primary: AppColors.primaryGreen,
          secondary: AppColors.accentGreen,
          surface: AppColors.surface,
          background: AppColors.background,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.background,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.lightGreen, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppStyles.greenButton,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: AppColors.primaryGreen,
          unselectedItemColor: Colors.grey,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          indicatorColor: AppColors.lightGreen,
          labelTextStyle: MaterialStatePropertyAll(TextStyle(color: AppColors.primaryGreen)),
          iconTheme: MaterialStatePropertyAll(IconThemeData(color: AppColors.primaryGreen)),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primaryGreen,
        ),
      ),
      home: FutureBuilder<bool>(
        future: AuthService.isLoggedIn(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.data!) {
            // Utilisateur connecté, rediriger vers la page appropriée selon le rôle
            return FutureBuilder<Widget>(
              future: NavigationHelper.getHomePage(),
              builder: (context, homeSnapshot) {
                if (!homeSnapshot.hasData) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return homeSnapshot.data!;
              },
            );
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
