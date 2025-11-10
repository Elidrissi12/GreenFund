# Guide de développement Backend Spring Boot pour GreenFund

## 📋 Vue d'ensemble

Ce guide vous accompagne dans le développement d'un backend Spring Boot complet pour l'application Flutter GreenFund. Le backend doit gérer :
- ✅ Authentification et autorisation (JWT)
- ✅ Gestion des utilisateurs (3 rôles : INVESTOR, OWNER, ADMIN)
- ✅ CRUD des projets d'énergie renouvelable
- ✅ Système d'investissement/financement
- ✅ Gestion administrative (validation, statistiques)
- ✅ Transactions et historique

---

## 🎯 Architecture du backend

```
greenfund-backend/
├── src/main/java/com/greenfund/
│   ├── GreenFundApplication.java
│   ├── config/
│   │   ├── SecurityConfig.java
│   │   ├── JwtConfig.java
│   │   └── CorsConfig.java
│   ├── controller/
│   │   ├── AuthController.java
│   │   ├── ProjectController.java
│   │   ├── InvestmentController.java
│   │   ├── UserController.java
│   │   └── AdminController.java
│   ├── service/
│   │   ├── AuthService.java
│   │   ├── UserService.java
│   │   ├── ProjectService.java
│   │   ├── InvestmentService.java
│   │   └── AdminService.java
│   ├── repository/
│   │   ├── UserRepository.java
│   │   ├── ProjectRepository.java
│   │   ├── InvestmentRepository.java
│   │   └── TransactionRepository.java
│   ├── model/
│   │   ├── entity/
│   │   │   ├── User.java
│   │   │   ├── Project.java
│   │   │   ├── Investment.java
│   │   │   └── Transaction.java
│   │   ├── dto/
│   │   │   ├── request/
│   │   │   └── response/
│   │   └── enum/
│   │       ├── Role.java
│   │       ├── EnergyType.java
│   │       └── ProjectStatus.java
│   ├── security/
│   │   ├── JwtTokenProvider.java
│   │   ├── JwtAuthenticationFilter.java
│   │   └── UserPrincipal.java
│   └── exception/
│       ├── GlobalExceptionHandler.java
│       └── CustomException.java
├── src/main/resources/
│   ├── application.properties
│   └── application-dev.properties
└── pom.xml (ou build.gradle)
```

---

## 📦 Étape 1 : Initialisation du projet

### 1.1 Créer le projet Spring Boot

