import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'main.dart';
import 'loading_indicator.dart';
import 'data_service.dart';

class CreateCompanyPage extends StatefulWidget {
  const CreateCompanyPage({super.key});

  @override
  _CreateCompanyPageState createState() => _CreateCompanyPageState();
}

class _CreateCompanyPageState extends State<CreateCompanyPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  Uint8List? _logoBytes;
  Uint8List? _bannerBytes;
  String? _logoUrl;
  String? _bannerUrl;
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _pickImage(bool isLogo) async {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();

    input.onChange.listen((event) {
      final files = input.files;
      if (files!.isNotEmpty) {
        final file = files.first;
        final reader = html.FileReader();

        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((_) {
          setState(() {
            if (isLogo) {
              _logoBytes = reader.result as Uint8List?;
              _logoUrl = html.Url.createObjectUrlFromBlob(file);
            } else {
              _bannerBytes = reader.result as Uint8List?;
              _bannerUrl = html.Url.createObjectUrlFromBlob(file);
            }
          });
        });
      }
    });
  }

  Future<void> _createCompany() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final supabase = Supabase.instance.client;
        final user = supabase.auth.currentUser;

        if (user == null) {
          setState(() {
            _errorMessage = 'Utilisateur non connecté';
            _isLoading = false;
          });
          return;
        }

        // Upload logo if available
        String? logoUrl;
        if (_logoBytes != null) {
          final logoFileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}_logo';
          final logoResponse = await supabase.storage
              .from('company-logos')
              .uploadBinary(logoFileName, _logoBytes!, fileOptions: FileOptions(upsert: true));

          logoUrl = supabase.storage
              .from('company-logos')
              .getPublicUrl(logoFileName);
        }

        // Upload banner if available
        String? bannerUrl;
        if (_bannerBytes != null) {
          final bannerFileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}_banner';
          final bannerResponse = await supabase.storage
              .from('company-banners')
              .uploadBinary(bannerFileName, _bannerBytes!, fileOptions: FileOptions(upsert: true));

          bannerUrl = supabase.storage
              .from('company-banners')
              .getPublicUrl(bannerFileName);
        }

        // Create company
        final companyResponse = await supabase.from('companies').insert({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'logo_url': logoUrl,
          'banner_url': bannerUrl,
          'created_by': user.id,
        }).select().single();

        // Add user as company member with owner role
        await supabase.from('company_members').insert({
          'company_id': companyResponse['id'],
          'user_id': user.id,
          'role': 'owner',
          'is_active': true,
          'joined_at': DateTime.now().toIso8601String(),
        });

        // Navigate to main page with new company data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserPage(
              user: user,
              fullName: '${user.userMetadata?['first_name'] ?? ''} ${user.userMetadata?['last_name'] ?? ''}',
              activeCompanyName: companyResponse['name'],
              activeCompanyLogoUrl: logoUrl,
              activeCompanyBannerUrl: bannerUrl,
            ),
          ),
        );
      } catch (error) {
        setState(() {
          _errorMessage = 'Erreur: ${error.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with blur
          Positioned.fill(
            child: FutureBuilder<String?>(
              future: DataService().getBackgroundImageUrl(9).then((url) {
                if (url != null) {
                  print("Background image URL for ID 9: $url");
                } else {
                  print("No background image found for ID 9");
                }
                return url;
              }),
              builder: (context, snapshot) {
                return BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: snapshot.connectionState == ConnectionState.waiting
                            ? const AssetImage('assets/creation_entreprise.webp')
                            : snapshot.hasError || !snapshot.hasData
                                ? const AssetImage('assets/creation_entreprise.webp')
                                : NetworkImage(snapshot.data!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Dark overlay
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Banner selection with logo overlay
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () => _pickImage(false),
                                child: Container(
                                  height: 180,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    image: _bannerUrl != null
                                        ? DecorationImage(
                                            image: NetworkImage(_bannerUrl!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: _bannerUrl == null
                                      ? Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.add_photo_alternate, size: 40, color: Colors.white.withOpacity(0.7)),
                                              const SizedBox(height: 8),
                                              Text('Ajouter une bannière', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                                            ],
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              // Logo selection
                              Positioned(
                                left: 20,
                                top: 20,
                                child: GestureDetector(
                                  onTap: () => _pickImage(true),
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.white,
                                    backgroundImage: _logoUrl != null
                                        ? NetworkImage(_logoUrl!)
                                        : null,
                                    child: _logoUrl == null
                                        ? Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.add_a_photo, size: 30, color: Colors.black),
                                              Text('Logo', style: TextStyle(color: Colors.black, fontSize: 12)),
                                            ],
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 60),
                          // Form fields
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              children: [
                                // Company name
                                TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Nom de l\'entreprise',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.3),
                                  ),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer un nom';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Email
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.3),
                                  ),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer un email';
                                    }
                                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                      return 'Veuillez entrer un email valide';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Phone
                                TextFormField(
                                  controller: _phoneController,
                                  decoration: InputDecoration(
                                    labelText: 'Numéro de téléphone',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.3),
                                  ),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer un numéro de téléphone';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),

                                // Error message
                                if (_errorMessage != null) ...[
                                  Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // Submit button
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _createCompany,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        )
                                      : const Text('Créer l\'entreprise', style: TextStyle(fontSize: 16)),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: LoadingIndicator(showOverlay: false),
                ),
              ),
            ),
        ],
      ),
    );
  }
}