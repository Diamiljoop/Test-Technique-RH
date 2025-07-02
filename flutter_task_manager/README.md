# 📱 Task Manager Flutter App

Application Flutter pour consommer les APIs Django Task Manager.

## 🚀 Fonctionnalités

- ✅ **Authentification JWT** avec Django
- 📋 **Gestion des tâches** (CRUD complet)
- 📁 **Gestion des projets** (CRUD complet)
- 👥 **Gestion des utilisateurs** (CRUD complet)
- 🎨 **Interface moderne** avec Material Design 3
- 📱 **Responsive** pour mobile et tablette

## 🛠️ Installation

### Prérequis
- Flutter SDK (version 3.0.0 ou supérieure)
- Android Studio / VS Code
- Serveur Django Task Manager en cours d'exécution

### Étapes d'installation

1. **Cloner le projet**
   ```bash
   git clone <repository-url>
   cd flutter_task_manager
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Configurer l'URL de l'API**
   
   Modifiez le fichier `lib/services/api_service.dart` selon votre environnement :
   
   ```dart
   // Pour l'émulateur Android
   static const String baseUrl = 'http://10.0.2.2:8000/api';
   
   // Pour iOS
   static const String baseUrl = 'http://localhost:8000/api';
   
   // Pour appareil physique (remplacez par votre IP)
   static const String baseUrl = 'http://192.168.1.XXX:8000/api';
   ```

4. **Lancer l'application**
   ```bash
   flutter run
   ```

## 📱 Utilisation

### 1. Connexion
- Utilisez vos identifiants Django (superuser recommandé)
- L'application stocke automatiquement le token JWT

### 2. Gestion des tâches
- **Voir toutes les tâches** : Onglet "Tâches"
- **Créer une tâche** : Bouton "+" 
- **Modifier une tâche** : Tap sur une tâche
- **Supprimer une tâche** : Swipe ou bouton supprimer

### 3. Gestion des projets
- **Voir tous les projets** : Onglet "Projets"
- **Créer un projet** : Bouton "+"
- **Modifier un projet** : Tap sur un projet
- **Supprimer un projet** : Bouton supprimer

### 4. Gestion des utilisateurs
- **Voir tous les utilisateurs** : Onglet "Utilisateurs"
- **Créer un utilisateur** : Bouton "+"
- **Filtrer par rôle** : Gestionnaire/Utilisateur

## 🏗️ Architecture

```
lib/
├── main.dart                 # Point d'entrée
├── models/                   # Modèles de données
│   ├── user.dart
│   ├── project.dart
│   └── task.dart
├── providers/                # Gestion d'état (Provider)
│   ├── auth_provider.dart
│   ├── task_provider.dart
│   ├── project_provider.dart
│   └── user_provider.dart
├── screens/                  # Écrans de l'application
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── tasks_screen.dart
│   ├── projects_screen.dart
│   └── users_screen.dart
└── services/                 # Services API
    └── api_service.dart
```

## 🔧 Configuration

### Variables d'environnement
- `baseUrl` : URL de votre API Django
- `timeout` : Timeout des requêtes HTTP

### Permissions Android
Ajoutez dans `android/app/src/main/AndroidManifest.xml` :
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## 🐛 Dépannage

### Erreur de connexion
- Vérifiez que le serveur Django est démarré
- Vérifiez l'URL dans `api_service.dart`
- Vérifiez vos identifiants

### Erreur CORS
- Ajoutez `django-cors-headers` à votre projet Django
- Configurez les origines autorisées

### Erreur de certificat (HTTPS)
- Pour le développement, utilisez HTTP
- Pour la production, configurez les certificats SSL

## 📦 Déploiement

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contribution

1. Fork le projet
2. Créez une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 📞 Support

Pour toute question ou problème :
- Ouvrez une issue sur GitHub
- Contactez l'équipe de développement

---

**Développé avec ❤️ pour la gestion de tâches** 