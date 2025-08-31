import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'create_company_page.dart';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'loading_indicator.dart';

class CompaniesPage extends StatefulWidget {
  const CompaniesPage({super.key});

  @override
  _CompaniesPageState createState() => _CompaniesPageState();
}

class _CompaniesPageState extends State<CompaniesPage> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _companies = [];
  List<Map<String, dynamic>> _filteredCompanies = [];
  String? _errorMessage;
  bool _isLoading = true;
  bool _isSwitchingCompany = false;

  @override
  void initState() {
    super.initState();
    _fetchCompanies();
  }

  Future<void> _fetchCompanies() async {
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

      final response = await supabase
          .from('company_members')
          .select('''
            companies!inner(id, name, logo_url, banner_url),
            role
          ''')
          .eq('user_id', user.id)
          .eq('is_active', true);

      if (response.isEmpty) {
        setState(() {
          _companies = [];
          _filteredCompanies = [];
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _companies = response.map((item) {
          return {
            'id': item['companies']['id'],
            'name': item['companies']['name'],
            'logo_url': item['companies']['logo_url'],
            'banner_url': item['companies']['banner_url'],
            'role': item['role'],
          };
        }).toList();
        _filteredCompanies = _companies;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Erreur: ${error.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterCompanies(String query) {
    setState(() {
      _filteredCompanies = _companies
          .where((company) =>
              company['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _switchCompany(Map<String, dynamic> company) async {
    setState(() {
      _isSwitchingCompany = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_company_id', company['id']);
      await prefs.setString('active_company_name', company['name']);
      await prefs.setString('active_company_logo_url', company['logo_url']);
      await prefs.setString('active_company_banner_url', company['banner_url']);

      // Navigate to main page with new company data
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserPage(
            user: Supabase.instance.client.auth.currentUser!,
            fullName: '${Supabase.instance.client.auth.currentUser?.userMetadata?['first_name'] ?? ''} ${Supabase.instance.client.auth.currentUser?.userMetadata?['last_name'] ?? ''}',
            activeCompanyName: company['name'],
            activeCompanyLogoUrl: company['logo_url'],
            activeCompanyBannerUrl: company['banner_url'],
          ),
        ),
      );
    } catch (error) {
      setState(() {
        _errorMessage = 'Erreur: ${error.toString()}';
        _isSwitchingCompany = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entreprises', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF222630), // Dark background
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/entreprise.webp',
              fit: BoxFit.cover,
            ),
          ),
          // Loading animation
          if (_isLoading)
            Center(
              child: LoadingIndicator(showOverlay: false),
            ),
          // Content
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Rechercher une entreprise',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: _filterCompanies,
                  ),
                  const SizedBox(height: 16),

                  // Error message
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Companies list
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredCompanies.length,
                      itemBuilder: (context, index) {
                        final company = _filteredCompanies[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Color(0xFFFFFFFF), // White cards
                          child: ListTile(
                            leading: company['logo_url'] != null
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(company['logo_url']),
                                  )
                                : CircleAvatar(
                                    child: Text(company['name'][0]),
                                  ),
                            title: Text(company['name']),
                            subtitle: Text('Rôle: ${company['role']}'),
                            onTap: _isSwitchingCompany ? null : () => _switchCompany(company),
                          ),
                        );
                      },
                    ),
                  ),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateCompanyPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF222630), // Dark background
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Créer'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Rejoindre button (inerte pour le moment)
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF222630), // Dark background
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Rejoindre'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (_isSwitchingCompany)
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