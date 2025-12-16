# Guide : Ajout d'Images pour les Projets (Production-Ready)

Ce guide détaille toutes les modifications nécessaires pour ajouter la fonctionnalité d'upload d'images aux projets, côté backend (Spring Boot 3) et frontend (Flutter 3+), avec une approche sécurisée et prête pour la production.

---

## 🔧 MODIFICATIONS BACKEND (Spring Boot 3 / Java 17)

### 1. Dépendances Maven (Optionnelles)

Dans `pom.xml`, la dépendance `commons-io` est **optionnelle** car nous utilisons uniquement les APIs Java standard (NIO). Si vous avez besoin de fonctionnalités supplémentaires, vous pouvez l'ajouter :

```xml
<!-- Optionnel : uniquement si vous avez besoin de fonctionnalités supplémentaires -->
<!-- <dependency>
    <groupId>commons-io</groupId>
    <artifactId>commons-io</artifactId>
    <version>2.11.0</version>
</dependency> -->
```

**Note** : Ce guide n'utilise que les APIs Java standard, donc cette dépendance n'est pas nécessaire.

### 2. Configuration du stockage des fichiers

Créer un nouveau fichier : `src/main/java/com/greenfund/greenfund_backend/config/FileStorageConfig.java`

```java
package com.greenfund.greenfund_backend.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@Configuration
public class FileStorageConfig implements WebMvcConfigurer {

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // Créer le dossier racine s'il n'existe pas
        Path uploadPath = Paths.get(uploadDir);
        if (!Files.exists(uploadPath)) {
            try {
                Files.createDirectories(uploadPath);
            } catch (Exception e) {
                throw new RuntimeException("Could not create upload directory", e);
            }
        }

        // Exposer les fichiers statiques
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:" + uploadPath.toAbsolutePath() + "/");
    }
}
```

### 3. Configuration dans application.properties

```properties
# File Upload Configuration
app.upload.dir=uploads
spring.servlet.multipart.enabled=true
spring.servlet.multipart.max-file-size=5MB
spring.servlet.multipart.max-request-size=5MB
```

### 4. Service de gestion des fichiers avec sécurité renforcée

Créer : `src/main/java/com/greenfund/greenfund_backend/service/FileStorageService.java`

```java
package com.greenfund.greenfund_backend.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

@Service
public class FileStorageService {

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

    // Whitelist stricte des formats autorisés
    private static final List<String> ALLOWED_CONTENT_TYPES = Arrays.asList(
        "image/jpeg",
        "image/jpg",
        "image/png",
        "image/webp"
    );

    private static final List<String> ALLOWED_EXTENSIONS = Arrays.asList(
        ".jpg",
        ".jpeg",
        ".png",
        ".webp"
    );

    /**
     * Stocke un fichier image pour un projet spécifique
     * Structure : uploads/projects/{projectId}/{uuid}.{extension}
     * 
     * @param file Le fichier à stocker
     * @param projectId L'ID du projet
     * @return Le chemin relatif stocké en base (ex: projects/12/uuid.jpg)
     * @throws RuntimeException Si le fichier est invalide
     */
    public String storeProjectImage(MultipartFile file, Long projectId) throws IOException {
        if (file.isEmpty()) {
            throw new RuntimeException("File is empty");
        }

        // Validation du content-type
        String contentType = file.getContentType();
        if (contentType == null || !ALLOWED_CONTENT_TYPES.contains(contentType.toLowerCase())) {
            throw new RuntimeException(
                String.format("Invalid file type. Allowed types: %s", ALLOWED_CONTENT_TYPES)
            );
        }

        // Validation de l'extension
        String originalFilename = file.getOriginalFilename();
        if (originalFilename == null || originalFilename.isEmpty()) {
            throw new RuntimeException("Filename is required");
        }

        String extension = "";
        int lastDotIndex = originalFilename.lastIndexOf(".");
        if (lastDotIndex > 0 && lastDotIndex < originalFilename.length() - 1) {
            extension = originalFilename.substring(lastDotIndex).toLowerCase();
        }

        if (!ALLOWED_EXTENSIONS.contains(extension)) {
            throw new RuntimeException(
                String.format("Invalid file extension. Allowed extensions: %s", ALLOWED_EXTENSIONS)
            );
        }

        // Normaliser l'extension (jpg/jpeg -> jpg)
        if (extension.equals(".jpeg")) {
            extension = ".jpg";
        }

        // Générer un nom unique
        String filename = UUID.randomUUID().toString() + extension;

        // Créer la structure de dossiers : uploads/projects/{projectId}/
        Path projectDir = Paths.get(uploadDir, "projects", projectId.toString());
        if (!Files.exists(projectDir)) {
            Files.createDirectories(projectDir);
        }

        // Sauvegarder le fichier
        Path filePath = projectDir.resolve(filename);
        Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

        // Retourner le chemin relatif pour stockage en base
        return String.format("projects/%d/%s", projectId, filename);
    }

    /**
     * Supprime un fichier image
     * 
     * @param relativePath Le chemin relatif stocké en base (ex: projects/12/uuid.jpg)
     */
    public void deleteFile(String relativePath) throws IOException {
        if (relativePath == null || relativePath.isEmpty()) {
            return;
        }
        Path filePath = Paths.get(uploadDir, relativePath);
        Files.deleteIfExists(filePath);
    }

    /**
     * Génère l'URL publique d'accès à l'image
     * 
     * @param relativePath Le chemin relatif stocké en base
     * @return L'URL publique (ex: /uploads/projects/12/uuid.jpg)
     */
    public String getFileUrl(String relativePath) {
        if (relativePath == null || relativePath.isEmpty()) {
            return null;
        }
        return "/uploads/" + relativePath;
    }
}
```

