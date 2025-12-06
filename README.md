# GreenFund - Application Flutter

Plateforme de micro-financement pour projets d'énergies renouvelables locales.

## Fonctionnalités
- Authentification (Login/Register)
- Gestion de projets (Investisseur, Porteur, Admin)
- Système d'investissement
- Tableau de bord administrateur
- Statistiques en temps réel
## Prérequis

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code avec extensions Flutter
- Un émulateur Android/iOS ou un appareil physique
- Backend Spring Boot en cours d'exécution (port 8080)
## Installation

1. Cloner le repository
git clone [url-du-repo]
cd GreenFund2. Installer les dépendances
flutter pub get3. Vérifier l'installation
flutter doctor


### 4. **Configuration**
## Configuration

### Configuration de l'API

L'URL de l'API est configurée dans `lib/services/api_service.dart` :

- **Web** : `http://localhost:8080/api`
- **Android Emulator** : `http://10.0.2.2:8080/api`
- **iOS Simulator** : `http://localhost:8080/api`
- **Appareil physique** : Utiliser l'IP de votre machine (ex: `http://192.168.x.x:8080/api`)

Pour modifier l'URL, éditez la méthode `baseUrl` dans `api_service.dart`.



### 6. **Structure du projet**
## Structure du projet

s fichiers dans `lib/theme/` (colors.dart, styles.dart)
2. **Ne jamais modifier** `main.dart`
3. Utiliser **uniquement** `AppColors` et `AppStyles` pour les couleurs et styles
4. Suivre la structure de dossiers existante
5. Ajouter des commentaires pour les fonctions complexes


## Build et déploiement

### Android APK
flutter build apk --releaseLe fichier APK sera dans `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (pour Google Play)
flutter build appbundle --release### iOS
flutter build ios --release

## Comptes de test

### Administrateur
- Email: `admin@greenfund.com`
- Mot de passe: `admin123`

### Créer un compte
Utilisez la page d'inscription pour créer un compte Investisseur ou Porteur de projet.

## Contribution

1. Créer une branche pour votre fonctionnalité
2. Suivre les règles de style du projet
3. Tester vos modifications
4. Créer une pull request
