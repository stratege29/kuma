# Kuma - Application Flutter de Contes Africains

Kuma est une application Flutter éducative qui propose un voyage littéraire à travers l'Afrique avec des histoires débloquables par pays. L'application offre une expérience gamifiée d'apprentissage des contes africains traditionnels.

## Fonctionnalités Principales

### 🌍 Voyage à travers l'Afrique
- Carte interactive de l'Afrique avec story cards positionnées
- Progression circulaire à travers 54 pays africains
- Animation d'entrée sur le pays de départ sélectionné
- Déblocage progressif des histoires selon les résultats aux quiz

### 📚 Expérience de Lecture
- **Mode Lecture** : Texte scrollable avec contrôles (taille police, mode nuit)
- **Mode Écoute** : Player audio avec contrôles avancés et animations
- Navigation automatique vers le quiz après lecture/écoute

### 🎯 Système de Quiz
- 3 questions obligatoires par histoire
- Score minimum de 2/3 pour débloquer le pays suivant
- Feedback immédiat et explications pédagogiques
- Gestion de la progression avec sauvegarde

### 👨‍👩‍👧‍👦 Gestion Multi-Profils
- Support jusqu'à 5 profils enfants par compte parent
- Progression individuelle par enfant
- Configuration personnalisée (âge, avatar, objectifs)

## Architecture Technique

### Clean Architecture / MVVM
- **Features** : Onboarding, Home, Story, Quiz, Auth
- **Layers** : Presentation (Bloc), Domain (Entities, UseCases), Data (Repository, DataSources)
- **Dependency Injection** : GetIt
- **State Management** : Flutter Bloc

### Packages Principaux
```yaml
flutter_bloc: ^8.1.3          # State management
get_it: ^7.6.4                # Dependency injection  
go_router: ^12.1.3            # Navigation
freezed: ^2.4.6               # Data models immutables
firebase_core: ^2.24.2        # Backend Firebase
hive: ^2.2.3                  # Cache local
google_fonts: ^6.1.0          # Typography
audioplayers: ^5.2.1          # Lecture audio
```

### Structure du Projet
```
lib/
├── core/
│   ├── constants/           # Constantes (pays, routes, etc.)
│   ├── di/                  # Injection de dépendances
│   ├── error/               # Gestion d'erreurs
│   ├── theme/               # Thème Material 3
│   └── utils/               # Utilitaires (router, etc.)
├── features/
│   ├── onboarding/          # Écrans d'onboarding (7 étapes)
│   ├── home/                # Page d'accueil avec carte
│   ├── story/               # Pages lecture/écoute
│   ├── quiz/                # Système de quiz
│   └── auth/                # Authentification Firebase
└── shared/
    ├── domain/entities/     # Modèles de données (Story, User)
    ├── data/                # Services de données mock
    └── presentation/        # Widgets réutilisables
```

## Flow Utilisateur Principal

1. **Splash** → Animation avec citation inspirante
2. **Onboarding** → 7 étapes de configuration (type utilisateur, enfants, objectifs, pays de départ)
3. **Carte** → Animation zoom sur pays de départ, première story active
4. **Story Selection** → Bottom sheet avec options "Lire" ou "Écouter"
5. **Lecture/Écoute** → Consommation du contenu avec navigation auto vers quiz
6. **Quiz** → 3 questions obligatoires avec feedback
7. **Résultat** :
   - ≥ 2/3 : Animation succès + déblocage pays suivant
   - < 2/3 : Options "Réessayer" ou "Relire"
8. **Progression** → Retour carte avec nouvelle story débloquée

## Configuration pour iOS

### Prérequis
- Flutter SDK ≥ 3.0.0
- Xcode (pour iOS)
- CocoaPods installé

### Installation
```bash
# Cloner le projet
git clone <repository-url>
cd kuma

# Installer les dépendances
flutter pub get

# Générer les fichiers Freezed
flutter packages pub run build_runner build

# Lancer sur simulateur iOS
flutter run
```

### Configuration Firebase
Remplacer les placeholders dans `main.dart` :
```dart
final firebaseOptions = FirebaseOptions(
  apiKey: "YOUR_API_KEY",
  appId: "YOUR_APP_ID",
  messagingSenderId: "YOUR_SENDER_ID", 
  projectId: "YOUR_PROJECT_ID",
);
```

## Données de Test

L'application inclut 20 histoires mock pour les 10 premiers pays :
- Côte d'Ivoire, Ghana, Nigeria, Cameroun, Kenya
- Éthiopie, Égypte, Maroc, Sénégal, Afrique du Sud

Chaque histoire comprend :
- Titre authentique africain
- Contenu 300-500 mots en français
- 3 questions quiz avec explications
- Valeurs transmises (Courage, Sagesse, etc.)
- Métadonnées complètes

## Design UI

### Thème Material 3
- **Couleurs principales** : Orange (#FF6B35), Vert (#2ECC71), Marron (#8B4513)
- **Polices** : Comfortaa (titres), Roboto (texte)
- **Design** : Cards arrondies, animations fluides, adaptation iOS

### Animations
- Transitions de page fluides
- Pulsation des story cards actives
- Animations de progression quiz
- Effets visuels lors des succès

## Tests

### Tests Unitaires
```bash
flutter test
```

### Test iOS Simulator
```bash
# Lister les simulateurs disponibles
xcrun simctl list devices

# Lancer sur simulateur spécifique
flutter run -d "iPhone 15 Pro"
```

## Roadmap

### Phase 1 (Actuelle) ✅
- [x] Architecture Clean + MVVM
- [x] Onboarding complet (7 écrans)
- [x] Carte interactive avec story cards
- [x] Flow lecture/écoute → quiz → progression
- [x] 20 histoires mock avec quiz

### Phase 2 (Prochaine)
- [ ] Intégration Firebase complète
- [ ] Synchronisation multi-device
- [ ] Mode hors ligne avancé
- [ ] Statistiques de progression
- [ ] Système de achievements

### Phase 3 (Future)
- [ ] Contenu audio réel
- [ ] Illustrations personnalisées
- [ ] Mode multijoueur famille
- [ ] Création de contes par les utilisateurs

## Contribution

Ce projet suit les conventions Flutter et utilise l'architecture Clean. 
Les contributions sont les bienvenues !

### Standards de Code
- Null safety obligatoire
- Commentaires en français
- Tests unitaires pour les use cases
- Documentation des APIs publiques

## License

Ce projet éducatif est destiné à promouvoir la culture africaine.
Tous droits réservés pour le contenu des contes traditionnels.