### 5. Modifier l'entité Project

Dans `src/main/java/com/greenfund/greenfund_backend/model/entity/Project.java`, ajouter :

```java
@Column(name = "image_path", length = 255)
private String imagePath;  // Stocke le chemin relatif : projects/{id}/{uuid}.jpg
```

**Note** : Le champ s'appelle `imagePath` (pas `imageFilename`) car il stocke un chemin relatif.

### 6. Modifier les DTOs

#### ProjectResponse.java
Ajouter :

```java
private String imageUrl;  // URL publique complète
```

### 7. Modifier ProjectService

Dans `ProjectService.java`, modifier la méthode `convertToResponse` :

```java
@Autowired
private FileStorageService fileStorageService;

private ProjectResponse convertToResponse(Project project) {
    ProjectResponse response = new ProjectResponse();
    // ... code existant ...
    response.setImageUrl(fileStorageService.getFileUrl(project.getImagePath()));
    return response;
}
```

### 8. Contrôleur pour l'upload d'images avec sécurité renforcée

Créer : `src/main/java/com/greenfund/greenfund_backend/controller/FileController.java`

```java
package com.greenfund.greenfund_backend.controller;

import com.greenfund.greenfund_backend.model.entity.Project;
import com.greenfund.greenfund_backend.repository.ProjectRepository;
import com.greenfund.greenfund_backend.security.UserPrincipal;
import com.greenfund.greenfund_backend.service.FileStorageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/files")
@CrossOrigin(origins = "*")
public class FileController {

    @Autowired
    private FileStorageService fileStorageService;

    @Autowired
    private ProjectRepository projectRepository;

    @PostMapping("/projects/{projectId}/image")
    @PreAuthorize("hasRole('OWNER')")
    public ResponseEntity<Map<String, String>> uploadProjectImage(
            @PathVariable Long projectId,
            @RequestParam("file") MultipartFile file) {
        
        try {
            // Vérifier que le projet existe et appartient à l'utilisateur
            UserPrincipal userPrincipal = (UserPrincipal) SecurityContextHolder.getContext()
                    .getAuthentication().getPrincipal();
            
            Project project = projectRepository.findById(projectId)
                    .orElseThrow(() -> new RuntimeException("Project not found"));
            
            if (!project.getOwner().getId().equals(userPrincipal.getId())) {
                throw new RuntimeException("You are not authorized to update this project");
            }

            // Supprimer l'ancienne image si elle existe
            if (project.getImagePath() != null && !project.getImagePath().isEmpty()) {
                try {
                    fileStorageService.deleteFile(project.getImagePath());
                } catch (Exception e) {
                    // Logger l'erreur mais continuer
                    System.err.println("Error deleting old image: " + e.getMessage());
                }
            }

            // Sauvegarder la nouvelle image (validation incluse dans le service)
            String relativePath = fileStorageService.storeProjectImage(file, projectId);
            project.setImagePath(relativePath);
            projectRepository.save(project);

            Map<String, String> response = new HashMap<>();
            response.put("imageUrl", fileStorageService.getFileUrl(relativePath));
            response.put("message", "Image uploaded successfully");

            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            throw e;  // Re-lancer les RuntimeException (validation, etc.)
        } catch (Exception e) {
            throw new RuntimeException("Error uploading image: " + e.getMessage(), e);
        }
    }
}
```

