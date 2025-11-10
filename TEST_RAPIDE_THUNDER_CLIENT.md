# ⚡ Test Rapide - Thunder Client

## 🚀 Démarrage en 3 étapes

### 1. Installer Thunder Client
- Ouvrez VSCode
- Extensions (`Ctrl + Shift + X`)
- Recherchez "Thunder Client" et installez

### 2. Démarrer le backend
```powershell
cd greenfund-backend
.\mvnw.cmd spring-boot:run
```

### 3. Ouvrir Thunder Client
- Cliquez sur l'icône Thunder Client dans la barre latérale
- Ou `Ctrl + Shift + T`

## 🧪 Tests essentiels

### Test 1 : Inscription
```
POST http://localhost:8080/api/auth/register
Content-Type: application/json

{
  "name": "Test User",
  "email": "test@example.com",
  "password": "password123",
  "role": "INVESTOR"
}
```
**→ Copiez le `token` de la réponse !**

### Test 2 : Connexion Admin
```
POST http://localhost:8080/api/auth/login
Content-Type: application/json

{
  "email": "admin@greenfund.com",
  "password": "admin123"
}
```
**→ Copiez le `token` admin !**

### Test 3 : Lister les projets (Public)
```
GET http://localhost:8080/api/projects
```
**→ Pas besoin de token**

### Test 4 : Créer un projet (avec token OWNER)
```
POST http://localhost:8080/api/projects
Authorization: Bearer VOTRE_TOKEN_OWNER
Content-Type: application/json

{
  "title": "Mon projet solaire",
  "city": "Casablanca",
  "energyType": "SOLAIRE",
  "description": "Installation de panneaux solaires",
  "targetAmount": 50000.00
}
```

### Test 5 : Investir (avec token INVESTOR)
```
POST http://localhost:8080/api/investments/1
Authorization: Bearer VOTRE_TOKEN_INVESTOR
Content-Type: application/json

{
  "amount": 1000.00
}
```

## 📝 Variables d'environnement (Recommandé)

1. Dans Thunder Client, cliquez sur **Env**
2. Créez "Local" avec :
   - `baseUrl` = `http://localhost:8080/api`
   - `token` = (vide, à remplir après login)
   - `adminToken` = (vide, à remplir après login admin)

3. Utilisez dans les requêtes :
   - URL : `{{baseUrl}}/auth/login`
   - Header : `Bearer {{token}}`

## 🔍 Vérification rapide

✅ Backend démarré ? → Vérifiez `http://localhost:8080/api/projects`  
✅ Token valide ? → Vérifiez le header `Authorization: Bearer TOKEN`  
✅ Bon rôle ? → Vérifiez que vous utilisez le bon token (INVESTOR/OWNER/ADMIN)

---

**Guide complet** : Voir `GUIDE_TEST_THUNDER_CLIENT.md` pour tous les endpoints détaillés.

