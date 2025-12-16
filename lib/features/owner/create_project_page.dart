import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../widgets/green_button.dart';
import '../../widgets/green_text_field.dart';
import '../../services/api_service.dart';
import '../../theme/colors.dart';

/// Création de projet (UI, mock).
class CreateProjectPage extends StatefulWidget {
  const CreateProjectPage({super.key});

  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _city = TextEditingController();
  final _description = TextEditingController();
  final _target = TextEditingController();
  String _energy = 'SOLAIRE';
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _title.dispose();
    _city.dispose();
    _description.dispose();
    _target.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        if (kIsWeb) {
          // Pour Flutter Web, lire les bytes
          final bytes = await image.readAsBytes();
          setState(() {
            _selectedImageBytes = bytes;
            _selectedImage = null;
          });
        } else {
          // Pour mobile, utiliser File
          setState(() {
            _selectedImage = File(image.path);
            _selectedImageBytes = null;
          });
        }
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
        if (kIsWeb) {
          // Pour Flutter Web, lire les bytes
          final bytes = await image.readAsBytes();
          setState(() {
            _selectedImageBytes = bytes;
            _selectedImage = null;
          });
        } else {
          // Pour mobile, utiliser File
          setState(() {
            _selectedImage = File(image.path);
            _selectedImageBytes = null;
          });
        }
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
        if (_selectedImage != null || _selectedImageBytes != null) {
          try {
            if (kIsWeb && _selectedImageBytes != null) {
              // Pour Web, créer un fichier temporaire depuis les bytes
              // Note: Sur Web, on doit utiliser une approche différente
              // Pour l'instant, on skip l'upload sur Web (à implémenter si nécessaire)
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Upload d\'image sur Web non encore implémenté'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            } else if (_selectedImage != null) {
              await ApiService.uploadProjectImage(project.id, _selectedImage!);
            }
          } catch (e) {
            // Si l'upload d'image échoue, le projet est déjà créé
            // On affiche un avertissement mais on ne bloque pas
            if (mounted) {
              Navigator.pop(context); // Fermer le loading
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Projet créé mais erreur lors de l\'upload de l\'image: $e'),
                  backgroundColor: Colors.orange,
                ),
              );
              Navigator.pop(context); // Retourner à la page précédente
              return;
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
                  child: (_selectedImage != null || _selectedImageBytes != null)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: kIsWeb && _selectedImageBytes != null
                              ? Image.memory(
                                  _selectedImageBytes!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )
                              : _selectedImage != null
                                  ? Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : const SizedBox.shrink(),
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
              GreenTextField(controller: _title, label: 'Titre', validator: (v) => (v==null||v.isEmpty)?'Titre requis':null),
              const SizedBox(height: 12),
              GreenTextField(controller: _city, label: 'Ville', validator: (v) => (v==null||v.isEmpty)?'Ville requise':null),
              const SizedBox(height: 12),
              GreenTextField(
                controller: _description,
                label: 'Description',
                maxLines: 4,
                validator: (v) => (v==null||v.isEmpty)?'Description requise':null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _energy,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Type d\'énergie'),
                items: const [
                  DropdownMenuItem(value: 'SOLAIRE', child: Text('Solaire')),
                  DropdownMenuItem(value: 'EOLIENNE', child: Text('Éolienne')),
                  DropdownMenuItem(value: 'BIOGAZ', child: Text('Biogaz')),
                ],
                onChanged: (v) => setState(() => _energy = v ?? 'SOLAIRE'),
              ),
              const SizedBox(height: 12),
              GreenTextField(
                controller: _target,
                label: 'Objectif (MAD)',
                keyboardType: TextInputType.number,
                validator: (v) => (double.tryParse((v??'').replaceAll(',', '.')) == null) ? 'Montant invalide' : null,
              ),
              const SizedBox(height: 16),
              GreenButton(onPressed: _submit, child: const Text('Soumettre')),
            ],
          ),
        ),
      ),
    );
  }
}