**Option A : Spring Initializr (https://start.spring.io/)**
- **Project** : Maven ou Gradle
- **Language** : Java
- **Spring Boot** : 3.2.0 ou supérieur
- **Packaging** : Jar
- **Java** : 17 ou 21

**Dépendances à sélectionner** :
- ✅ Spring Web
- ✅ Spring Data JPA
- ✅ Spring Security
- ✅ MySQL Driver (ou PostgreSQL)
- ✅ Lombok
- ✅ Validation
- ✅ JWT (jjwt)

**Option B : Via IntelliJ IDEA**
1. File → New → Project
2. Spring Initializr
3. Sélectionner les dépendances ci-dessus

### 1.2 Structure des dossiers

Créer la structure de dossiers dans `src/main/java/com/greenfund/` :
```
config/
controller/
service/
repository/
model/entity/
model/dto/request/
model/dto/response/
model/enum/
security/
exception/
```

---

## 📦 Étape 2 : Configuration (pom.xml / build.gradle)

### 2.1 Si Maven (pom.xml)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
        <relativePath/>
    </parent>
    <groupId>com.greenfund</groupId>
    <artifactId>greenfund-backend</artifactId>
    <version>1.0.0</version>
    <name>GreenFund Backend</name>
    <description>Backend API for GreenFund crowdfunding platform</description>
    <properties>
        <java.version>17</java.version>
    </properties>
    <dependencies>
        <!-- Spring Boot Starters -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        
        <!-- Database -->
        <dependency>
            <groupId>com.mysql</groupId>
            <artifactId>mysql-connector-j</artifactId>
            <scope>runtime</scope>
        </dependency>
        <!-- Ou PostgreSQL -->
        <!--
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>
        -->
        
        <!-- JWT -->
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-api</artifactId>
            <version>0.12.3</version>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-impl</artifactId>
            <version>0.12.3</version>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-jackson</artifactId>
            <version>0.12.3</version>
            <scope>runtime</scope>
        </dependency>
        
        <!-- Lombok -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        
        <!-- Test -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.security</groupId>
            <artifactId>spring-security-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
    
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <excludes>
                        <exclude>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                        </exclude>
                    </excludes>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

### 2.2 Si Gradle (build.gradle)

```gradle
plugins {
    id 'java'
    id 'org.springframework.boot' version '3.2.0'
    id 'io.spring.dependency-management' version '1.1.4'
}

group = 'com.greenfund'
version = '1.0.0'

java {
    sourceCompatibility = '17'
}

configurations {
    compileOnly {
        extendsFrom annotationProcessor
    }
}

repositories {
    mavenCentral()
}

dependencies {
    // Spring Boot Starters
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-security'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
    
    // Database
    runtimeOnly 'com.mysql:mysql-connector-j'
    // runtimeOnly 'org.postgresql:postgresql'
    
    // JWT
    implementation 'io.jsonwebtoken:jjwt-api:0.12.3'
    runtimeOnly 'io.jsonwebtoken:jjwt-impl:0.12.3'
    runtimeOnly 'io.jsonwebtoken:jjwt-jackson:0.12.3'
    
    // Lombok
    compileOnly 'org.projectlombok:lombok'
    annotationProcessor 'org.projectlombok:lombok'
    
    // Test
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testImplementation 'org.springframework.security:spring-security-test'
}

tasks.named('test') {
    useJUnitPlatform()
}
```

---

## 📦 Étape 3 : Configuration de la base de données

### 3.1 Fichier application.properties

```properties
# Application
spring.application.name=greenfund-backend
server.port=8080

# Database Configuration (MySQL)
spring.datasource.url=jdbc:mysql://localhost:3306/greenfund_db?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC
spring.datasource.username=root
spring.datasource.password=your_password
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# JPA/Hibernate
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQL8Dialect
spring.jpa.properties.hibernate.format_sql=true

# JWT Configuration
jwt.secret=yourSecretKeyForJWTTokenGenerationMustBeAtLeast256BitsLong
jwt.expiration=86400000

# CORS
app.cors.allowed-origins=http://localhost:3000,http://localhost:5000

# Logging
logging.level.com.greenfund=DEBUG
logging.level.org.springframework.security=DEBUG
```

### 3.2 Créer la base de données MySQL

```sql
CREATE DATABASE IF NOT EXISTS greenfund_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

---

## 📦 Étape 4 : Modèles de données (Entities)

### 4.1 Enum : Role

```java
package com.greenfund.model.enum;

public enum Role {
    INVESTOR,
    OWNER,
    ADMIN
}
```

### 4.2 Enum : EnergyType

```java
package com.greenfund.model.enum;

public enum EnergyType {
    SOLAIRE,
    EOLIENNE,
    BIOGAZ
}
```

### 4.3 Enum : ProjectStatus

```java
package com.greenfund.model.enum;

public enum ProjectStatus {
    PENDING,    // En attente de validation
    APPROVED,   // Approuvé
    REJECTED,   // Rejeté
    ACTIVE,     // Actif (collecte en cours)
    COMPLETED,  // Complété (objectif atteint)
    CANCELLED   // Annulé
}
```

### 4.4 Entity : User

```java
package com.greenfund.model.entity;

import com.greenfund.model.enum.Role;
import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Size(max = 100)
    @Column(nullable = false)
    private String name;

    @NotBlank
    @Email
    @Size(max = 100)
    @Column(nullable = false, unique = true)
    private String email;

    @NotBlank
    @Size(min = 6)
    @Column(nullable = false)
    private String password;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role;

    @Column(nullable = false)
    private Boolean active = true;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;

    // Relations
    @OneToMany(mappedBy = "owner", cascade = CascadeType.ALL)
    private List<Project> projects;

    @OneToMany(mappedBy = "investor", cascade = CascadeType.ALL)
    private List<Investment> investments;
}
```

### 4.5 Entity : Project

```java
package com.greenfund.model.entity;

