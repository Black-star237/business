import 'package:flutter/material.dart';
import 'create_company_page.dart';
import 'data_service.dart';

class NoCompanyPage extends StatelessWidget {
  const NoCompanyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entreprises', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<String?>(
              future: DataService().getBackgroundImageUrl(4).then((url) {
                if (url != null) {
                  print("Background image URL for ID 4: $url");
                } else {
                  print("No background image found for ID 4");
                }
                return url;
              }),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Image.asset(
                    'assets/notfound_img.webp',
                    width: 300,
                    height: 300,
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return Image.asset(
                    'assets/notfound_img.webp',
                    width: 300,
                    height: 300,
                  );
                }

                return Image.network(
                  snapshot.data!,
                  width: 300,
                  height: 300,
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Pas d\'entreprise',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Vous n\'êtes associé à aucune entreprise.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
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
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('Créer une entreprise'),
            ),
          ],
        ),
      ),
    );
  }
}