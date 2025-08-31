import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sidebar.dart';
import 'no_company_page.dart';
import 'companies_page.dart';
import 'package:lottie/lottie.dart';
import 'loading_indicator.dart';
import 'navbar.dart';
import 'kpi_card.dart';
import 'data_service.dart';

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
        scaffoldBackgroundColor: Color(0xFFF6F6F6), // Light background
      ),
      home: const AuthChecker(),
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.value(Supabase.instance.client.auth.currentSession),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is already authenticated
          return const MainAppContent();
        } else {
          // User is not authenticated, show welcome page
          return const WelcomePage();
        }
      },
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
                    image: AssetImage('assets/1238.webp'),
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
                      'assets/logo.webp',
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
                      color: Color(0xFFF7931A), // Orange color
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
                                ? const Color(0xFFF7931A) // Orange when hovered
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
  bool _isLoading = false;

  Future<void> _authenticate() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

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
              .select('company_id, companies!inner (id, name)')
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
            // Redirect to CompaniesPage if user has one or more companies
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const CompaniesPage(),
              ),
            );
          }
          _showSuccessAnimation(context);
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
          try {
            // Check if profile already exists before inserting
            final existingProfile = await supabase
                .from('profiles')
                .select()
                .eq('id', response.user!.id)
                .single();

            if (existingProfile == null) {
              // Insert into profiles table only if profile doesn't exist
              await supabase.from('profiles').insert({
                'id': response.user!.id,
                'email': response.user!.email,
                'first_name': _nameController.text.split(' ').first,
                'last_name': _nameController.text.split(' ').length > 1
                    ? _nameController.text.split(' ').sublist(1).join(' ')
                    : '',
              });
            }

            // Check if user has associated companies (for sign up, typically none)
            final companyData = await supabase
                .from('company_members')
                .select('company_id')
                .eq('user_id', response.user!.id);

            if (companyData.isEmpty) {
              // No companies associated - always redirect to NoCompanyPage for new signups
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
                  builder: (context) => const CompaniesPage(),
                ),
              );
            }
            _showSuccessAnimation(context);
          } catch (error) {
            setState(() {
              _errorMessage = 'Erreur lors de la création du profil : ${error.toString()}';
            });
          }
        }
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Erreur : ${error.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
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
                    image: AssetImage('assets/welcom.webp'),
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
                          onPressed: _isLoading ? null : _authenticate,
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
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                )
                              : Text(_isLogin ? 'Se connecter' : "S'inscrire"),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
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