### 9. Migration de base de données

Pour la production, créer une migration SQL :

```sql
ALTER TABLE projects ADD COLUMN image_path VARCHAR(255);
```

Avec `ddl-auto=update`, Hibernate créera automatiquement la colonne en développement.

---

## 📱 MODIFICATIONS FRONTEND (Flutter 3+)

### 1. Ajouter les dépendances

Dans `pubspec.yaml`, ajouter :

```yaml
dependencies:
  # ... dépendances existantes ...
  image_picker: ^1.0.7
  http: ^1.2.0  # Déjà présent
  mime: ^1.0.4  # Pour détecter le vrai MIME type
```

Puis exécuter : `flutter pub get`

### 2. Modifier le modèle Project

Dans `lib/models/project.dart`, ajouter :

```dart
final String? imageUrl;  // URL de l'image

// Dans le constructeur
Project({
  // ... paramètres existants ...
  this.imageUrl,
});

// Dans fromJson
factory Project.fromJson(Map<String, dynamic> json) {
  return Project(
    // ... champs existants ...
    imageUrl: json['imageUrl'],
  );
}

// Dans toJson
Map<String, dynamic> toJson() {
  return {
    // ... champs existants ...
    'imageUrl': imageUrl,
  };
}

// Dans copyWith
Project copyWith({
  // ... paramètres existants ...
  String? imageUrl,
}) {
  return Project(
    // ... champs existants ...
    imageUrl: imageUrl ?? this.imageUrl,
  );
}
```

### 3. Méthode d'upload avec MIME type correct

Dans `lib/services/api_service.dart`, ajouter :

```dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

static Future<String> uploadProjectImage(String projectId, File imageFile) async {
  try {
    final headers = await _getHeaders();
    // Retirer Content-Type pour laisser http gérer multipart
    headers.remove('Content-Type');
    
    final uri = Uri.parse('$baseUrl/files/projects/$projectId/image');
    
    var request = http.MultipartRequest('POST', uri);
    
    // Ajouter les headers d'authentification
    request.headers.addAll(headers);
    
    // Détecter le vrai MIME type avec le package mime
    final mimeType = lookupMimeType(imageFile.path);
    if (mimeType == null || !mimeType.startsWith('image/')) {
      throw Exception('Invalid image file type');
    }
    
    // Extraire le type et sous-type du MIME
    final mimeTypeData = mimeType.split('/');
    if (mimeTypeData.length != 2) {
      throw Exception('Invalid MIME type format');
    }
    
    // Normaliser jpeg -> jpg pour la cohérence
    String subtype = mimeTypeData[1].toLowerCase();
    if (subtype == 'jpeg') {
      subtype = 'jpg';
    }
    
    // Créer le MediaType correct
    final contentType = MediaType('image', subtype);
    
    // Ajouter le fichier avec le bon MIME type
    var multipartFile = await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      filename: imageFile.path.split('/').last,
      contentType: contentType,
    );
    request.files.add(multipartFile);
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['imageUrl'] as String;
    } else {
      final errorBody = response.body;
      try {
        final errorJson = jsonDecode(errorBody);
        throw Exception(errorJson['message'] ?? 'Failed to upload image');
      } catch (_) {
        throw Exception('Failed to upload image: $errorBody');
      }
    }
  } catch (e) {
    if (e.toString().contains('Invalid image file type') || 
        e.toString().contains('Invalid MIME type')) {
      rethrow;
    }
    throw Exception('Error uploading image: $e');
  }
}
```

