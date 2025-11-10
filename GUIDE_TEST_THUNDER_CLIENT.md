# Guide : Tester le Backend avec Thunder Client

## 📋 Installation de Thunder Client

1. Ouvrez VSCode
2. Allez dans **Extensions** (`Ctrl + Shift + X`)
3. Recherchez **"Thunder Client"**
4. Installez l'extension (par Ranga Vadhineni)

## 🚀 Configuration initiale

### 1. Démarrer le backend

Assurez-vous que le backend Spring Boot est démarré :

```powershell
cd greenfund-backend
.\mvnw.cmd spring-boot:run
```

Attendez que vous voyiez : `Started GreenFundBackendApplication`

### 2. Ouvrir Thunder Client

1. Dans VSCode, cliquez sur l'icône **Thunder Client** dans la barre latérale (ou `Ctrl + Shift + T`)
2. Cliquez sur **New Request**

## 🔐 Tests d'authentification

### Test 1 : Inscription (Register)

**Méthode** : `POST`  
**URL** : `http://localhost:8080/api/auth/register`

**Headers** :
```
Content-Type: application/json
```

**Body** (JSON) :
```json
{
  "name": "Test User",
  "email": "test@example.com",
  "password": "password123",
  "role": "INVESTOR"
}
```

**Rôles possibles** :
- `INVESTOR` - Investisseur
- `OWNER` - Porteur de projet
- `ADMIN` - Administrateur

**Réponse attendue** (200 OK) :
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "id": 1,
  "name": "Test User",
  "email": "test@example.com",
  "role": "INVESTOR"
}
```

**⚠️ Important** : Copiez le `token` pour les requêtes suivantes !

### Test 2 : Connexion (Login)

**Méthode** : `POST`  
**URL** : `http://localhost:8080/api/auth/login`

**Headers** :
```
Content-Type: application/json
```

**Body** (JSON) :
```json
{
  "email": "test@example.com",
  "password": "password123"
}
```

**Réponse attendue** (200 OK) :
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "id": 1,
  "name": "Test User",
  "email": "test@example.com",
  "role": "INVESTOR"
}
```

### Test 3 : Connexion Admin (par défaut)

**Méthode** : `POST`  
**URL** : `http://localhost:8080/api/auth/login`

**Body** (JSON) :
```json
{
  "email": "admin@greenfund.com",
  "password": "admin123"
}
```

## 📦 Tests des Projets

### Test 4 : Lister tous les projets (Public)

**Méthode** : `GET`  
**URL** : `http://localhost:8080/api/projects`

**Headers** : Aucun (endpoint public)

**Réponse attendue** (200 OK) :
```json
[
  {
    "id": 1,
    "title": "Parc solaire Casablanca",
    "city": "Casablanca",
    "energyType": "SOLAIRE",
    "description": "Installation de panneaux solaires",
    "targetAmount": 100000.00,
    "raisedAmount": 0.00,
    "status": "APPROVED",
    "progress": 0.0,
    "ownerId": 2,
    "ownerName": "Owner Name",
    "createdAt": "2024-01-01T10:00:00"
  }
]
```

### Test 5 : Obtenir un projet par ID (Public)

**Méthode** : `GET`  
**URL** : `http://localhost:8080/api/projects/1`

**Headers** : Aucun (endpoint public)

### Test 6 : Créer un projet (OWNER uniquement)

**Méthode** : `POST`  
**URL** : `http://localhost:8080/api/projects`

**Headers** :
```
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN_HERE
```

**Body** (JSON) :
```json
{
  "title": "Nouveau projet éolien",
  "city": "Rabat",
  "energyType": "EOLIENNE",
  "description": "Installation d'éoliennes pour production d'énergie renouvelable",
  "targetAmount": 50000.00
}
```

**Types d'énergie possibles** :
- `SOLAIRE`
- `EOLIENNE`
- `BIOGAZ`

**Réponse attendue** (200 OK) :
```json
{
  "id": 2,
  "title": "Nouveau projet éolien",
  "city": "Rabat",
  "energyType": "EOLIENNE",
  "description": "Installation d'éoliennes...",
  "targetAmount": 50000.00,
  "raisedAmount": 0.00,
  "status": "PENDING",
  "progress": 0.0,
  "ownerId": 2,
  "ownerName": "Owner Name",
  "createdAt": "2024-01-01T10:00:00"
}
```

