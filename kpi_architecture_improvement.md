# Amélioration de l'Architecture des Composants KPI

## Analyse Actuelle

Actuellement, les composants KPI sont définis dans des fichiers séparés :
- `main_revenue_card.dart` : Carte principale pour le chiffre d'affaires
- `secondary_kpi_card.dart` : Cartes secondaires pour les autres KPIs

Cependant, dans `main.dart`, ces composants sont instanciés et configurés directement dans le widget `UserPage`, avec des appels à `DataService` pour récupérer les données.

## Problèmes Identifiés

1. **Duplication de Logique** : La logique de récupération et de formatage des données KPI est dupliquée dans `main.dart`
2. **Couplage Fort** : Les composants KPI sont fortement couplés à la page principale
3. **Difficulté de Réutilisation** : Il serait difficile de réutiliser ces composants dans d'autres pages sans dupliquer la logique

## Proposition d'Amélioration

### 1. Créer un KPI Service

Créer un service dédié pour récupérer et formater les données KPI :

```dart
class KpiService {
  final DataService _dataService = DataService();

  Future<Map<String, dynamic>> getKpiData({
    required String companyId,
    required DateTime startDate,
    required DateTime endDate,
    required String previousStartDate,
    required String previousEndDate,
  }) async {
    return await _dataService.getKpis(
      companyId: companyId,
      startDate: startDate,
      endDate: endDate,
      previousStartDate: previousStartDate,
      previousEndDate: previousEndDate,
    );
  }

  String formatComparison(dynamic current, dynamic previous) {
    // Logique de formatage de la comparaison
  }
}
```

### 2. Modifier les Composants KPI

Faire en sorte que les composants KPI acceptent des données déjà formatées :

```dart
class MainRevenueCard extends StatelessWidget {
  final String revenue;
  final String comparison;
  final bool isDarkMode;

  const MainRevenueCard({
    required this.revenue,
    required this.comparison,
    required this.isDarkMode,
  });

  // ... reste du code inchangé
}
```

### 3. Utiliser un KPI Controller

Créer un widget controller qui récupère les données et les passe aux composants :

```dart
class KpiDashboard extends StatelessWidget {
  final String companyId;
  final bool isDarkMode;

  const KpiDashboard({
    required this.companyId,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadKpiData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final data = snapshot.data ?? {};

        return Column(
          children: [
            MainRevenueCard(
              revenue: data['revenue']['current'].toString(),
              comparison: _formatComparison(
                data['revenue']['current'],
                data['revenue']['previous'],
              ),
              isDarkMode: isDarkMode,
            ),
            // Autres cartes KPI...
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadKpiData() async {
    final kpiService = KpiService();
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month + 1, 0);
    final previousStartDate = DateTime(now.year, now.month - 1, 1);
    final previousEndDate = DateTime(now.year, now.month, 0);

    return await kpiService.getKpiData(
      companyId: companyId,
      startDate: startDate,
      endDate: endDate,
      previousStartDate: previousStartDate.toIso8601String(),
      previousEndDate: previousEndDate.toIso8601String(),
    );
  }

  String _formatComparison(dynamic current, dynamic previous) {
    // Logique de formatage de la comparaison
  }
}
```

### 4. Utiliser le KPI Dashboard dans la Page Principale

Dans `main.dart`, remplacer la logique KPI par le nouveau widget :

```dart
KpiDashboard(
  companyId: Supabase.instance.client.auth.currentUser!.id,
  isDarkMode: _isDarkMode,
)
```

## Avantages de cette Approche

1. **Séparation des Préoccupations** : La logique de récupération des données est séparée de l'affichage
2. **Réutilisabilité** : Les composants KPI peuvent être facilement réutilisés dans d'autres pages
3. **Maintenabilité** : Le code est plus facile à maintenir et à tester
4. **Extensibilité** : Il est plus facile d'ajouter de nouveaux types de KPI ou de modifier la logique existante

## Conclusion

Cette amélioration permettrait de mieux structurer le code des composants KPI, en les rendant plus modulaires et réutilisables. Cela répondrait à la suggestion de l'utilisateur de développer les cartes KPI dans leurs propres fichiers et de les importer là où on le souhaite sur la page principale.