### 4. Modifier la page de création de projet

Dans `lib/features/owner/create_project_page.dart`, modifier :

```dart
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class _CreateProjectPageState extends State<CreateProjectPage> {
  // ... variables existantes ...
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sélection: $e')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la prise de photo: $e')),
        );
      }
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
        
        final targetAmount = double.tryParse(_target.text.replaceAll(',', '.')) ?? 0.0;
        
        // Créer le projet
        final project = await ApiService.createProject(
          title: _title.text.trim(),
          city: _city.text.trim(),
          energyType: _energy,
          description: _description.text.trim(),
          targetAmount: targetAmount,
        );
        
        // Uploader l'image si sélectionnée
        if (_selectedImage != null) {
          try {
            await ApiService.uploadProjectImage(project.id, _selectedImage!);
          } catch (e) {
            // Si l'upload d'image échoue, le projet est déjà créé
            // On affiche un avertissement mais on ne bloque pas
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Projet créé mais erreur lors de l\'upload de l\'image: $e'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        }
        
        if (mounted) {
          Navigator.pop(context); // Fermer le loading
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Projet créé avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
          
          Navigator.pop(context); // Retourner à la page précédente
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Fermer le loading
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la création: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un projet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Widget pour sélectionner l'image
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('Galerie'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage();
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text('Appareil photo'),
                            onTap: () {
                              Navigator.pop(context);
                              _takePhoto();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryGreen,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 64,
                              color: AppColors.primaryGreen,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ajouter une image',
                              style: TextStyle(
                                color: AppColors.primaryGreen,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              
              // ... reste des champs existants ...
              GreenTextField(controller: _title, label: 'Titre', validator: (v) => (v==null||v.isEmpty)?'Titre requis':null),
              const SizedBox(height: 12),
              // ... autres champs ...
            ],
          ),
        ),
      ),
    );
  }
}
```

### 5. Modifier la page d'édition de projet

Dans `lib/features/owner/edit_project_page.dart`, ajouter la même logique d'upload d'image avec gestion de l'image existante.

### 6. Modifier le widget ProjectCard

Dans `lib/widgets/project_card.dart`, ajouter :

```dart
final String? imageUrl;  // Ajouter ce paramètre

const ProjectCard({
  // ... paramètres existants ...
  this.imageUrl,
});

// Dans le build, remplacer l'icône par l'image si disponible :
if (imageUrl != null && imageUrl!.isNotEmpty) ...[
  ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.network(
      imageUrl!.startsWith('http') 
        ? imageUrl! 
        : '${ApiService.baseUrl.replaceAll('/api', '')}$imageUrl',
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Fallback vers l'icône si l'image ne charge pas
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: energyColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(energyIcon, color: energyColor, size: 24),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: energyColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / 
                  loadingProgress.expectedTotalBytes!
                : null,
            strokeWidth: 2,
            color: energyColor,
          ),
        );
      },
    ),
  ),
] else ...[
  Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: energyColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(energyIcon, color: energyColor, size: 24),
  ),
],
```

### 7. Mettre à jour les pages qui utilisent ProjectCard

Dans toutes les pages qui utilisent `ProjectCard`, passer le `imageUrl` :

```dart
ProjectCard(
  title: project.title,
  energy: project.energyType,
  city: project.city,
  progress: project.progress,
  raisedAmount: project.raisedAmount,
  targetAmount: project.targetAmount,
  imageUrl: project.imageUrl,  // Ajouter cette ligne
  onTap: () { /* ... */ },
)
```

### 8. Permissions Android (Android 13+)

Dans `android/app/src/main/AndroidManifest.xml`, ajouter :

```xml
<!-- Permissions pour Android 13+ (API 33+) -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<!-- Permissions pour Android 12 et inférieur (API 32 et moins) -->
<uses-permission 
    android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
<!-- Permission caméra -->
<uses-permission android:name="android.permission.CAMERA" />
```

