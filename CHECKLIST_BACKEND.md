# ✅ Checklist de développement Backend Spring Boot

## 📋 Vue d'ensemble rapide

Ce document est un checklist pour suivre votre progression dans le développement du backend Spring Boot pour GreenFund.

---

## 🎯 Phase 1 : Configuration initiale

### Environnement
- [ ] Installer Java 17 ou 21
- [ ] Installer Maven ou Gradle
- [ ] Installer MySQL (ou PostgreSQL)
- [ ] Installer IntelliJ IDEA ou Eclipse
- [ ] Installer Postman pour tester les APIs

### Projet
- [ ] Créer le projet Spring Boot via Spring Initializr
- [ ] Configurer les dépendances (Web, JPA, Security, JWT, etc.)
- [ ] Créer la structure de dossiers
- [ ] Configurer `application.properties`
- [ ] Créer la base de données MySQL `greenfund_db`

---

## 🎯 Phase 2 : Modèles de données

### Enums
- [ ] Créer `Role` (INVESTOR, OWNER, ADMIN)
- [ ] Créer `EnergyType` (SOLAIRE, EOLIENNE, BIOGAZ)
- [ ] Créer `ProjectStatus` (PENDING, APPROVED, REJECTED, etc.)

### Entities
- [ ] Créer `User` entity
- [ ] Créer `Project` entity
- [ ] Créer `Investment` entity
- [ ] Créer `Transaction` entity (optionnel pour MVP)

### Relations
- [ ] Configurer relation User → Projects (OneToMany)
- [ ] Configurer relation User → Investments (OneToMany)
- [ ] Configurer relation Project → Investments (OneToMany)
- [ ] Tester les relations JPA

---

## 🎯 Phase 3 : DTOs et Validation

### Request DTOs
- [ ] `LoginRequest`
- [ ] `RegisterRequest`
- [ ] `CreateProjectRequest`
- [ ] `InvestRequest`
- [ ] `UpdateProjectRequest`

### Response DTOs
- [ ] `AuthResponse`
- [ ] `ProjectResponse`
- [ ] `InvestmentResponse`
- [ ] `UserResponse`

### Validation
- [ ] Ajouter `@Valid` dans les contrôleurs
- [ ] Ajouter les annotations de validation (@NotBlank, @Email, etc.)
- [ ] Tester la validation

---

## 🎯 Phase 4 : Repositories

- [ ] `UserRepository` (findByEmail, existsByEmail, etc.)
- [ ] `ProjectRepository` (findByStatus, findByOwnerId, etc.)
- [ ] `InvestmentRepository` (findByInvestorId, findByProjectId)
- [ ] `TransactionRepository` (optionnel)
- [ ] Tester les requêtes personnalisées

---

## 🎯 Phase 5 : Sécurité JWT

### JWT
- [ ] Créer `JwtTokenProvider`
- [ ] Configurer la clé secrète JWT
- [ ] Implémenter `generateToken()`
- [ ] Implémenter `validateToken()`
- [ ] Implémenter `getUserIdFromToken()`

### Security
- [ ] Créer `UserPrincipal` (implémente UserDetails)
- [ ] Créer `UserDetailsServiceImpl`
- [ ] Créer `JwtAuthenticationFilter`
- [ ] Configurer `SecurityConfig`
- [ ] Configurer CORS
- [ ] Tester l'authentification

---

## 🎯 Phase 6 : Services

### AuthService
- [ ] Implémenter `register()`
- [ ] Implémenter `login()`
- [ ] Gérer les erreurs (email existe déjà, etc.)

### ProjectService
- [ ] Implémenter `createProject()`
- [ ] Implémenter `getAllProjects()`
- [ ] Implémenter `getProjectById()`
- [ ] Implémenter `updateProjectStatus()`
- [ ] Implémenter `getProjectsByStatus()`

### InvestmentService
- [ ] Implémenter `investInProject()`
- [ ] Implémenter `getInvestmentsByInvestor()`
- [ ] Gérer la mise à jour du montant collecté
- [ ] Gérer le changement de statut (COMPLETED)

