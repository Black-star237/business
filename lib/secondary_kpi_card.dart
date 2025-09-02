import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data_service.dart';

class SecondaryKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String comparison;
  final IconData icon;
  final bool isDarkMode;
  final SupabaseClient? supabaseClient;

  const SecondaryKpiCard({
    Key? key,
    required this.title,
    required this.value,
    required this.comparison,
    required this.icon,
    required this.isDarkMode,
    this.supabaseClient,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    // Debug: Afficher la couleur de fond et l'URL de l'image
    print("Couleur de fond en mode sombre: ${isDarkMode ? const Color(0XFF383C44) : Colors.white}");

    return FutureBuilder<String?>(
      future: DataService().getBackgroundImageUrl(isDarkMode ? 8 : 6),
      builder: (context, snapshot) {
        return Container(
          width: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDarkMode ? const Color(0XFF383C44) : Colors.white, // Base selon le mode
            image: snapshot.hasData && snapshot.data != null
                ? DecorationImage(
                    image: NetworkImage(snapshot.data!),
                    fit: BoxFit.cover,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: Colors.orange, size: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: comparison.contains('-') ? Colors.red : Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        comparison.replaceAll(RegExp(r'[^0-9.%-]'), ''),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