import com.greenfund.model.enum.EnergyType;
import com.greenfund.model.enum.ProjectStatus;
import jakarta.persistence.*;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "projects")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Project {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Size(max = 200)
    @Column(nullable = false)
    private String title;

    @NotBlank
    @Size(max = 100)
    @Column(nullable = false)
    private String city;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private EnergyType energyType;

    @NotBlank
    @Size(max = 1000)
    @Column(nullable = false, columnDefinition = "TEXT")
    private String description;

    @NotNull
    @DecimalMin(value = "0.0", inclusive = false)
    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal targetAmount;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal raisedAmount = BigDecimal.ZERO;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ProjectStatus status = ProjectStatus.PENDING;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    private User owner;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;

    // Relations
    @OneToMany(mappedBy = "project", cascade = CascadeType.ALL)
    private List<Investment> investments;

    // Méthode calculée
    public double getProgress() {
        if (targetAmount.compareTo(BigDecimal.ZERO) == 0) {
            return 0.0;
        }
        double progress = raisedAmount.divide(targetAmount, 4, BigDecimal.ROUND_HALF_UP)
                .multiply(BigDecimal.valueOf(100)).doubleValue();
        return Math.min(100.0, Math.max(0.0, progress));
    }

    public boolean isFunded() {
        return raisedAmount.compareTo(targetAmount) >= 0;
    }
}
```

### 4.6 Entity : Investment

```java
package com.greenfund.model.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "investments")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Investment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    @DecimalMin(value = "0.0", inclusive = false)
    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal amount;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "project_id", nullable = false)
    private Project project;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "investor_id", nullable = false)
    private User investor;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    public void updateProjectRaisedAmount() {
        if (project != null) {
            project.setRaisedAmount(project.getRaisedAmount().add(amount));
        }
    }
}
```

### 4.7 Entity : Transaction

```java
package com.greenfund.model.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "transactions")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Transaction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String transactionId;

    @NotNull
    @DecimalMin(value = "0.0", inclusive = false)
    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal amount;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "investment_id")
    private Investment investment;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TransactionType type;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TransactionStatus status = TransactionStatus.PENDING;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;

    public enum TransactionType {
        INVESTMENT,
        REFUND,
        WITHDRAWAL
    }

    public enum TransactionStatus {
        PENDING,
        COMPLETED,
        FAILED,
        CANCELLED
    }
}
```

---

## 📦 Étape 5 : DTOs (Data Transfer Objects)

### 5.1 Request DTOs

#### LoginRequest.java
```java
package com.greenfund.model.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class LoginRequest {
    @NotBlank
    @Email
    private String email;

    @NotBlank
    private String password;
}
```

#### RegisterRequest.java
```java
package com.greenfund.model.dto.request;

import com.greenfund.model.enum.Role;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class RegisterRequest {
    @NotBlank
    @Size(max = 100)
    private String name;

    @NotBlank
    @Email
    @Size(max = 100)
    private String email;

    @NotBlank
    @Size(min = 6)
    private String password;

    private Role role;
}
```

#### CreateProjectRequest.java
```java
package com.greenfund.model.dto.request;

import com.greenfund.model.enum.EnergyType;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class CreateProjectRequest {
    @NotBlank
    @Size(max = 200)
    private String title;

    @NotBlank
    @Size(max = 100)
    private String city;

    @NotNull
    private EnergyType energyType;

    @NotBlank
    @Size(max = 1000)
    private String description;

    @NotNull
    @DecimalMin(value = "0.0", inclusive = false)
    private BigDecimal targetAmount;
}
```

#### InvestRequest.java
```java
package com.greenfund.model.dto.request;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class InvestRequest {
    @NotNull
    @DecimalMin(value = "0.0", inclusive = false)
    private BigDecimal amount;
}
```

### 5.2 Response DTOs

#### AuthResponse.java
```java
package com.greenfund.model.dto.response;

