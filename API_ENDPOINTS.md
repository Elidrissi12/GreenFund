# 📡 API Endpoints - GreenFund Backend

## 🔐 Base URL
```
http://localhost:8080/api
```

## 🔑 Authentification
Tous les endpoints (sauf `/api/auth/**`) nécessitent un token JWT dans le header :
```
Authorization: Bearer <token>
```

---

## 🔓 Authentification (Public)

### POST /api/auth/register
**Description :** Inscription d'un nouvel utilisateur

**Request Body :**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "role": "INVESTOR"  // ou "OWNER"
}
```

**Response :**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "type": "Bearer",
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com",
  "role": "INVESTOR"
}
```

### POST /api/auth/login
**Description :** Connexion d'un utilisateur

**Request Body :**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response :**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "type": "Bearer",
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com",
  "role": "INVESTOR"
}
```

---

## 📦 Projets (Authentifié)

### GET /api/projects
**Description :** Liste des projets (public)

**Query Parameters :**
- `status` (optionnel) : PENDING, APPROVED, REJECTED, ACTIVE, COMPLETED, CANCELLED

**Response :**
```json
[
  {
    "id": 1,
    "title": "Panneaux solaires - Marrakech",
    "city": "Marrakech",
    "energyType": "SOLAIRE",
    "description": "Installation de 50 panneaux...",
    "targetAmount": 120000.00,
    "raisedAmount": 45000.00,
    "progress": 37.5,
    "status": "ACTIVE",
    "ownerId": 2,
    "ownerName": "Ahmed Benali",
    "createdAt": "2024-01-15T10:00:00",
    "updatedAt": "2024-01-20T15:30:00"
  }
]
```

### GET /api/projects/search
**Description :** Recherche de projets avec filtres (public)

**Query Params :**
```
keyword          (optionnel) - recherche sur titre / description / ville
city             (optionnel)
energyType       (optionnel) - SOLAIRE | EOLIENNE | BIOGAZ
status           (optionnel) - PENDING | APPROVED | ACTIVE | COMPLETED | CANCELLED | REJECTED
minTargetAmount  (optionnel) - Montant cible minimum (nombre)
maxTargetAmount  (optionnel) - Montant cible maximum (nombre)
minRaisedAmount  (optionnel) - Montant levé minimum (nombre)
maxRaisedAmount  (optionnel) - Montant levé maximum (nombre)
```

**Réponse :**
```json
[
  {
    "id": 1,
    "title": "Parc solaire Casablanca",
    "city": "Casablanca",
    "energyType": "SOLAIRE",
    "description": "Installation de panneaux solaires",
    "targetAmount": 100000.00,
    "raisedAmount": 45000.00,
    "progress": 45.0,
    "status": "APPROVED",
    "ownerId": 2,
    "ownerName": "Owner Name",
    "createdAt": "2024-01-01T10:00:00",
    "updatedAt": "2024-01-05T09:00:00"
  }
]
```

### GET /api/projects/{id}
**Description :** Détails d'un projet spécifique

**Response :**
```json
{
  "id": 1,
  "title": "Panneaux solaires - Marrakech",
  "city": "Marrakech",
  "energyType": "SOLAIRE",
  "description": "Installation de 50 panneaux...",
  "targetAmount": 120000.00,
  "raisedAmount": 45000.00,
  "progress": 37.5,
  "status": "ACTIVE",
  "ownerId": 2,
  "ownerName": "Ahmed Benali",
  "createdAt": "2024-01-15T10:00:00",
  "updatedAt": "2024-01-20T15:30:00"
}
```

### POST /api/projects
**Description :** Créer un nouveau projet (OWNER uniquement)

**Request Body :**
```json
{
  "title": "Panneaux solaires - Marrakech",
  "city": "Marrakech",
  "energyType": "SOLAIRE",
  "description": "Installation de 50 panneaux sur toits résidentiels.",
  "targetAmount": 120000.00
}
```

**Response :**
```json
{
  "id": 1,
  "title": "Panneaux solaires - Marrakech",
  "city": "Marrakech",
  "energyType": "SOLAIRE",
  "description": "Installation de 50 panneaux...",
  "targetAmount": 120000.00,
  "raisedAmount": 0.00,
  "progress": 0.0,
  "status": "PENDING",
  "ownerId": 2,
  "ownerName": "Ahmed Benali",
  "createdAt": "2024-01-15T10:00:00",
  "updatedAt": "2024-01-15T10:00:00"
}
```

### PUT /api/projects/{id}
**Description :** Modifier un projet (OWNER uniquement)

**Request Body :**
```json
{
  "title": "Panneaux solaires - Marrakech (Modifié)",
  "city": "Marrakech",
  "energyType": "SOLAIRE",
  "description": "Description mise à jour...",
  "targetAmount": 150000.00
}
```

---

## 💰 Investissements (Authentifié)

### POST /api/investments/projects/{projectId}
**Description :** Investir dans un projet (INVESTOR uniquement)

**Request Body :**
```json
{
  "amount": 5000.00
}
```

**Response :**
```json
{
  "id": 1,
  "amount": 5000.00,
  "projectId": 1,
  "projectTitle": "Panneaux solaires - Marrakech",
  "investorId": 1,
  "investorName": "John Doe",
  "createdAt": "2024-01-20T14:30:00"
}
```

### GET /api/investments/my-investments
**Description :** Liste de mes investissements (INVESTOR)

**Response :**
```json
[
  {
    "id": 1,
    "amount": 5000.00,
    "projectId": 1,
    "projectTitle": "Panneaux solaires - Marrakech",
    "investorId": 1,
    "investorName": "John Doe",
    "createdAt": "2024-01-20T14:30:00"
  },
  {
    "id": 2,
    "amount": 3000.00,
    "projectId": 2,
    "projectTitle": "Mini-éolienne - Agadir",
    "investorId": 1,
    "investorName": "John Doe",
    "createdAt": "2024-01-21T10:15:00"
  }
]
```

### GET /api/investments/projects/{projectId}
**Description :** Liste des investissements d'un projet (OWNER)

**Response :**
```json
[
  {
    "id": 1,
    "amount": 5000.00,
    "projectId": 1,
    "projectTitle": "Panneaux solaires - Marrakech",
    "investorId": 1,
    "investorName": "John Doe",
    "createdAt": "2024-01-20T14:30:00"
  }
]
```

---

## 👤 Utilisateurs (Authentifié)

### GET /api/users/me
**Description :** Informations de l'utilisateur connecté

**Response :**
```json
{
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com",
  "role": "INVESTOR",
  "active": true,
  "createdAt": "2024-01-10T08:00:00"
}
```

### GET /api/users/my-projects
**Description :** Mes projets (OWNER)

**Response :**
```json
[
  {
    "id": 1,
    "title": "Panneaux solaires - Marrakech",
    "city": "Marrakech",
    "energyType": "SOLAIRE",
    "description": "Installation de 50 panneaux...",
    "targetAmount": 120000.00,
    "raisedAmount": 45000.00,
    "progress": 37.5,
    "status": "ACTIVE",
    "ownerId": 2,
    "ownerName": "Ahmed Benali",
    "createdAt": "2024-01-15T10:00:00",
    "updatedAt": "2024-01-20T15:30:00"
  }
]
```

---

## 🔧 Administration (ADMIN uniquement)

### GET /api/admin/projects/pending
**Description :** Liste des projets en attente de validation

**Response :**
```json
[
  {
    "id": 1,
    "title": "Panneaux solaires - Marrakech",
    "city": "Marrakech",
    "energyType": "SOLAIRE",
    "description": "Installation de 50 panneaux...",
    "targetAmount": 120000.00,
    "raisedAmount": 0.00,
    "progress": 0.0,
    "status": "PENDING",
    "ownerId": 2,
    "ownerName": "Ahmed Benali",
    "createdAt": "2024-01-15T10:00:00",
    "updatedAt": "2024-01-15T10:00:00"
  }
]
```

### PUT /api/admin/projects/{id}/validate
**Description :** Valider ou rejeter un projet

**Query Parameters :**
- `status` : APPROVED, REJECTED, ACTIVE

**Example :**
```
PUT /api/admin/projects/1/validate?status=APPROVED
```

**Response :**
```json
{
  "id": 1,
  "title": "Panneaux solaires - Marrakech",
  "status": "APPROVED",
  ...
}
```

### GET /api/admin/users
**Description :** Liste de tous les utilisateurs

**Response :**
```json
[
  {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "INVESTOR",
    "active": true,
    "createdAt": "2024-01-10T08:00:00"
  }
]
```

### PUT /api/admin/users/{id}/status
**Description :** Activer/désactiver un utilisateur

**Request Body :**
```json
{
  "active": false
}
```

### GET /api/admin/stats
**Description :** Statistiques de la plateforme

**Response :**
```json
{
  "totalProjects": 50,
  "activeProjects": 12,
  "completedProjects": 8,
  "totalInvestments": 1500,
  "totalRaised": 2500000.00,
  "totalInvestors": 350,
  "totalOwners": 45
}
```

---

## 📊 Codes de statut HTTP

- `200 OK` : Requête réussie
- `201 Created` : Ressource créée avec succès
- `400 Bad Request` : Erreur de validation
- `401 Unauthorized` : Non authentifié
- `403 Forbidden` : Non autorisé (mauvais rôle)
- `404 Not Found` : Ressource non trouvée
- `500 Internal Server Error` : Erreur serveur

---

## 🔒 Rôles et permissions

### INVESTOR
- ✅ Consulter les projets
- ✅ Investir dans les projets
- ✅ Voir ses investissements
- ❌ Créer des projets
- ❌ Gérer les projets

### OWNER
- ✅ Créer des projets
- ✅ Modifier ses projets
- ✅ Voir ses projets
- ✅ Voir les financements reçus
- ❌ Investir dans les projets
- ❌ Valider les projets

### ADMIN
- ✅ Tous les droits
- ✅ Valider/rejeter les projets
- ✅ Gérer les utilisateurs
- ✅ Voir les statistiques
- ✅ Gérer les transactions

---

## 📝 Exemples de requêtes cURL

### Inscription
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "role": "INVESTOR"
  }'
```

### Connexion
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

### Créer un projet
```bash
curl -X POST http://localhost:8080/api/projects \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "title": "Panneaux solaires - Marrakech",
    "city": "Marrakech",
    "energyType": "SOLAIRE",
    "description": "Installation de 50 panneaux...",
    "targetAmount": 120000.00
  }'
```

### Investir dans un projet
```bash
curl -X POST http://localhost:8080/api/investments/projects/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "amount": 5000.00
  }'
```

---

## 🐛 Gestion des erreurs

### Erreur de validation
```json
{
  "title": "Le titre est requis",
  "targetAmount": "Le montant doit être supérieur à 0"
}
```

### Erreur d'authentification
```json
{
  "message": "Invalid email or password"
}
```

### Erreur d'autorisation
```json
{
  "message": "Access denied. Required role: ADMIN"
}
```

---

*Documentation API créée pour GreenFund Backend - Mise à jour régulière recommandée*

