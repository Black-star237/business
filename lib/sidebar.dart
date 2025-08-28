import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final String? companyName;
  final String? companyLogoUrl;
  final String? companyBannerUrl;

  const Sidebar({
    super.key,
    this.companyName,
    this.companyLogoUrl,
    this.companyBannerUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Section en haut avec la bannière et le logo de l'entreprise
            Stack(
              children: [
                // Bannière de l'entreprise
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: companyBannerUrl != null
                            ? DecorationImage(
                                image: NetworkImage(companyBannerUrl!),
                                fit: BoxFit.cover,
                                onError: (exception, stackTrace) {
                                  print('Erreur de chargement de la bannière: $exception');
                                },
                              )
                            : null,
                  ),
                ),
                // Contenu superposé sur la bannière
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    child: Column(
                      children: [
                        // Logo de l'entreprise
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          backgroundImage: companyLogoUrl != null
                              ? NetworkImage(companyLogoUrl!)
                              : const AssetImage('assets/logo.jpg') as ImageProvider,
                          child: companyLogoUrl == null
                              ? const Icon(Icons.business, size: 30, color: Colors.black)
                              : null,
                        ),
                        const SizedBox(height: 8),
                        // Nom de l'entreprise
                        Text(
                          companyName ?? 'Fluxiabiz',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'bayer_martin@yahoo.com',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Liste des éléments de menu
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.home, color: Colors.black),
                    title: const Text('Accueil', style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.collections, color: Colors.black),
                    title: const Text('Nouveautés', style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.star, color: Colors.black),
                    title: const Text('Meilleures offres', style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications, color: Colors.black),
                    title: const Text('Notifications', style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.black),
                    title: const Text('Paramètres', style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.black),
                    title: const Text('Déconnexion', style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}