### Test 7 : Modifier un projet (OWNER uniquement)

**Méthode** : `PUT`  
**URL** : `http://localhost:8080/api/projects/2`

**Headers** :
```
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN_HERE
```

**Body** (JSON) :
```json
{
  "title": "Projet éolien modifié",
  "city": "Tanger",
  "energyType": "EOLIENNE",
  "description": "Description mise à jour",
  "targetAmount": 60000.00
}
```

**⚠️ Note** : Ne peut pas modifier un projet qui a déjà reçu des investissements.

### Test 8 : Mes projets (OWNER uniquement)

**Méthode** : `GET`  
**URL** : `http://localhost:8080/api/projects/my-projects`

**Headers** :
```
Authorization: Bearer YOUR_TOKEN_HERE
```

## 💰 Tests des Investissements

### Test 9 : Investir dans un projet (INVESTOR uniquement)

**Méthode** : `POST`  
**URL** : `http://localhost:8080/api/investments/1`

**Headers** :
```
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN_HERE
```

**Body** (JSON) :
```json
{
  "amount": 1000.00
}
```

**Réponse attendue** (200 OK) :
```json
{
  "id": 1,
  "amount": 1000.00,
  "projectId": 1,
  "projectTitle": "Parc solaire Casablanca",
  "investorId": 1,
  "investorName": "Test User",
  "createdAt": "2024-01-01T10:00:00"
}
```

### Test 10 : Mes investissements (INVESTOR uniquement)

**Méthode** : `GET`  
**URL** : `http://localhost:8080/api/investments/my-investments`

**Headers** :
```
Authorization: Bearer YOUR_TOKEN_HERE
```

## 👨‍💼 Tests Admin

### Test 11 : Projets en attente (ADMIN uniquement)

**Méthode** : `GET`  
**URL** : `http://localhost:8080/api/admin/projects/pending`

**Headers** :
```
Authorization: Bearer YOUR_ADMIN_TOKEN_HERE
```

### Test 12 : Valider un projet (ADMIN uniquement)

**Méthode** : `PUT`  
**URL** : `http://localhost:8080/api/admin/projects/2/validate?status=APPROVED`

**Headers** :
```
Authorization: Bearer YOUR_ADMIN_TOKEN_HERE
```

**Statuts possibles** :
- `APPROVED` - Approuvé
- `REJECTED` - Rejeté
- `ACTIVE` - Actif
- `COMPLETED` - Complété
- `CANCELLED` - Annulé

### Test 13 : Rejeter un projet (ADMIN uniquement)

**Méthode** : `PUT`  
**URL** : `http://localhost:8080/api/admin/projects/2/validate?status=REJECTED`

**Headers** :
```
Authorization: Bearer YOUR_ADMIN_TOKEN_HERE
```

### Test 14 : Liste des utilisateurs (ADMIN uniquement)

**Méthode** : `GET`  
**URL** : `http://localhost:8080/api/admin/users`

**Headers** :
```
Authorization: Bearer YOUR_ADMIN_TOKEN_HERE
```

### Test 15 : Activer/Désactiver un utilisateur (ADMIN uniquement)

**Méthode** : `PUT`  
**URL** : `http://localhost:8080/api/admin/users/1/status?active=false`

**Headers** :
```
Authorization: Bearer YOUR_ADMIN_TOKEN_HERE
```

### Test 16 : Statistiques (ADMIN uniquement)

**Méthode** : `GET`  
**URL** : `http://localhost:8080/api/admin/stats`

**Headers** :
```
Authorization: Bearer YOUR_ADMIN_TOKEN_HERE
```

**Réponse attendue** (200 OK) :
```json
{
  "totalProjects": 10,
  "pendingProjects": 2,
  "activeProjects": 5,
  "completedProjects": 2,
  "totalUsers": 15
}
```

### Test 17 : Toutes les transactions (ADMIN uniquement)

**Méthode** : `GET`  
**URL** : `http://localhost:8080/api/admin/transactions`

**Headers** :
```
Authorization: Bearer YOUR_ADMIN_TOKEN_HERE
```

## 🔧 Utilisation avancée de Thunder Client

### Sauvegarder des variables d'environnement

