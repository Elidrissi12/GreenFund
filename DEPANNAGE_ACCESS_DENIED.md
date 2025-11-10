# 🔧 Dépannage : Erreur "Access Denied"

## ❌ Problème

Vous voyez l'erreur : **"Access Denied"** ou **"Accès refusé"** lors du chargement des projets.

## 🔍 Causes possibles

### 1. **Mauvais rôle utilisateur** (Le plus probable)

L'endpoint `/api/projects/my-projects` nécessite le rôle **OWNER** (Porteur de projet).

**Solution :**
- Vérifiez que vous êtes connecté avec un compte **OWNER**
- Si vous êtes connecté en tant qu'**INVESTOR** ou **ADMIN**, vous ne pouvez pas accéder à cette page

**Comment vérifier :**
1. Déconnectez-vous
2. Créez un nouveau compte avec le rôle **"Porteur de projet"** (OWNER)
3. Ou connectez-vous avec un compte existant qui a le rôle OWNER

### 2. **Token manquant ou invalide**

Le token JWT n'est pas présent ou a expiré.

**Solution :**
1. Déconnectez-vous
2. Reconnectez-vous pour obtenir un nouveau token

### 3. **Backend non démarré**

Le backend Spring Boot n'est pas démarré ou n'est pas accessible.

**Solution :**
```powershell
cd greenfund-backend
.\mvnw.cmd spring-boot:run
```

Vérifiez que vous voyez : `Started GreenFundBackendApplication`

### 4. **URL incorrecte pour Android**

Sur Android Emulator, l'URL doit être `http://10.0.2.2:8080/api` (pas `localhost`).

**Vérification :**
Le fichier `lib/services/api_service.dart` doit contenir :
```dart
} else if (Platform.isAndroid) {
  return 'http://10.0.2.2:8080/api';
}
```

## ✅ Solutions étape par étape

### Solution 1 : Créer un compte OWNER

1. **Déconnectez-vous** de l'application
2. Cliquez sur **"Créer un compte"**
3. Remplissez le formulaire :
   - Nom complet
   - Email
   - Mot de passe
   - **Rôle : Sélectionnez "Porteur de projet"** (pas "Investisseur")
4. Cliquez sur **"S'inscrire"**
5. Vous serez automatiquement connecté avec le rôle OWNER
6. Retournez à l'**"Espace Porteur"**

### Solution 2 : Utiliser le compte admin

Le compte admin par défaut a tous les rôles, mais pour tester l'espace porteur :

1. **Déconnectez-vous**
2. **Créez un nouveau compte** avec le rôle **"Porteur de projet"**
3. Connectez-vous avec ce compte

### Solution 3 : Vérifier la connexion au backend

1. **Testez l'endpoint public** dans Thunder Client :
   ```
   GET http://localhost:8080/api/projects
   ```
   Si cela fonctionne, le backend est accessible.

2. **Testez la connexion** :
   ```
   POST http://localhost:8080/api/auth/login
   {
     "email": "votre-email@example.com",
     "password": "votre-mot-de-passe"
   }
   ```
   Copiez le token retourné.

3. **Testez l'endpoint my-projects** avec le token :
   ```
   GET http://localhost:8080/api/projects/my-projects
   Authorization: Bearer VOTRE_TOKEN
   ```
   Si vous obtenez 403, c'est que votre compte n'a pas le rôle OWNER.

## 🧪 Test rapide avec Thunder Client

1. **Inscription d'un OWNER** :
   ```
   POST http://localhost:8080/api/auth/register
   Content-Type: application/json
   
   {
     "name": "Test Owner",
     "email": "owner@test.com",
     "password": "password123",
     "role": "OWNER"
   }
   ```
   → Copiez le `token`

2. **Tester my-projects** :
   ```
   GET http://localhost:8080/api/projects/my-projects
   Authorization: Bearer VOTRE_TOKEN
   ```
   → Devrait retourner une liste (vide si aucun projet)

3. **Si vous obtenez 403** :
   - Votre compte n'a pas le rôle OWNER
   - Créez un nouveau compte avec `"role": "OWNER"`

## 📝 Vérification des rôles dans l'application

### Rôles disponibles :
- **INVESTOR** (Investisseur) :
  - Peut voir les projets
  - Peut investir dans les projets
  - Peut voir ses investissements
  - **NE PEUT PAS** créer ou modifier des projets

- **OWNER** (Porteur de projet) :
  - Peut créer des projets
  - Peut modifier ses projets
  - Peut voir ses projets et financements
  - **NE PEUT PAS** investir dans les projets

- **ADMIN** (Administrateur) :
  - Peut tout faire
  - Peut valider/rejeter les projets
  - Peut gérer les utilisateurs
  - Peut voir les statistiques

## 🔄 Redémarrage complet

Si rien ne fonctionne :

1. **Arrêtez l'application Flutter** (appuyez sur `q` dans le terminal)

2. **Arrêtez le backend** (Ctrl+C dans le terminal du backend)

3. **Redémarrez le backend** :
   ```powershell
   cd greenfund-backend
   .\mvnw.cmd spring-boot:run
   ```

4. **Nettoyez l'application Flutter** :
   ```powershell
   cd GreenFund
   flutter clean
   flutter pub get
   ```

5. **Relancez l'application** :
   ```powershell
   flutter run
   ```

6. **Créez un nouveau compte OWNER** et testez

## 💡 Message d'erreur amélioré

L'application affiche maintenant des messages d'erreur plus clairs :
- **"Session expirée"** → Reconnectez-vous
- **"Accès refusé. Vous devez être propriétaire de projet"** → Créez un compte OWNER
- **"Non autorisé"** → Vérifiez vos identifiants

---

**Si le problème persiste**, vérifiez les logs du backend pour plus de détails sur l'erreur.

