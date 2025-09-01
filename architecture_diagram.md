# Diagramme d'Architecture de Fluxiabiz

```mermaid
graph TD
    A[Fluxiabiz] --> B[AuthChecker]
    B -->|Non authentifié| C[WelcomePage]
    B -->|Authentifié| D[MainAppContent]
    C --> E[AuthPage]
    E -->|Connexion| F[NoCompanyPage]
    E -->|Inscription| F
    F --> G[CreateCompanyPage]
    G --> H[UserPage]
    D -->|A des entreprises| H
    D -->|Pas d'entreprises| F
    H --> I[CompaniesPage]
    I -->|Sélection| H
    I -->|Création| G

    subgraph "Pages Principales"
        C
        E
        F
        G
        H
        I
    end

    subgraph "Composants UI"
        J[Navbar]
        K[Sidebar]
        L[MainRevenueCard]
        M[SecondaryKpiCard]
        N[LoadingIndicator]
    end

    H --> J
    H --> K
    H --> L
    H --> M
    H --> N

    subgraph "Services"
        O[DataService]
        P[Supabase]
    end

    O --> P
    H --> O
    G --> O
    I --> O
    F --> O
    E --> O
    D --> O

    subgraph "Données"
        Q[companies]
        R[company_members]
        S[profiles]
        T[sales]
        U[clients]
        V[inventory_alerts]
        W[stock_movements]
        X[app_assets]
    end

    P --> Q
    P --> R
    P --> S
    P --> T
    P --> U
    P --> V
    P --> W
    P --> X

    subgraph "Stockage"
        Y[company-logos]
        Z[company-banners]
    end

    P --> Y
    P --> Z
```

## Légende

- **Pages Principales** : Les différentes pages de l'application
- **Composants UI** : Composants réutilisables de l'interface utilisateur
- **Services** : Services pour interagir avec le backend
- **Données** : Tables de la base de données Supabase
- **Stockage** : Stockage d'objets pour les images

## Flux Principal

1. **Authentification** : L'utilisateur commence sur `AuthChecker` qui vérifie l'état d'authentification
2. **Connexion/Inscription** : Si non authentifié, l'utilisateur passe par `WelcomePage` → `AuthPage`
3. **Gestion d'entreprise** : Après authentification, l'utilisateur est dirigé vers :
   - `NoCompanyPage` s'il n'a pas d'entreprise (puis `CreateCompanyPage`)
   - `UserPage` s'il a une entreprise active
4. **Navigation** : L'utilisateur peut naviguer entre les entreprises via `CompaniesPage`

## Architecture Technique

- **Frontend** : Flutter avec des composants réutilisables
- **Backend** : Supabase (authentification, base de données, stockage)
- **Services** : `DataService` centralise les appels à Supabase
- **Données** : Tables relationnelles avec des relations entre entreprises, utilisateurs et activités