1. Cliquez sur **Env** dans Thunder Client
2. Créez un nouvel environnement (ex: "Local")
3. Ajoutez des variables :
   - `baseUrl` : `http://localhost:8080/api`
   - `token` : (sera mis à jour après login)
   - `adminToken` : (sera mis à jour après login admin)

### Utiliser les variables dans les requêtes

Dans l'URL, utilisez : `{{baseUrl}}/auth/login`  
Dans les headers, utilisez : `Bearer {{token}}`

### Créer une collection

1. Cliquez sur **Collections** dans Thunder Client
2. Créez une nouvelle collection "GreenFund API"
3. Organisez vos requêtes par catégories :
   - Auth
   - Projects
   - Investments
   - Admin

### Scripts de test automatiques

Thunder Client supporte les scripts de test. Exemple pour vérifier le token :

```javascript
// Dans l'onglet "Tests" de Thunder Client
test("Status code is 200", function() {
  expect(res.status).to.equal(200);
});

test("Response has token", function() {
  const body = res.body;
  expect(body).to.have.property('token');
  expect(body.token).to.be.a('string');
});
```

## 📝 Workflow de test recommandé

### 1. Test complet du flux utilisateur

1. **Inscription** d'un investisseur
   - Copier le token
   
2. **Connexion** avec le même compte
   - Vérifier que le token est retourné
   
3. **Lister les projets** (sans token)
   - Vérifier que c'est accessible publiquement
   
4. **Investir** dans un projet
   - Utiliser le token de l'investisseur
   
5. **Voir mes investissements**
   - Vérifier que l'investissement apparaît

### 2. Test complet du flux porteur de projet

1. **Inscription** d'un porteur
   - Rôle : `OWNER`
   
2. **Créer un projet**
   - Vérifier que le statut est `PENDING`
   
3. **Voir mes projets**
   - Vérifier que le projet apparaît
   
4. **Modifier le projet**
   - Vérifier que la modification fonctionne

### 3. Test complet du flux admin

1. **Connexion admin**
   - Email : `admin@greenfund.com`
   - Password : `admin123`
   
2. **Voir les projets en attente**
   - Vérifier la liste
   
3. **Valider un projet**
   - Changer le statut à `APPROVED`
   
4. **Voir les statistiques**
   - Vérifier les compteurs
   
5. **Voir toutes les transactions**
   - Vérifier la liste complète

## 🐛 Résolution de problèmes

### Erreur 401 (Unauthorized)

**Cause** : Token manquant ou invalide

**Solution** :
- Vérifiez que le header `Authorization: Bearer TOKEN` est présent
- Vérifiez que le token n'a pas expiré (par défaut 24h)
- Reconnectez-vous pour obtenir un nouveau token

### Erreur 403 (Forbidden)

**Cause** : Rôle insuffisant

**Solution** :
- Vérifiez que vous utilisez le bon token (INVESTOR, OWNER, ou ADMIN)
- Vérifiez que l'endpoint correspond à votre rôle

### Erreur 404 (Not Found)

**Cause** : URL incorrecte ou ressource inexistante

**Solution** :
- Vérifiez l'URL complète
- Vérifiez que l'ID de la ressource existe
- Vérifiez que le backend est démarré

### Erreur 500 (Internal Server Error)

**Cause** : Erreur serveur

**Solution** :
- Vérifiez les logs du backend
- Vérifiez que la base de données est accessible
- Vérifiez les données envoyées (format JSON correct)

## 📚 Codes HTTP de référence

- **200 OK** : Requête réussie
- **201 Created** : Ressource créée
- **400 Bad Request** : Données invalides
- **401 Unauthorized** : Non authentifié
- **403 Forbidden** : Non autorisé (mauvais rôle)
- **404 Not Found** : Ressource introuvable
- **500 Internal Server Error** : Erreur serveur

## 💡 Astuces

1. **Sauvegarder les tokens** : Créez des variables d'environnement pour les tokens
2. **Dupliquer les requêtes** : Clic droit > Duplicate pour créer des variantes
3. **Historique** : Thunder Client garde un historique de toutes les requêtes
4. **Export/Import** : Vous pouvez exporter vos collections pour les partager
5. **Tests automatiques** : Utilisez les scripts de test pour valider automatiquement les réponses

---

**Note** : Assurez-vous toujours que le backend est démarré avant de tester les endpoints !

