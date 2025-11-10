# 🔧 Guide de Configuration - GreenFund

## 📋 Prérequis

- Java 17 ou 21
- Maven 3.6+
- MySQL 8.0+
- Flutter 3.0+
- Node.js (optionnel pour développement)

---

## 🗄️ Configuration de la Base de Données

### 1. Créer la base de données

```sql
CREATE DATABASE IF NOT EXISTS greenfund_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 2. Configurer les credentials MySQL

Éditez le fichier `greenfund-backend/src/main/resources/application.properties` :

```properties
spring.datasource.username=root
spring.datasource.password=VOTRE_MOT_DE_PASSE_MYSQL
```

---

## 🚀 Lancer le Backend Spring Boot

### 1. Ouvrir le projet backend

```bash
cd greenfund-backend
```

### 2. Configurer MySQL

Assurez-vous que MySQL est démarré et que la base de données existe.

### 3. Lancer l'application

**Option A : Via Maven**
```bash
./mvnw spring-boot:run
```

**Option B : Via IDE (IntelliJ IDEA)**
1. Ouvrir le projet dans IntelliJ IDEA
2. Lancer `GreenfundBackendApplication.java`

### 4. Vérifier que le backend fonctionne

Ouvrez votre navigateur et allez sur : `http://localhost:8080/api/auth/login`

Vous devriez voir une erreur JSON (c'est normal, cela signifie que le serveur répond).

### 5. Créer un utilisateur admin (automatique)

L'application créera automatiquement un utilisateur admin au démarrage :
- **Email** : `admin@greenfund.com`
- **Password** : `admin123`
- **Rôle** : `ADMIN`

---

## 📱 Configuration du Frontend Flutter

### 1. Configurer l'URL du backend

Éditez le fichier `lib/services/api_service.dart` :

```dart
static String get baseUrl {
  if (kIsWeb) {
    return 'http://localhost:8080/api';
  } else if (Platform.isAndroid) {
    // Pour Android Emulator
    return 'http://10.0.2.2:8080/api';
    // Pour Android device physique, remplacez par l'IP de votre machine:
    // return 'http://192.168.1.XXX:8080/api';
  } else if (Platform.isIOS) {
    // Pour iOS Simulator
    return 'http://localhost:8080/api';
    // Pour iOS device physique, remplacez par l'IP de votre machine:
    // return 'http://192.168.1.XXX:8080/api';
  }
  return 'http://localhost:8080/api';
}
```

### 2. Trouver l'IP de votre machine

**Windows :**
```bash
ipconfig
```
Cherchez l'adresse IPv4 (ex: 192.168.1.100)

**Mac/Linux :**
```bash
ifconfig
```
ou
```bash
ip addr show
```

### 3. Installer les dépendances Flutter

```bash
cd GreenFund
flutter pub get
```

### 4. Lancer l'application Flutter

**Android :**
```bash
flutter run
```

**iOS :**
```bash
flutter run
```

**Web :**
```bash
flutter run -d chrome
```

---

## 🧪 Tester l'application

### 1. Créer un compte

1. Ouvrez l'application Flutter
2. Cliquez sur "Créer un compte"
3. Remplissez le formulaire :
   - Nom : Votre nom
   - Email : votre@email.com
   - Mot de passe : votre mot de passe
   - Rôle : Investisseur ou Porteur

### 2. Se connecter

1. Utilisez l'email et le mot de passe créés
2. Ou utilisez le compte admin :
   - Email : `admin@greenfund.com`
   - Password : `admin123`

### 3. Tester les fonctionnalités

**En tant qu'Investisseur :**
- Voir les projets disponibles
- Investir dans un projet

**En tant que Porteur :**
- Créer un projet
- Voir mes projets
- Voir les financements reçus

**En tant qu'Admin :**
- Valider les projets
- Gérer les utilisateurs
- Voir les statistiques

---

## 🔧 Dépannage

### Le backend ne démarre pas

1. **Vérifiez que MySQL est démarré**
   ```bash
   # Windows
   net start MySQL80
   
   # Mac/Linux
   sudo systemctl start mysql
   ```

2. **Vérifiez les credentials MySQL dans `application.properties`**

3. **Vérifiez que le port 8080 est libre**
   ```bash
   # Windows
   netstat -ano | findstr :8080
   
   # Mac/Linux
   lsof -i :8080
   ```

### L'application Flutter ne se connecte pas au backend

1. **Vérifiez que le backend est démarré**
   - Ouvrez `http://localhost:8080/api/auth/login` dans votre navigateur

2. **Vérifiez l'URL dans `api_service.dart`**
   - Pour Android Emulator : `http://10.0.2.2:8080/api`
   - Pour iOS Simulator : `http://localhost:8080/api`
   - Pour device physique : `http://VOTRE_IP:8080/api`

3. **Vérifiez le firewall**
   - Assurez-vous que le port 8080 est autorisé

4. **Vérifiez la connexion réseau**
   - Pour device physique, assurez-vous que l'appareil et l'ordinateur sont sur le même réseau WiFi

### Erreur CORS

Si vous voyez des erreurs CORS, vérifiez que `SecurityConfig.java` autorise votre origine :

```java
configuration.setAllowedOrigins(Arrays.asList(
    "http://localhost:3000",
    "http://localhost:5000",
    "http://127.0.0.1:5000"
));
```

---

## 📝 Notes importantes

1. **Sécurité** : En production, changez le secret JWT dans `application.properties`
2. **Base de données** : En production, utilisez des migrations (Flyway/Liquibase)
3. **URLs** : Adaptez les URLs selon votre environnement

---

## 🚀 Prochaines étapes

1. ✅ Tester toutes les fonctionnalités
2. ✅ Ajouter des tests
3. ✅ Déployer en production
4. ✅ Configurer HTTPS
5. ✅ Ajouter la gestion des images

---

*Guide de configuration créé pour GreenFund - Mise à jour régulière recommandée*