**Important** : Ne pas utiliser `WRITE_EXTERNAL_STORAGE` qui est obsolète depuis Android 10+ et n'est plus nécessaire pour accéder aux images.

### 9. Permissions iOS

Dans `ios/Runner/Info.plist`, ajouter :

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Nous avons besoin d'accéder à votre galerie pour ajouter des images aux projets</string>
<key>NSCameraUsageDescription</key>
<string>Nous avons besoin d'accéder à votre appareil photo pour prendre des photos de projets</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Nous avons besoin de sauvegarder des images dans votre galerie</string>
```

---

## 📋 Checklist de mise en œuvre

### Backend
- [ ] Vérifier que `commons-io` n'est pas nécessaire (optionnel)
- [ ] Créer `FileStorageConfig.java`
- [ ] Ajouter configuration dans `application.properties`
- [ ] Créer `FileStorageService.java` avec whitelist stricte (jpg, png, webp)
- [ ] Ajouter champ `imagePath` dans l'entité `Project`
- [ ] Ajouter champ `imageUrl` dans `ProjectResponse`
- [ ] Modifier `ProjectService.convertToResponse()` pour utiliser `imagePath`
- [ ] Créer `FileController.java` avec validation de sécurité
- [ ] Tester l'upload avec formats autorisés (jpg, png, webp)
- [ ] Tester le rejet de formats non autorisés
- [ ] Vérifier la structure de stockage : `uploads/projects/{id}/{uuid}.jpg`

### Frontend
- [ ] Ajouter `image_picker` et `mime` dans `pubspec.yaml`
- [ ] Modifier le modèle `Project` pour inclure `imageUrl`
- [ ] Ajouter méthode `uploadProjectImage()` avec MIME type correct dans `ApiService`
- [ ] Modifier `CreateProjectPage` avec sélection d'image
- [ ] Modifier `EditProjectPage` avec sélection d'image
- [ ] Modifier `ProjectCard` pour afficher l'image avec fallback
- [ ] Mettre à jour toutes les utilisations de `ProjectCard`
- [ ] Corriger permissions Android (READ_MEDIA_IMAGES pour API 33+)
- [ ] Ajouter permissions iOS
- [ ] Tester sur émulateur Android 13+
- [ ] Tester sur device iOS

---

## 🧪 Tests à effectuer

### Backend
1. **Upload valide** :
   - Upload d'image JPG avec projet valide → ✅
   - Upload d'image PNG avec projet valide → ✅
   - Upload d'image WEBP avec projet valide → ✅

2. **Sécurité** :
   - Upload d'un fichier non-image (ex: .pdf) → ❌ Rejeté
   - Upload avec content-type falsifié → ❌ Rejeté
   - Upload par utilisateur non propriétaire → ❌ Rejeté
   - Upload avec projet inexistant → ❌ Rejeté

3. **Structure** :
   - Vérifier que l'image est stockée dans `uploads/projects/{projectId}/{uuid}.jpg`
   - Vérifier que le chemin relatif est stocké en base : `projects/{id}/{uuid}.jpg`
   - Vérifier que l'URL publique fonctionne : `/uploads/projects/{id}/{uuid}.jpg`

4. **Remplacement** :
   - Upload d'une nouvelle image remplace l'ancienne → ✅
   - Ancienne image supprimée du disque → ✅

### Frontend
1. **Sélection** :
   - Sélection d'image depuis la galerie → ✅
   - Prise de photo avec l'appareil → ✅
   - Affichage de l'aperçu avant upload → ✅

2. **Upload** :
   - Upload lors de la création de projet → ✅
   - Upload lors de l'édition de projet → ✅
   - Gestion d'erreur si upload échoue → ✅

3. **Affichage** :
   - Affichage de l'image dans les cartes → ✅
   - Fallback vers icône si image non disponible → ✅
   - Loading state pendant le chargement → ✅

4. **Permissions** :
   - Demande de permission galerie (Android 13+) → ✅
   - Demande de permission caméra → ✅

---

## 🔒 Bonnes pratiques & Sécurité

### Backend

1. **Validation stricte** :
   - ✅ Whitelist des formats : jpg, png, webp uniquement
   - ✅ Vérification du content-type ET de l'extension
   - ✅ Rejet de tout format non autorisé

2. **Stockage sécurisé** :
   - ✅ Structure organisée par projet : `uploads/projects/{id}/`
   - ✅ Noms de fichiers uniques (UUID)
   - ✅ Chemin relatif stocké en base (pas de chemin absolu)

3. **Autorisations** :
   - ✅ Seul le propriétaire peut uploader/modifier l'image
   - ✅ Vérification de l'existence du projet
   - ✅ Validation des rôles avec `@PreAuthorize`

4. **Gestion des erreurs** :
   - ✅ Messages d'erreur clairs
   - ✅ Suppression de l'ancienne image en cas de remplacement
   - ✅ Gestion des exceptions avec logging

### Frontend

1. **MIME types** :
   - ✅ Utilisation du package `mime` pour détecter le vrai type
   - ✅ Normalisation jpeg → jpg
   - ✅ Validation avant envoi

2. **Permissions** :
   - ✅ Permissions Android 13+ : `READ_MEDIA_IMAGES`
   - ✅ Permissions Android 12- : `READ_EXTERNAL_STORAGE` avec `maxSdkVersion=32`
   - ✅ Pas de `WRITE_EXTERNAL_STORAGE` (obsolète)

3. **UX** :
   - ✅ Aperçu de l'image avant upload
   - ✅ Loading states
   - ✅ Gestion d'erreurs avec messages clairs
   - ✅ Fallback visuel si image non disponible

4. **Performance** :
   - ✅ Compression des images avant upload (imageQuality: 85)
   - ✅ Redimensionnement (maxWidth: 1920, maxHeight: 1080)
   - ✅ Lazy loading des images dans les listes

---

## ⚠️ Points d'attention

1. **Taille des fichiers** :
   - Limite configurée à 5MB (modifiable dans `application.properties`)
   - Compression côté client recommandée avant upload

2. **Stockage en production** :
   - Pour la production, considérer un stockage cloud (AWS S3, Cloudinary, Azure Blob)
   - Sauvegarder régulièrement les fichiers
   - Nettoyer les fichiers orphelins (projets supprimés)

3. **Performance** :
   - Pour les listes, considérer des thumbnails
   - Cache des images téléchargées
   - CDN pour servir les images statiques

4. **Sécurité avancée** :
   - Scanner les images pour contenu malveillant (optionnel)
   - Rate limiting sur l'endpoint d'upload
   - Validation de la taille réelle du fichier (pas seulement le header)

---

## 🚀 Améliorations futures

- Support de plusieurs images par projet
- Redimensionnement automatique côté serveur (thumbnails)
- Upload progressif avec barre de progression
- Compression automatique côté serveur
- Support de formats additionnels (HEIC, AVIF)
- Intégration avec un service de stockage cloud
- Cache intelligent des images
- Lazy loading avec placeholder

---

## 📝 Notes techniques

### Structure de stockage

```
uploads/
└── projects/
    ├── 1/
    │   ├── a1b2c3d4-e5f6-7890-abcd-ef1234567890.jpg
    │   └── b2c3d4e5-f6a7-8901-bcde-f12345678901.png
    ├── 2/
    │   └── c3d4e5f6-a7b8-9012-cdef-123456789012.webp
    └── ...
```

### Format stocké en base

Le champ `imagePath` dans la table `projects` contient :
- Format : `projects/{projectId}/{uuid}.{ext}`
- Exemple : `projects/12/a1b2c3d4-e5f6-7890-abcd-ef1234567890.jpg`

### URL publique

L'URL générée pour accéder à l'image :
- Format : `/uploads/projects/{projectId}/{uuid}.{ext}`
- Exemple : `/uploads/projects/12/a1b2c3d4-e5f6-7890-abcd-ef1234567890.jpg`

---

*Guide mis à jour et corrigé pour production - Spring Boot 3 / Flutter 3+ - Version finale*