import com.greenfund.model.enum.Role;
import lombok.Data;

@Data
public class AuthResponse {
    private String token;
    private String type = "Bearer";
    private Long id;
    private String name;
    private String email;
    private Role role;

    public AuthResponse(String token, Long id, String name, String email, Role role) {
        this.token = token;
        this.id = id;
        this.name = name;
        this.email = email;
        this.role = role;
    }
}
```

#### ProjectResponse.java
```java
package com.greenfund.model.dto.response;

import com.greenfund.model.enum.EnergyType;
import com.greenfund.model.enum.ProjectStatus;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class ProjectResponse {
    private Long id;
    private String title;
    private String city;
    private EnergyType energyType;
    private String description;
    private BigDecimal targetAmount;
    private BigDecimal raisedAmount;
    private double progress;
    private ProjectStatus status;
    private Long ownerId;
    private String ownerName;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
```

#### InvestmentResponse.java
```java
package com.greenfund.model.dto.response;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class InvestmentResponse {
    private Long id;
    private BigDecimal amount;
    private Long projectId;
    private String projectTitle;
    private Long investorId;
    private String investorName;
    private LocalDateTime createdAt;
}
```

---

## 📦 Étape 6 : Repositories

### 6.1 UserRepository.java

```java
package com.greenfund.repository;

import com.greenfund.model.entity.User;
import com.greenfund.model.enum.Role;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    Boolean existsByEmail(String email);
    List<User> findByRole(Role role);
    List<User> findByActive(Boolean active);
}
```

### 6.2 ProjectRepository.java

```java
package com.greenfund.repository;

import com.greenfund.model.entity.Project;
import com.greenfund.model.enum.EnergyType;
import com.greenfund.model.enum.ProjectStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProjectRepository extends JpaRepository<Project, Long> {
    List<Project> findByStatus(ProjectStatus status);
    List<Project> findByOwnerId(Long ownerId);
    List<Project> findByEnergyType(EnergyType energyType);
    List<Project> findByCity(String city);
    
    @Query("SELECT SUM(p.raisedAmount) FROM Project p WHERE p.status = :status")
    Double getTotalRaisedAmountByStatus(ProjectStatus status);
    
    @Query("SELECT COUNT(p) FROM Project p WHERE p.status = :status")
    Long countByStatus(ProjectStatus status);
}
```

### 6.3 InvestmentRepository.java

```java
package com.greenfund.repository;

import com.greenfund.model.entity.Investment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface InvestmentRepository extends JpaRepository<Investment, Long> {
    List<Investment> findByInvestorId(Long investorId);
    List<Investment> findByProjectId(Long projectId);
    
    @Query("SELECT SUM(i.amount) FROM Investment i WHERE i.project.id = :projectId")
    Double getTotalInvestmentsByProjectId(Long projectId);
}
```

### 6.4 TransactionRepository.java

```java
package com.greenfund.repository;

import com.greenfund.model.entity.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    List<Transaction> findByUserId(Long userId);
    List<Transaction> findByInvestmentId(Long investmentId);
    Transaction findByTransactionId(String transactionId);
}
```

---

## 📦 Étape 7 : Sécurité JWT

### 7.1 JwtTokenProvider.java

```java
package com.greenfund.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;

@Component
public class JwtTokenProvider {
    @Value("${jwt.secret}")
    private String jwtSecret;

    @Value("${jwt.expiration}")
    private int jwtExpirationInMs;

    public String generateToken(Authentication authentication) {
        UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + jwtExpirationInMs);

