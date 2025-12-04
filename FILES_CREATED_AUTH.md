# Fichiers Créés pour l'Authentification

## 📁 Scripts de Base de Données

### Scripts SQL
- `database/alter-clients-table.sql` - Modifie la structure de la table clients
- `database/setup-auth-complete.sql` - Script complet de configuration (RECOMMANDÉ)
- `database/create-test-user.sql` - Crée uniquement les utilisateurs de test

### Scripts d'Exécution
- `database/EXECUTE-AUTH-SETUP.ps1` - Script PowerShell pour exécuter la configuration (RECOMMANDÉ)
- `database/EXECUTE-AUTH-SETUP.bat` - Script Batch pour exécuter la configuration
- `database/execute-test-user.ps1` - Script PowerShell pour créer les utilisateurs
- `database/execute-test-user.bat` - Script Batch pour créer les utilisateurs

## 📁 Scripts de Gestion des Services

- `start-services-clean.ps1` - Démarre tous les services dans le bon ordre
- `stop-services.ps1` - Arrête tous les services
- `test-login.json` - Fichier JSON de test pour curl

## 📁 Documentation

### Guides Principaux
- `START_HERE.md` - Guide de démarrage ultra-rapide (3 commandes)
- `SETUP_COMPLETE_GUIDE.md` - Guide complet de configuration
- `database/AUTH_SETUP_GUIDE.md` - Guide détaillé de configuration de l'authentification

### Dépannage
- `AUTH_TROUBLESHOOTING.md` - Guide de dépannage de l'authentification
- `PORTS_CONFIGURATION.md` - Configuration et gestion des ports

### Fichiers Existants Modifiés
- `database/README.md` - Ajout d'une section sur l'authentification
- `Client_service/src/main/resources/application.yaml` - Ajout des propriétés JWT

## 🎯 Utilisation Recommandée

### Configuration Initiale

1. **Créer les bases de données** :
   ```cmd
   cd database
   EXECUTE_ME.bat
   ```

2. **Configurer l'authentification** :
   ```cmd
   EXECUTE-AUTH-SETUP.bat
   ```
   OU
   ```powershell
   .\EXECUTE-AUTH-SETUP.ps1
   ```

### Démarrage Quotidien

1. **Démarrer les services** :
   ```powershell
   .\start-services-clean.ps1
   ```

2. **Arrêter les services** :
   ```powershell
   .\stop-services.ps1
   ```

## 📊 Structure des Fichiers

```
WillBank_MicroService/
├── START_HERE.md                    ⭐ Commencer ici
├── SETUP_COMPLETE_GUIDE.md          📖 Guide complet
├── AUTH_TROUBLESHOOTING.md          🐛 Dépannage auth
├── PORTS_CONFIGURATION.md           🔌 Configuration ports
├── FILES_CREATED_AUTH.md            📋 Ce fichier
├── start-services-clean.ps1         🚀 Démarrer services
├── stop-services.ps1                🛑 Arrêter services
├── test-login.json                  🧪 Test curl
│
└── database/
    ├── AUTH_SETUP_GUIDE.md          📖 Guide auth détaillé
    ├── setup-auth-complete.sql      ⭐ Script SQL principal
    ├── alter-clients-table.sql      🔧 Modifier structure
    ├── create-test-user.sql         👤 Créer utilisateurs
    ├── EXECUTE-AUTH-SETUP.ps1       ⭐ Exécution PowerShell
    ├── EXECUTE-AUTH-SETUP.bat       ⭐ Exécution Batch
    ├── execute-test-user.ps1        👤 Créer users PS
    └── execute-test-user.bat        👤 Créer users Batch
```

## ✅ Checklist de Configuration

- [ ] MySQL installé et démarré
- [ ] Bases de données créées (`EXECUTE_ME.bat`)
- [ ] Authentification configurée (`EXECUTE-AUTH-SETUP.bat`)
- [ ] Services backend démarrés (`start-services-clean.ps1`)
- [ ] Frontend démarré (`npm start` dans Frontend/)
- [ ] Test de connexion réussi

## 🔐 Credentials par Défaut

Tous les utilisateurs créés ont le mot de passe : **password123**

| Email | Rôle | Utilisation |
|-------|------|-------------|
| jean.dupont@example.com | CLIENT | Tests utilisateur normal |
| marie.martin@example.com | CLIENT | Tests utilisateur normal |
| admin@willbank.com | ADMIN | Tests administrateur |

## 🎯 Prochaines Étapes

Après la configuration :

1. ✅ Tester la connexion avec les credentials ci-dessus
2. ✅ Explorer le dashboard client
3. ✅ Explorer le dashboard admin
4. ✅ Créer des comptes bancaires
5. ✅ Effectuer des transactions
6. ✅ Tester les différentes fonctionnalités

## 💡 Notes Importantes

- Les scripts sont **idempotents** : ils peuvent être exécutés plusieurs fois sans problème
- Les mots de passe sont hashés avec **BCrypt** (force 10)
- Le token JWT expire après **24 heures**
- Tous les appels API doivent passer par le **Gateway** (port 8080)
- Les services doivent être démarrés dans l'**ordre** (Eureka en premier)

## 🆘 Aide

En cas de problème, consultez dans l'ordre :

1. `AUTH_TROUBLESHOOTING.md` - Problèmes d'authentification
2. `PORTS_CONFIGURATION.md` - Problèmes de ports
3. `TROUBLESHOOTING.md` - Problèmes généraux
4. Les logs dans les consoles PowerShell des services
