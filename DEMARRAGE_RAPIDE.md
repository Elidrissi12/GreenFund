# 🚀 Démarrage Rapide - Frontend Flutter

## Étapes rapides pour lancer l'application

### 1️⃣ Préparer l'environnement

```powershell
# Vérifier que Flutter est installé
flutter --version

# Vérifier l'état de l'installation
flutter doctor
```

### 2️⃣ Installer les dépendances

```powershell
# Dans le dossier GreenFund
cd C:\Users\ABDO EL IDRISSI\Desktop\GreenFund
flutter pub get
```

### 3️⃣ Démarrer le backend (dans un terminal séparé)

```powershell
# Dans le dossier greenfund-backend
cd C:\Users\ABDO EL IDRISSI\Desktop\greenfund-backend
.\mvnw.cmd spring-boot:run
```

Attendez que le backend démarre (vous verrez "Started GreenFundBackendApplication").

### 4️⃣ Lancer le frontend Flutter

#### Option A : Via VSCode (Recommandé)
1. Ouvrez VSCode dans le dossier `GreenFund`
2. Appuyez sur **F5**
3. Sélectionnez **Chrome** ou **Android** dans la liste des devices

#### Option B : Via Terminal
```powershell
# Pour Web (Chrome)
flutter run -d chrome

# Pour Android (si vous avez un émulateur)
flutter run -d android

# Pour voir tous les devices disponibles
flutter devices
```

### 5️⃣ Tester l'application

1. L'application devrait s'ouvrir dans Chrome ou l'émulateur
2. Testez la connexion :
   - Email : `admin@greenfund.com`
   - Mot de passe : `admin123` (si vous avez créé un admin)
   - Ou créez un nouveau compte

## ⚡ Commandes utiles pendant l'exécution

- **`r`** : Hot Reload (recharge rapide)
- **`R`** : Hot Restart (redémarrage complet)
- **`q`** : Quitter l'application

## 🔧 Si vous avez des erreurs

### Erreur : "No devices found"
```powershell
# Vérifier les devices
flutter devices

# Si aucun device, installez Chrome ou démarrez un émulateur Android
```

### Erreur : "Failed to connect to backend"
1. Vérifiez que le backend est démarré sur le port 8080
2. Testez dans le navigateur : `http://localhost:8080/api/projects`
3. Vérifiez les permissions du firewall

### Erreur : "Package not found"
```powershell
flutter clean
flutter pub get
flutter run
```

## 📱 Pour Android Device Physique

1. Activez le mode développeur et le débogage USB sur votre téléphone
2. Connectez votre téléphone via USB
3. Autorisez le débogage USB
4. Vérifiez que le device est détecté :
```powershell
flutter devices
```
5. Lancez l'application :
```powershell
flutter run -d <device-id>
```

**Important** : Pour que votre téléphone puisse accéder au backend, modifiez l'URL dans `lib/services/api_service.dart` :
```dart
// Remplacez localhost par l'IP de votre machine
return 'http://192.168.1.XXX:8080/api'; // Votre IP locale
```

Pour trouver votre IP :
```powershell
ipconfig
# Cherchez "Adresse IPv4" (ex: 192.168.1.100)
```

---

**Besoin d'aide ?** Consultez `GUIDE_LANCEMENT_VSCODE.md` pour plus de détails.