        return Jwts.builder()
                .subject(Long.toString(userPrincipal.getId()))
                .claim("email", userPrincipal.getEmail())
                .claim("role", userPrincipal.getRole().name())
                .issuedAt(now)
                .expiration(expiryDate)
                .signWith(getSigningKey())
                .compact();
    }

    public Long getUserIdFromToken(String token) {
        Claims claims = Jwts.parser()
                .verifyWith(getSigningKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();

        return Long.parseLong(claims.getSubject());
    }

    public boolean validateToken(String authToken) {
        try {
            Jwts.parser().verifyWith(getSigningKey()).build().parseSignedClaims(authToken);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }

    private SecretKey getSigningKey() {
        return Keys.hmacShaKeyFor(jwtSecret.getBytes());
    }
}
```

### 7.2 UserPrincipal.java

```java
package com.greenfund.security;

import com.greenfund.model.entity.User;
import com.greenfund.model.enum.Role;
import lombok.AllArgsConstructor;
import lombok.Data;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;

@Data
@AllArgsConstructor
public class UserPrincipal implements UserDetails {
    private Long id;
    private String name;
    private String email;
    private String password;
    private Role role;
    private Boolean active;
    private Collection<? extends GrantedAuthority> authorities;

    public static UserPrincipal create(User user) {
        Collection<GrantedAuthority> authorities = Collections.singletonList(
                new SimpleGrantedAuthority("ROLE_" + user.getRole().name())
        );

        return new UserPrincipal(
                user.getId(),
                user.getName(),
                user.getEmail(),
                user.getPassword(),
                user.getRole(),
                user.getActive(),
                authorities
        );
    }

    @Override
    public String getUsername() {
        return email;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return active;
    }
}
```

### 7.3 JwtAuthenticationFilter.java

```java
package com.greenfund.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    @Autowired
    private JwtTokenProvider tokenProvider;

    @Autowired
    private UserDetailsService userDetailsService;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        try {
            String jwt = getJwtFromRequest(request);

            if (StringUtils.hasText(jwt) && tokenProvider.validateToken(jwt)) {
                Long userId = tokenProvider.getUserIdFromToken(jwt);
                UserDetails userDetails = userDetailsService.loadUserByUsername(userId.toString());
                UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                        userDetails, null, userDetails.getAuthorities());
                authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        } catch (Exception ex) {
            logger.error("Could not set user authentication in security context", ex);
        }

        filterChain.doFilter(request, response);
    }

    private String getJwtFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}
```

---

## 📦 Étape 8 : Configuration de sécurité

### 8.1 SecurityConfig.java

```java
package com.greenfund.config;

