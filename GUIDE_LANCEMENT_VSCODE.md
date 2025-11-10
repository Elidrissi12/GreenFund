# Guide : Lancer le Frontend Flutter avec VSCode

## 📋 Prérequis

### 1. Installer Flutter SDK
- Téléchargez Flutter depuis : https://flutter.dev/docs/get-started/install
- Extrayez le SDK dans un dossier (ex: `C:\src\flutter`)
- Ajoutez Flutter au PATH de votre système

### 2. Vérifier l'installation
Ouvrez un terminal PowerShell et exécutez :
```powershell
flutter doctor
```

Assurez-vous que :
- ✅ Flutter est installé
- ✅ Android Studio est installé (pour Android)
- ✅ VS Code est installé
- ✅ Chrome est installé (pour le web)

## 🔧 Configuration VSCode

### 1. Installer les extensions nécessaires

Dans VSCode, installez ces extensions :

1. **Flutter** (par Dart Code)
   - Extension ID: `Dart-Code.flutter`
   - Installe automatiquement l'extension Dart
   - Ou recherchez "Flutter" dans l'onglet Extensions (`Ctrl + Shift + X`)

2. **Dart** (par Dart Code)
   - Extension ID: `Dart-Code.dart-code`
   - Généralement installée automatiquement avec Flutter

### 2. Configuration des fichiers VSCode (Optionnel)

Créez un dossier `.vscode` à la racine du projet et ajoutez ces fichiers :

**`.vscode/launch.json`** :
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter (Chrome)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "deviceId": "chrome"
    },
    {
      "name": "Flutter (Android)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "deviceId": "android"
    }
  ]
}
```

**`.vscode/settings.json`** :
```json
{
  "dart.flutterSdkPath": null,
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "Dart-Code.dart-code",
  "[dart]": {
    "editor.formatOnSave": true
  }
}
```

### 3. Ouvrir le projet

1. Dans VSCode, cliquez sur **File > Open Folder**
2. Sélectionnez le dossier `GreenFund` (le dossier racine du projet Flutter)
3. VSCode devrait détecter automatiquement que c'est un projet Flutter

### 4. Vérifier la configuration

1. Ouvrez un terminal dans VSCode : **Terminal > New Terminal** (ou `Ctrl + ù`)
2. Vérifiez que Flutter est reconnu :
```powershell
flutter --version
```

3. Vérifiez les dépendances :
```powershell
flutter pub get
```

## 🚀 Lancer l'application

### Option 1 : Via la barre de commandes VSCode

1. Appuyez sur `F5` ou cliquez sur **Run > Start Debugging**
2. Ou utilisez `Ctrl + F5` pour **Run > Start Without Debugging**

### Option 2 : Via le terminal

#### Pour Web (Chrome)
```powershell
flutter run -d chrome
```

#### Pour Android (Emulator ou Device)
```powershell
# Vérifier les devices disponibles
flutter devices

# Lancer sur un device spécifique
flutter run -d <device-id>
```

#### Pour Windows Desktop
```powershell
flutter run -d windows
```

### Option 3 : Via la palette de commandes

1. Appuyez sur `Ctrl + Shift + P`
2. Tapez `Flutter: Select Device`
3. Choisissez votre device (Chrome, Android Emulator, etc.)
4. Appuyez sur `F5` pour lancer

## 📱 Sélectionner un device

### Voir les devices disponibles
```powershell
flutter devices
```

### Exemples de sortie :
```
3 connected devices:

Chrome (web) • chrome • web-javascript • Google Chrome 120.0.0.0
Windows (desktop) • windows • windows-x64 • Microsoft Windows [Version 10.0.26200]
sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64 • Android 14 (API 34)
```

### Sélectionner un device via VSCode
1. Regardez en bas à droite de VSCode, vous verrez le device actuel
2. Cliquez dessus pour changer de device
3. Ou utilisez `Ctrl + Shift + P` > `Flutter: Select Device`

## 🔍 Commandes utiles

### Hot Reload
- Appuyez sur `r` dans le terminal où l'app tourne
- Ou cliquez sur le bouton 🔄 dans VSCode

### Hot Restart
- Appuyez sur `R` (majuscule) dans le terminal
- Ou utilisez `Ctrl + Shift + F5`

### Quitter
- Appuyez sur `q` dans le terminal

### Voir les logs
- Les logs s'affichent dans le terminal
- Ou dans la console Debug de VSCode (View > Debug Console)

## ⚙️ Configuration pour le backend

### Important : URL du backend

Avant de lancer l'application, assurez-vous que le backend Spring Boot est démarré sur le port 8080.

L'URL de base est configurée dans `lib/services/api_service.dart` :
- **Web** : `http://localhost:8080/api`
- **Android Emulator** : `http://10.0.2.2:8080/api`
- **iOS Simulator** : `http://localhost:8080/api`
- **Android Device physique** : `http://[IP_DE_VOTRE_MACHINE]:8080/api`

### Pour Android Device physique

1. Trouvez l'IP de votre machine :
```powershell
ipconfig
```
Cherchez l'adresse IPv4 (ex: `192.168.1.100`)

2. Modifiez `lib/services/api_service.dart` :
```dart
static String get baseUrl {
  if (kIsWeb) {
    return 'http://localhost:8080/api';
  } else if (Platform.isAndroid) {
    // Pour Android device physique, utilisez l'IP de votre machine:
    return 'http://192.168.1.100:8080/api'; // Remplacez par votre IP
  }
  // ...
}
```

## 🐛 Résolution de problèmes

### Problème : "No devices found"
**Solution :**
- Pour Web : Installez Chrome
- Pour Android : Démarrez un émulateur Android ou connectez un device
- Vérifiez avec `flutter devices`

### Problème : "Flutter command not found"
**Solution :**
- Ajoutez Flutter au PATH système
- Redémarrez VSCode
- Vérifiez avec `flutter --version` dans un nouveau terminal

### Problème : "Error: No pubspec.yaml file found"
**Solution :**
- Assurez-vous d'être dans le dossier racine du projet Flutter
- Le fichier `pubspec.yaml` doit être présent

### Problème : "Failed to connect to backend"
**Solution :**
1. Vérifiez que le backend Spring Boot est démarré
2. Testez l'URL dans un navigateur : `http://localhost:8080/api/projects`
3. Vérifiez les permissions réseau (firewall)
4. Pour Android device, utilisez l'IP de votre machine au lieu de localhost

### Problème : "Package not found"
**Solution :**
```powershell
flutter pub get
flutter clean
flutter pub get
```

### Problème : "Build failed"
**Solution :**
```powershell
flutter clean
flutter pub get
flutter run
```

## 📝 Workflow recommandé

1. **Démarrer le backend** (dans un terminal séparé)
   ```powershell
   cd greenfund-backend
   .\mvnw.cmd spring-boot:run
   ```

2. **Ouvrir le projet Flutter dans VSCode**
   - Ouvrir le dossier `GreenFund`

3. **Installer les dépendances**
   ```powershell
   flutter pub get
   ```

4. **Sélectionner un device**
   - Cliquez sur le device en bas à droite de VSCode
   - Ou `Ctrl + Shift + P` > `Flutter: Select Device`

5. **Lancer l'application**
   - Appuyez sur `F5`
   - Ou `flutter run -d chrome` dans le terminal

6. **Développer avec Hot Reload**
   - Modifiez le code
   - Appuyez sur `r` pour recharger
   - Appuyez sur `R` pour redémarrer complètement

## 🎯 Raccourcis clavier utiles

- `F5` : Lancer/Déboguer
- `Ctrl + F5` : Lancer sans déboguer
- `Shift + F5` : Arrêter
- `Ctrl + Shift + P` : Palette de commandes
- `r` : Hot Reload (dans le terminal de l'app)
- `R` : Hot Restart (dans le terminal de l'app)
- `q` : Quitter (dans le terminal de l'app)

## 📚 Ressources supplémentaires

- Documentation Flutter : https://flutter.dev/docs
- Documentation VSCode Flutter : https://dartcode.org/docs/
- Guide de débogage : https://flutter.dev/docs/testing/debugging

---

**Note** : Si vous rencontrez des problèmes, vérifiez toujours `flutter doctor` pour identifier les problèmes de configuration.