### AdminService (optionnel)
- [ ] Implémenter `getAllUsers()`
- [ ] Implémenter `updateUserStatus()`
- [ ] Implémenter `getStatistics()`

---

## 🎯 Phase 7 : Contrôleurs REST

### AuthController
- [ ] `POST /api/auth/register`
- [ ] `POST /api/auth/login`
- [ ] Tester avec Postman

### ProjectController
- [ ] `POST /api/projects` (créer projet)
- [ ] `GET /api/projects` (liste des projets)
- [ ] `GET /api/projects/{id}` (détails projet)
- [ ] `PUT /api/projects/{id}` (modifier projet)
- [ ] Tester avec Postman

### InvestmentController
- [ ] `POST /api/investments/projects/{projectId}` (investir)
- [ ] `GET /api/investments/my-investments` (mes investissements)
- [ ] Tester avec Postman

### AdminController
- [ ] `GET /api/admin/projects/pending` (projets en attente)
- [ ] `PUT /api/admin/projects/{id}/validate` (valider/rejeter)
- [ ] `GET /api/admin/users` (liste utilisateurs)
- [ ] `GET /api/admin/stats` (statistiques)
- [ ] Tester avec Postman

---

## 🎯 Phase 8 : Gestion des erreurs

- [ ] Créer `GlobalExceptionHandler`
- [ ] Gérer `RuntimeException`
- [ ] Gérer `MethodArgumentNotValidException`
- [ ] Gérer les erreurs de validation
- [ ] Tester les messages d'erreur

---

## 🎯 Phase 9 : Tests

### Tests unitaires
- [ ] Tests des services
- [ ] Tests des repositories
- [ ] Tests de sécurité

### Tests d'intégration
- [ ] Tests des contrôleurs
- [ ] Tests end-to-end

---

## 🎯 Phase 10 : Documentation et déploiement

### Documentation
- [ ] Documenter les endpoints (Swagger/OpenAPI)
- [ ] Créer un README
- [ ] Documenter les modèles de données

### Déploiement
- [ ] Configurer les profils (dev, prod)
- [ ] Configurer Docker (optionnel)
- [ ] Préparer le déploiement

---

## 🎯 Phase 11 : Intégration Flutter

- [ ] Tester les endpoints depuis Flutter
- [ ] Implémenter `ApiService` dans Flutter
- [ ] Intégrer l'authentification
- [ ] Intégrer les projets
- [ ] Intégrer les investissements
- [ ] Tester l'application complète

---

## 📊 Progression

**Phase 1 :** ⬜ Configuration initiale  
**Phase 2 :** ⬜ Modèles de données  
**Phase 3 :** ⬜ DTOs et Validation  
**Phase 4 :** ⬜ Repositories  
**Phase 5 :** ⬜ Sécurité JWT  
**Phase 6 :** ⬜ Services  
**Phase 7 :** ⬜ Contrôleurs REST  
**Phase 8 :** ⬜ Gestion des erreurs  
**Phase 9 :** ⬜ Tests  
**Phase 10 :** ⬜ Documentation  
**Phase 11 :** ⬜ Intégration Flutter  

---

## 🚀 Commandes utiles

### Lancer l'application
```bash
./mvnw spring-boot:run
# ou
./gradlew bootRun
```

### Tests
```bash
./mvnw test
# ou
./gradlew test
```

### Build
```bash
./mvnw clean package
# ou
./gradlew build
```

---

## 📝 Notes importantes

1. **Sécurité** : Ne jamais commiter les secrets JWT en production
2. **Base de données** : Utiliser des migrations (Flyway/Liquibase) en production
3. **Validation** : Toujours valider les données côté serveur
4. **Tests** : Écrire des tests avant de déployer
5. **Documentation** : Documenter les APIs avec Swagger

---

*Checklist créée pour GreenFund Backend - Suivez votre progression ici !*