class MainAppContent extends StatelessWidget {
  const MainAppContent({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        if (snapshot.hasData) {
          final data = snapshot.data!;
          return UserPage(
            user: data['user'],
            fullName: data['fullName'],
            activeCompanyName: data['activeCompanyName'],
            activeCompanyLogoUrl: data['activeCompanyLogoUrl'],
            activeCompanyBannerUrl: data['activeCompanyBannerUrl'],
          );
        }

        // Fallback
        return const Center(child: Text('Aucune donnée utilisateur trouvée'));
      },
    );
  }

  Future<Map<String, dynamic>> _getUserData() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    // Fetch user profile to get the full name
    final userData = await supabase
        .from('profiles')
        .select('first_name, last_name')
        .eq('id', user.id)
        .single();

    if (userData == null || userData['first_name'] == null || userData['last_name'] == null) {
      throw Exception('Profil utilisateur incomplet');
    }

    final fullName = '${userData['first_name']} ${userData['last_name']}';

    // Check if user has associated companies
    final companyData = await supabase
    .from('company_members')
    .select('company_id, companies!inner (id, name, logo_url, banner_url)')
    .eq('user_id', user.id)
    .limit(1);

    String? activeCompanyName;
    String? activeCompanyLogoUrl;
    String? activeCompanyBannerUrl;

    if (companyData.isNotEmpty) {
      activeCompanyName = companyData.first['companies']['name'];
      activeCompanyLogoUrl = companyData.first['companies']['logo_url'];
      activeCompanyBannerUrl = companyData.first['companies']['banner_url'];
    }

    return {
      'user': user,
      'fullName': fullName,
      'activeCompanyName': activeCompanyName,
      'activeCompanyLogoUrl': activeCompanyLogoUrl,
      'activeCompanyBannerUrl': activeCompanyBannerUrl,
    };
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
      body: FutureBuilder(
        future: _loadDashboardData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator(showOverlay: false));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final data = snapshot.data ?? {};

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec message de bienvenue
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Bienvenue ',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: '${widget.fullName}',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text: ' sur votre espace ',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: '${widget.activeCompanyName}',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Carte de communication/publicité (à implémenter)
                SizedBox(
                  height: 150,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildAdCard('assets/creation_entreprise.webp', 'Publicité 1'),
                      _buildAdCard('assets/welcom.webp', 'Publicité 2'),
                      _buildAdCard('assets/logo.webp', 'Publicité 3'),
                    ],
                  ),
                ),

                // Filtres de période
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filtrer par période:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterButton('Aujourd\'hui', true),
                            const SizedBox(width: 8),
                            _buildFilterButton('Hier', false),
                            const SizedBox(width: 8),
                            _buildFilterButton('Semaine', false),
                            const SizedBox(width: 8),
                            _buildFilterButton('Mois', false),
                            const SizedBox(width: 8),
                            _buildCalendarButton(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // KPIs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'KPIs:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          KpiCard(
                            title: 'Chiffre d\'affaires',
                            value: data['revenue'] != null
                                ? '${data['revenue']['current']} €'
                                : '0 FCFA',
                            comparison: data['revenue'] != null
                                ? _formatComparison(
                                    data['revenue']['current'],
                                    data['revenue']['previous'],
                                  )
                                : '0%',
                            icon: Icons.attach_money,
                            color: const Color(0xFFFFFFFF),
                          ),
                          KpiCard(
                            title: 'Commandes',
                            value: data['orders'] != null
                                ? data['orders']['current'].toString()
                                : '0',
                            comparison: data['orders'] != null
                                ? _formatComparison(
                                    data['orders']['current'],
                                    data['orders']['previous'],
                                  )
                                : '0%',
                            icon: Icons.shopping_cart,
                            color: const Color(0xFFFFFFFF),
                          ),
                          KpiCard(
                            title: 'Clients Actifs',
                            value: data['activeClients'] != null
                                ? data['activeClients']['current'].toString()
                                : '0',
                            comparison: data['activeClients'] != null
                                ? _formatComparison(
                                    data['activeClients']['current'],
                                    data['activeClients']['previous'],
                                  )
                                : '0%',
                            icon: Icons.people,
                            color: const Color(0xFFFFFFFF),
                          ),
                          KpiCard(
                            title: 'Alertes de Stock',
                            value: data['stockAlerts'] != null
                                ? data['stockAlerts']['current'].toString()
                                : '0',
                            comparison: data['stockAlerts'] != null
                                ? _formatComparison(
                                    data['stockAlerts']['current'],
                                    data['stockAlerts']['previous'],
                                  )
                                : '0%',
                            icon: Icons.warning,
                            color: const Color(0xFFFFFFFF),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions rapides
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Actions rapides:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildActionButton(Icons.android, 'IA'),
                            const SizedBox(width: 16),
                            _buildActionButton(Icons.add_shopping_cart, 'Produit'),
                            const SizedBox(width: 16),
                            _buildActionButton(Icons.person_add, 'Client'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Activités récentes
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Activités récentes:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...(data['recentActivities'] as List<dynamic>? ?? []).map((activity) {
                        return _buildActivityItem(
                          activity['title'],
                          activity['subtitle'],
                          _formatTimeAgo(activity['timestamp']),
                          activity['user'],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Navbar(
        currentIndex: 0,
        onTap: (index) {
          // Gérer la navigation plus tard
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _loadDashboardData() async {
    final dataService = DataService();

    // Calculer les périodes
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1); // Début du mois
    final endDate = DateTime(now.year, now.month + 1, 0); // Fin du mois

    // Période précédente pour comparaison
    final previousStartDate = DateTime(now.year, now.month - 1, 1);
    final previousEndDate = DateTime(now.year, now.month, 0);

    // Récupérer les données
    final kpis = await dataService.getKpis(
      companyId: Supabase.instance.client.auth.currentUser!.id,
      startDate: startDate,
      endDate: endDate,
      previousStartDate: previousStartDate.toIso8601String(),
      previousEndDate: previousEndDate.toIso8601String(),
    );

    final recentActivities = await dataService.getRecentActivities(
      companyId: Supabase.instance.client.auth.currentUser!.id,
      limit: 5,
    );

    return {
      ...kpis,
      'recentActivities': recentActivities,
    };
  }

  String _formatComparison(dynamic current, dynamic previous) {
    if (current == null || previous == null) return '0%';

    final difference = (current - previous).toDouble();
    final percentage = previous != 0 ? (difference / previous) * 100 : 0;

    if (difference > 0) {
      return '+${difference.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)';
    } else if (difference < 0) {
      return '${difference.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)';
    } else {
      return '0 (0%)';
    }
  }

  String _formatTimeAgo(String timestamp) {
    final date = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours}h';
    } else {
      return 'Il y a ${difference.inMinutes}m';
    }
  }

  Widget _buildAdCard(String imagePath, String title) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, bool isActive) {
    return ElevatedButton(
      onPressed: () {
        // Gérer la sélection du filtre
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? const Color(0xFFF7931A) : Colors.black,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label),
    );
  }

  Widget _buildCalendarButton() {
    return IconButton(
      icon: const Icon(Icons.calendar_today),
      onPressed: () {
        // Afficher le calendrier pour sélectionner une période personnalisée
      },
      color: Colors.orange,
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return ElevatedButton.icon(
      onPressed: () {
        // Gérer l'action rapide
      },
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, String user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFFFFFFFF),
      child: ListTile(
        leading: const Icon(Icons.circle, size: 12),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 4),
            Text(
              '$time par $user',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

void _showSuccessAnimation(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Lottie.asset(
          'assets/bien_joue_lottie.json',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
          onLoaded: (composition) {
            Future.delayed(composition.duration, () {
              Navigator.of(context).pop();
            });
          },
        ),
      );
    },
  );
}