import com.greenfund.security.JwtAuthenticationFilter;
import com.greenfund.security.UserDetailsServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.List;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {
    @Autowired
    private UserDetailsServiceImpl userDetailsService;

    @Autowired
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authConfig) throws Exception {
        return authConfig.getAuthenticationManager();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http.cors(cors -> cors.configurationSource(corsConfigurationSource()))
                .csrf(csrf -> csrf.disable())
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/api/auth/**").permitAll()
                        .requestMatchers("/api/admin/**").hasRole("ADMIN")
                        .requestMatchers("/api/projects/**").authenticated()
                        .requestMatchers("/api/investments/**").authenticated()
                        .anyRequest().authenticated()
                );

        http.authenticationProvider(authenticationProvider());
        http.addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(Arrays.asList("http://localhost:3000", "http://localhost:5000"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(List.of("*"));
        configuration.setAllowCredentials(true);
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
```

### 8.2 UserDetailsServiceImpl.java

```java
package com.greenfund.security;

import com.greenfund.model.entity.User;
import com.greenfund.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserDetailsServiceImpl implements UserDetailsService {
    @Autowired
    private UserRepository userRepository;

    @Override
    @Transactional
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with email: " + email));
        return UserPrincipal.create(user);
    }

    @Transactional
    public UserDetails loadUserById(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with id: " + id));
        return UserPrincipal.create(user);
    }
}
```

---

## 📦 Étape 9 : Services

### 9.1 AuthService.java

```java
package com.greenfund.service;

import com.greenfund.model.dto.request.LoginRequest;
import com.greenfund.model.dto.request.RegisterRequest;
import com.greenfund.model.dto.response.AuthResponse;
import com.greenfund.model.entity.User;
import com.greenfund.model.enum.Role;
import com.greenfund.repository.UserRepository;
import com.greenfund.security.JwtTokenProvider;
import com.greenfund.security.UserPrincipal;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {
    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtTokenProvider tokenProvider;

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already exists");
        }

        User user = new User();
        user.setName(request.getName());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole(request.getRole() != null ? request.getRole() : Role.INVESTOR);
        user.setActive(true);

        user = userRepository.save(user);

        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        String token = tokenProvider.generateToken(authentication);
        UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();

        return new AuthResponse(token, userPrincipal.getId(), userPrincipal.getName(),
                userPrincipal.getEmail(), userPrincipal.getRole());
    }

    public AuthResponse login(LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        SecurityContextHolder.getContext().setAuthentication(authentication);
        String token = tokenProvider.generateToken(authentication);
        UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();

        return new AuthResponse(token, userPrincipal.getId(), userPrincipal.getName(),
                userPrincipal.getEmail(), userPrincipal.getRole());
    }
}
```

### 9.2 ProjectService.java

```java
package com.greenfund.service;

import com.greenfund.model.dto.request.CreateProjectRequest;
import com.greenfund.model.dto.response.ProjectResponse;
import com.greenfund.model.entity.Project;
import com.greenfund.model.entity.User;
import com.greenfund.model.enum.ProjectStatus;
import com.greenfund.repository.ProjectRepository;
import com.greenfund.repository.UserRepository;
import com.greenfund.security.UserPrincipal;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ProjectService {
    @Autowired
    private ProjectRepository projectRepository;

    @Autowired
    private UserRepository userRepository;

    @Transactional
    public ProjectResponse createProject(CreateProjectRequest request) {
        UserPrincipal userPrincipal = (UserPrincipal) SecurityContextHolder.getContext()
                .getAuthentication().getPrincipal();
        User owner = userRepository.findById(userPrincipal.getId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        Project project = new Project();
        project.setTitle(request.getTitle());
        project.setCity(request.getCity());
        project.setEnergyType(request.getEnergyType());
        project.setDescription(request.getDescription());
        project.setTargetAmount(request.getTargetAmount());
        project.setRaisedAmount(java.math.BigDecimal.ZERO);
        project.setStatus(ProjectStatus.PENDING);
        project.setOwner(owner);

        project = projectRepository.save(project);
        return convertToResponse(project);
    }

    public List<ProjectResponse> getAllProjects() {
        return projectRepository.findAll().stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public List<ProjectResponse> getProjectsByStatus(ProjectStatus status) {
        return projectRepository.findByStatus(status).stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public ProjectResponse getProjectById(Long id) {
        Project project = projectRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Project not found"));
        return convertToResponse(project);
    }

    @Transactional
    public ProjectResponse updateProjectStatus(Long id, ProjectStatus status) {
        Project project = projectRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Project not found"));
        project.setStatus(status);
        project = projectRepository.save(project);
        return convertToResponse(project);
    }

    private ProjectResponse convertToResponse(Project project) {
        ProjectResponse response = new ProjectResponse();
        response.setId(project.getId());
        response.setTitle(project.getTitle());
        response.setCity(project.getCity());
        response.setEnergyType(project.getEnergyType());
        response.setDescription(project.getDescription());
        response.setTargetAmount(project.getTargetAmount());
        response.setRaisedAmount(project.getRaisedAmount());
        response.setProgress(project.getProgress());
        response.setStatus(project.getStatus());
        response.setOwnerId(project.getOwner().getId());
        response.setOwnerName(project.getOwner().getName());
        response.setCreatedAt(project.getCreatedAt());
        response.setUpdatedAt(project.getUpdatedAt());
        return response;
    }
}
```

### 9.3 InvestmentService.java

```java
package com.greenfund.service;

import com.greenfund.model.dto.request.InvestRequest;
import com.greenfund.model.dto.response.InvestmentResponse;
import com.greenfund.model.entity.Investment;
import com.greenfund.model.entity.Project;
import com.greenfund.model.entity.User;
import com.greenfund.model.enum.ProjectStatus;
import com.greenfund.repository.InvestmentRepository;
import com.greenfund.repository.ProjectRepository;
import com.greenfund.repository.UserRepository;
import com.greenfund.security.UserPrincipal;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class InvestmentService {
    @Autowired
    private InvestmentRepository investmentRepository;

    @Autowired
    private ProjectRepository projectRepository;

    @Autowired
    private UserRepository userRepository;

    @Transactional
    public InvestmentResponse investInProject(Long projectId, InvestRequest request) {
        UserPrincipal userPrincipal = (UserPrincipal) SecurityContextHolder.getContext()
                .getAuthentication().getPrincipal();
        User investor = userRepository.findById(userPrincipal.getId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new RuntimeException("Project not found"));

        if (project.getStatus() != ProjectStatus.APPROVED && project.getStatus() != ProjectStatus.ACTIVE) {
            throw new RuntimeException("Project is not available for investment");
        }

        Investment investment = new Investment();
        investment.setAmount(request.getAmount());
        investment.setProject(project);
        investment.setInvestor(investor);

        investment = investmentRepository.save(investment);

        // Mettre à jour le statut du projet si l'objectif est atteint
        if (project.isFunded() && project.getStatus() == ProjectStatus.ACTIVE) {
            project.setStatus(ProjectStatus.COMPLETED);
            projectRepository.save(project);
        }

        return convertToResponse(investment);
    }

    public List<InvestmentResponse> getInvestmentsByInvestor() {
        UserPrincipal userPrincipal = (UserPrincipal) SecurityContextHolder.getContext()
                .getAuthentication().getPrincipal();
        return investmentRepository.findByInvestorId(userPrincipal.getId()).stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    private InvestmentResponse convertToResponse(Investment investment) {
        InvestmentResponse response = new InvestmentResponse();
        response.setId(investment.getId());
        response.setAmount(investment.getAmount());
        response.setProjectId(investment.getProject().getId());
        response.setProjectTitle(investment.getProject().getTitle());
        response.setInvestorId(investment.getInvestor().getId());
        response.setInvestorName(investment.getInvestor().getName());
        response.setCreatedAt(investment.getCreatedAt());
        return response;
    }
}
```

---

## 📦 Étape 10 : Contrôleurs REST

### 10.1 AuthController.java

```java
package com.greenfund.controller;

import com.greenfund.model.dto.request.LoginRequest;
import com.greenfund.model.dto.request.RegisterRequest;
import com.greenfund.model.dto.response.AuthResponse;
import com.greenfund.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {
    @Autowired
    private AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        AuthResponse response = authService.register(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(response);
    }
}
```

### 10.2 ProjectController.java

```java
package com.greenfund.controller;

import com.greenfund.model.dto.request.CreateProjectRequest;
import com.greenfund.model.dto.response.ProjectResponse;
import com.greenfund.model.enum.ProjectStatus;
import com.greenfund.service.ProjectService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/projects")
@CrossOrigin(origins = "*")
public class ProjectController {
    @Autowired
    private ProjectService projectService;

    @PostMapping
    public ResponseEntity<ProjectResponse> createProject(@Valid @RequestBody CreateProjectRequest request) {
        ProjectResponse response = projectService.createProject(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    public ResponseEntity<List<ProjectResponse>> getAllProjects(
            @RequestParam(required = false) ProjectStatus status) {
        List<ProjectResponse> projects = status != null
                ? projectService.getProjectsByStatus(status)
                : projectService.getAllProjects();
        return ResponseEntity.ok(projects);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProjectResponse> getProjectById(@PathVariable Long id) {
        ProjectResponse response = projectService.getProjectById(id);
        return ResponseEntity.ok(response);
    }
}
```

### 10.3 InvestmentController.java

```java
package com.greenfund.controller;

import com.greenfund.model.dto.request.InvestRequest;
import com.greenfund.model.dto.response.InvestmentResponse;
import com.greenfund.service.InvestmentService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/investments")
@CrossOrigin(origins = "*")
public class InvestmentController {
    @Autowired
    private InvestmentService investmentService;

    @PostMapping("/projects/{projectId}")
    public ResponseEntity<InvestmentResponse> investInProject(
            @PathVariable Long projectId,
            @Valid @RequestBody InvestRequest request) {
        InvestmentResponse response = investmentService.investInProject(projectId, request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/my-investments")
    public ResponseEntity<List<InvestmentResponse>> getMyInvestments() {
        List<InvestmentResponse> investments = investmentService.getInvestmentsByInvestor();
        return ResponseEntity.ok(investments);
    }
}
```

### 10.4 AdminController.java

```java
package com.greenfund.controller;

import com.greenfund.model.dto.response.ProjectResponse;
import com.greenfund.model.enum.ProjectStatus;
import com.greenfund.service.ProjectService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {
    @Autowired
    private ProjectService projectService;

    @GetMapping("/projects/pending")
    public ResponseEntity<List<ProjectResponse>> getPendingProjects() {
        List<ProjectResponse> projects = projectService.getProjectsByStatus(ProjectStatus.PENDING);
        return ResponseEntity.ok(projects);
    }

    @PutMapping("/projects/{id}/validate")
    public ResponseEntity<ProjectResponse> validateProject(
            @PathVariable Long id,
            @RequestParam ProjectStatus status) {
        ProjectResponse response = projectService.updateProjectStatus(id, status);
        return ResponseEntity.ok(response);
    }
}
```

---

## 📦 Étape 11 : Gestion des exceptions

### 11.1 GlobalExceptionHandler.java

```java
package com.greenfund.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<Map<String, String>> handleRuntimeException(RuntimeException e) {
        Map<String, String> error = new HashMap<>();
        error.put("message", e.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, String>> handleValidationExceptions(
            MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach((error) -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            errors.put(fieldName, errorMessage);
        });
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errors);
    }
}
```

---

## 📦 Étape 12 : Tests et démarrage

### 12.1 Créer un utilisateur admin par défaut

Créer une classe `DataInitializer.java` :

```java
package com.greenfund.config;

import com.greenfund.model.entity.User;
import com.greenfund.model.enum.Role;
import com.greenfund.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {
    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) {
        if (!userRepository.existsByEmail("admin@greenfund.com")) {
            User admin = new User();
            admin.setName("Admin");
            admin.setEmail("admin@greenfund.com");
            admin.setPassword(passwordEncoder.encode("admin123"));
            admin.setRole(Role.ADMIN);
            admin.setActive(true);
            userRepository.save(admin);
        }
    }
}
```

### 12.2 Lancer l'application

1. Démarrer MySQL
2. Créer la base de données `greenfund_db`
3. Lancer l'application Spring Boot
4. Tester les endpoints avec Postman ou cURL

---

## 📋 Endpoints API

### Authentification
- `POST /api/auth/register` - Inscription
- `POST /api/auth/login` - Connexion

### Projets
- `GET /api/projects` - Liste des projets
- `GET /api/projects/{id}` - Détails d'un projet
- `POST /api/projects` - Créer un projet (OWNER)
- `PUT /api/projects/{id}` - Modifier un projet (OWNER)

### Investissements
- `POST /api/investments/projects/{projectId}` - Investir dans un projet
- `GET /api/investments/my-investments` - Mes investissements

### Administration
- `GET /api/admin/projects/pending` - Projets en attente
- `PUT /api/admin/projects/{id}/validate` - Valider/rejeter un projet
- `GET /api/admin/users` - Liste des utilisateurs
- `GET /api/admin/stats` - Statistiques

---

## 🚀 Prochaines étapes

1. ✅ Tester tous les endpoints
2. ✅ Ajouter la validation des données
3. ✅ Implémenter la pagination
4. ✅ Ajouter les tests unitaires et d'intégration
5. ✅ Configurer le déploiement (Docker, etc.)
6. ✅ Intégrer avec l'application Flutter

---

*Guide créé pour GreenFund Backend - Spring Boot 3.2.0*

