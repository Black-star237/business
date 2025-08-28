import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sidebar.dart';
import 'no_company_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hhkqazdivfkqcpcjdqbv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhoa3FhemRpdmZrcWNwY2pkcWJ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU2NzIwMzcsImV4cCI6MjA3MTI0ODAzN30.PYopflHcTXkuMC9k0o2vMPJzBrIp705hrvxUdggMZoM',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fluxiabiz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with blur and overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/1238.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          // Dark overlay
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with rounded corners
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/logo.jpg',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Welcome text
                  const Text(
                    'Bienvenu sur',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Fluxiabiz',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700), // Gold color
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Start button with hover effect
                  StatefulBuilder(
                    builder: (context, setState) {
                      bool isHovered = false;

                      return MouseRegion(
                        onEnter: (_) => setState(() => isHovered = true),
                        onExit: (_) => setState(() => isHovered = false),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AuthPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isHovered
                                ? const Color(0xFFFFD700) // Gold when hovered
                                : Colors.black, // Black by default
                            foregroundColor: isHovered
                                ? Colors.black // Black text when hovered
                                : Colors.white, // White text by default
                            padding: const EdgeInsets.symmetric(
                                horizontal: 48, vertical: 16),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: const Text('Commencer'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  String? _errorMessage;

  Future<void> _authenticate() async {
    final supabase = Supabase.instance.client;

    try {
      if (_isLogin) {
        // Login
        final response = await supabase.auth.signInWithPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (response.user != null) {
          // Fetch user profile to get the full name
          final userData = await supabase
              .from('profiles')
              .select('first_name, last_name')
              .eq('id', response.user!.id)
              .single();

          if (userData == null || userData['first_name'] == null || userData['last_name'] == null) {
            throw Exception('Profil utilisateur incomplet');
          }

          final fullName = '${userData['first_name']} ${userData['last_name']}';

          // Check if user has associated companies
          final companyData = await supabase
              .from('company_members')
              .select('company_id, companies!inner (id, name, updated_at)')
              .eq('user_id', response.user!.id);

          print('Company Data: $companyData');

          if (companyData.isEmpty) {
            // No companies associated
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const NoCompanyPage(),
              ),
            );
          } else {
            // Sort companies by updated_at to find the most recently modified
            companyData.sort((a, b) {
              final aDate = DateTime.parse(a['companies']['updated_at']);
              final bDate = DateTime.parse(b['companies']['updated_at']);
              return bDate.compareTo(aDate);
            });

            final activeCompany = companyData.first['companies'];

            print('Active Company: $activeCompany');

            // Check all keys in activeCompany
            activeCompany.keys.forEach((key) {
              print('Key: $key, Value: ${activeCompany[key]}');
            });

            if (activeCompany == null || activeCompany['id'] == null) {
              throw Exception('Entreprise active non trouvée');
            }

            // Fetch the active company details
            final activeCompanyDetails = await supabase
                .from('companies')
                .select('name, logo_url, banner_url')
                .eq('id', activeCompany['id'])
                .single();

            print('Active Company Details: $activeCompanyDetails');

            if (activeCompanyDetails == null) {
              throw Exception('Détails de l\'entreprise active non trouvés');
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => UserPage(
                  user: response.user!,
                  fullName: fullName,
                  activeCompanyName: activeCompanyDetails['name'] ?? 'Nom non disponible',
                  activeCompanyLogoUrl: activeCompanyDetails['logo_url'] ?? 'assets/logo.jpg',
                  activeCompanyBannerUrl: activeCompanyDetails['banner_url'] ?? 'assets/1238.jpg',
                ),
              ),
            );
          }
        }
      } else {
        // Sign up
        final response = await supabase.auth.signUp(
          email: _emailController.text,
          password: _passwordController.text,
          data: {
            'first_name': _nameController.text.split(' ').first,
            'last_name': _nameController.text.split(' ').length > 1
                ? _nameController.text.split(' ').sublist(1).join(' ')
                : '',
          },
        );
        if (response.user != null) {
          // Insert into profiles table
          await supabase.from('profiles').insert({
            'id': response.user!.id,
            'email': response.user!.email,
            'first_name': _nameController.text.split(' ').first,
            'last_name': _nameController.text.split(' ').length > 1
                ? _nameController.text.split(' ').sublist(1).join(' ')
                : '',
          });

          // Check if user has associated companies (for sign up, typically none)
          final companyData = await supabase
              .from('company_members')
              .select('company_id')
              .eq('user_id', response.user!.id);

          if (companyData.isEmpty) {
            // No companies associated
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const NoCompanyPage(),
              ),
            );
          } else {
            // This case is unlikely for sign up, but handle it anyway
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => UserPage(
                  user: response.user!,
                  fullName: _nameController.text,
                  activeCompanyName: null, // Would need to fetch company name
                ),
              ),
            );
          }
        }
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Erreur : ${error.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with blur and overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/welcom.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          // Dark overlay
          Container(
            color: Colors.black.withOpacity(0.4),
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
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isLogin ? 'Connexion' : 'Inscription',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (!_isLogin) ...[
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Nom complet',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.3),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.3),
                          ),
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.3),
                          ),
                          style: const TextStyle(color: Colors.white),
                          obscureText: true,
                        ),
                        const SizedBox(height: 24),
                        if (_errorMessage != null) ...[
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                        ],
                        ElevatedButton(
                          onPressed: _authenticate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 16),
                            textStyle: const TextStyle(fontSize: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(_isLogin ? 'Se connecter' : "S'inscrire"),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                              _errorMessage = null;
                            });
                          },
                          child: Text(
                            _isLogin
                                ? 'Pas encore de compte ? S\'inscrire'
                                : 'Déjà un compte ? Se connecter',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserPage extends StatefulWidget {
   final User user;
   final String fullName;
   final String? activeCompanyName;
   final String? activeCompanyLogoUrl;
   final String? activeCompanyBannerUrl;

   const UserPage({
     super.key,
     required this.user,
     required this.fullName,
     this.activeCompanyName,
     this.activeCompanyLogoUrl,
     this.activeCompanyBannerUrl,
   });

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool _isDarkMode = false;
  bool _showSidebar = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _toggleSidebar() {
    setState(() {
      _showSidebar = !_showSidebar;
    });
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      drawer: Sidebar(
        companyName: widget.activeCompanyName,
        companyLogoUrl: widget.activeCompanyLogoUrl,
        companyBannerUrl: widget.activeCompanyBannerUrl,
      ),
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher...',
              hintStyle: TextStyle(color: Colors.white70),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              prefixIcon: Icon(Icons.search, color: Colors.white70),
            ),
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
              color: Colors.white,
            ),
            onPressed: _toggleTheme,
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Action pour les notifications
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.black),
            ),
          ),
        ],
      ),
      body: Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Text(
             'Bonjour, ${widget.fullName}!',
             style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
             textAlign: TextAlign.center,
           ),
           if (widget.activeCompanyName != null) ...[
             const SizedBox(height: 10),
             Text(
               'Entreprise active: ${widget.activeCompanyName}',
               style: const TextStyle(fontSize: 18, color: Colors.grey),
               textAlign: TextAlign.center,
             ),
           ]
         ],
       ),
     ),
    );
  }
}
