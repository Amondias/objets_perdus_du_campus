import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../../config/app_config.dart';
import '../../models/item_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/items_provider.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  String _type = 'lost';
  String _category = 'other';
  List<XFile> _images = [];
  final _picker = ImagePicker();
  
  double? _latitude;
  double? _longitude;
  bool _isGettingLocation = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024, // Limite la largeur pour le Web
      maxHeight: 1024, // Limite la hauteur
      imageQuality: 80, // Compresse à 80%
    );
    if (pickedFile != null) {
      setState(() {
        _images.add(pickedFile);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Le service de localisation est désactivé.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Permissions de localisation refusées.';
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw 'Permissions de localisation refusées de façon permanente.';
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isGettingLocation = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Position GPS récupérée !')),
      );
    } catch (e) {
      setState(() => _isGettingLocation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsProvider = context.watch<ItemsProvider>();
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publier une annonce'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type Selector
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'lost', label: Text('PERDU'), icon: Icon(Icons.search)),
                  ButtonSegment(value: 'found', label: Text('TROUVÉ'), icon: Icon(Icons.check_circle_outline)),
                ],
                selected: {_type},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => _type = newSelection.first);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return _type == 'lost' ? AppConfig.accentLost : AppConfig.accentFound;
                    }
                    return AppConfig.surfaceVariant;
                  }),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Titre de l\'objet',
                  hintText: 'Ex: Clés, iPhone 13, Sac à dos...',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                items: AppConfig.categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat['id'] as String,
                    child: Row(
                      children: [
                        Icon(cat['icon'] as IconData, size: 20),
                        const SizedBox(width: 10),
                        Text(cat['name'] as String),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),

              // Location
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Lieu (ex: Amphi A)',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isGettingLocation ? null : _getCurrentLocation,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        backgroundColor: _latitude != null ? AppConfig.accentFound : AppConfig.primaryColor,
                      ),
                      child: _isGettingLocation 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Icon(_latitude != null ? Icons.my_location : Icons.location_searching),
                    ),
                  ),
                ],
              ),
              if (_latitude != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text('Position GPS partagée ✓', style: TextStyle(color: AppConfig.accentFound, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Détails, couleur, état...',
                  alignLabelWithHint: true,
                ),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 24),

              // Images
              Text('Photos', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    InkWell(
                      onTap: _pickImage,
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          color: AppConfig.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: const Icon(Icons.add_a_photo_outlined, color: Colors.white38),
                      ),
                    ),
                    ..._images.asMap().entries.map((entry) {
                      final image = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: FutureBuilder<Uint8List>(
                                future: image.readAsBytes(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Image.memory(snapshot.data!, width: 100, height: 100, fit: BoxFit.cover);
                                  }
                                  return Container(width: 100, height: 100, color: AppConfig.surfaceVariant);
                                },
                              ),
                            ),
                            Positioned(
                              top: 4, right: 4,
                              child: GestureDetector(
                                onTap: () => setState(() => _images.removeAt(entry.key)),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Submit Button
              ElevatedButton(
                onPressed: itemsProvider.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          final user = authProvider.user!;
                          final ok = await itemsProvider.addItem(
                            title: _titleCtrl.text.trim(),
                            description: _descCtrl.text.trim(),
                            category: _category,
                            type: _type,
                            location: ItemLocation(
                              latitude: _latitude ?? AppConfig.defaultLatitude,
                              longitude: _longitude ?? AppConfig.defaultLongitude,
                              name: _locationCtrl.text.trim(),
                            ),
                            userId: user.uid,
                            userName: user.name,
                            userPhotoUrl: user.photoUrl,
                            photoFiles: _images,
                            requiresValidation: true,
                          );

                          if (ok && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Annonce publiée !')),
                            );
                            Navigator.pop(context);
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(itemsProvider.error ?? 'Erreur lors de la publication.')),
                            );
                          }
                        }
                      },
                child: itemsProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Publier l\'annonce'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
