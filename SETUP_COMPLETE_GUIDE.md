# Guide Complet de Configuration WillBank

## 📋 Vue d'Ensemble

Ce guide vous accompagne pas à pas pour configurer et démarrer l'application WillBank complète avec authentification.

## ✅ Prérequis

- ✅ MySQL 8.0 installé et démarré
- ✅ Java JDK 21 installé
- ✅ Maven installé
- ✅ Node.js et npm installés
- ✅ Angular CLI installé

## 🚀 Configuration en 4 Étapes

### Étape 1: Configuration de la Base de Données

#### 1.1 Créer les bases de données

```cmd
cd database
EXECUTE_ME.bat
```

Entrez le mot de passe root MySQL quand demandé.

#### 1.2 Configurer l'authentification (IMPORTANT!)

```powershell
.\EXECUTE-AUTH-SETUP.ps1
```

Ou :

```cmd
EXECUTE-AUTH-SETUP.bat
```

Ce script va :
- ✅ Ajouter les colonnes `password` et `role` à la table `clients`
- ✅ Créer 3 utilisateurs de test avec le mot de passe `password123`

**Utilisateurs créés :**
- `jean.dupont@example.com` (CLIENT)
- `marie.martin@example.com` (CLIENT)
- `admin@willbank.com` (ADMIN)

### Étape 2: Démarrer les Services Backend

```powershell
.\start-services-clean.ps1
```

Ce script va démarrer dans l'ordre :
1. Eureka Server (port 8761) - 30 secondes
2. Client Service (port 8084) - 15 secondes
3. Account Service (port 8081) - 15 secondes
4. Transaction Service (port 8082) - 15 secondes
5. Gateway Service (port 8080) - 15 secondes

**Temps total : ~2 minutes**

### Étape 3: Vérifier les Services

#### 3.1 Vérifier Eureka

Ouvrez http://localhost:8761

Vous devriez voir tous les services enregistrés :
- CLIENT-SERVICE
- ACCOUNT-SERVICE
- TRANSACTION-SERVICE
- GATEWAY-SERVICE

#### 3.2 Tester l'authentification

```powershell
curl.exe -X POST http://localhost:8080/api/auth/login `
  -H "Content-Type: application/json" `
  --data "@test-login.json"
```

Vous devriez recevoir un token JWT.

### Étape 4: Démarrer le Frontend

```powershell
cd Frontend
npm install
npm start
```

Le frontend sera accessible sur http://localhost:4200

## 🎯 Test de l'Application

### 1. Connexion en tant que Client

1. Ouvrez http://localhost:4200/login
2. Connectez-vous avec :
   - Email: `jean.dupont@example.com`
   - Password: `password123`
3. Vous serez redirigé vers le dashboard client

### 2. Connexion en tant qu'Admin

1. Déconnectez-vous
2. Connectez-vous avec :
   - Email: `admin@willbank.com`
   - Password: `password123`
3. Vous serez redirigé vers le dashboard admin

## 📊 Architecture des Ports

| Service | Port | URL |
|---------|------|-----|
| Eureka Server | 8761 | http://localhost:8761 |
| Gateway Service | 8080 | http://localhost:8080 |
| Account Service | 8081 | http://localhost:8081 |
| Transaction Service | 8082 | http://localhost:8082 |
| Client Service | 8084 | http://localhost:8084 |
| Frontend Angular | 4200 | http://localhost:4200 |

## 🔐 Authentification et Sécurité

### Flux d'Authentification

1. L'utilisateur se connecte via le frontend
2. Le frontend envoie les credentials au Gateway (port 8080)
3. Le Gateway route vers le Client Service (port 8084)
4. Le Client Service vérifie les credentials et génère un JWT
5. Le JWT est retourné au frontend
6. Le frontend stocke le JWT dans localStorage
7. Toutes les requêtes suivantes incluent le JWT dans le header Authorization

### Structure du JWT

Le token JWT contient :
- `userId` : ID du client
- `email` : Email du client
- `role` : Rôle (CLIENT ou ADMIN)
- `exp` : Date d'expiration (24h)

### Routes Protégées

- `/api/clients/**` : Authentification requise
- `/api/accounts/**` : Authentification requise
- `/api/transactions/**` : Authentification requise
- `/api/auth/**` : Pas d'authentification (login)

## 🛠️ Commandes Utiles

### Arrêter tous les services

```powershell
.\stop-services.ps1
```

### Redémarrer tous les services

```powershell
.\stop-services.ps1
.\start-services-clean.ps1
```

### Vérifier les ports utilisés

```powershell
netstat -ano | findstr "8080 8081 8082 8084 8761"
```

### Voir les processus Java

```powershell
Get-Process java
```

### Tuer tous les processus Java

```powershell
Get-Process java | Stop-Process -Force
```

## 🐛 Dépannage

### Problème : "Port already in use"

**Solution :**
```powershell
.\stop-services.ps1
.\start-services-clean.ps1
```

### Problème : "Email ou mot de passe incorrect"

**Solution :**
1. Vérifiez que le script d'authentification a été exécuté :
   ```powershell
   cd database
   .\EXECUTE-AUTH-SETUP.ps1
   ```
2. Vérifiez que le Client Service est démarré (port 8084)

### Problème : "Connection refused" ou erreur CORS

**Solution :**
1. Vérifiez que le Gateway est démarré (port 8080)
2. Vérifiez que tous les services sont enregistrés dans Eureka
3. Attendez 30-60 secondes après le démarrage

### Problème : Service ne démarre pas

**Solution :**
1. Vérifiez que MySQL est démarré : `Get-Service MySQL80`
2. Vérifiez les logs dans la console PowerShell du service
3. Vérifiez que le port n'est pas déjà utilisé

### Problème : Eureka ne voit pas les services

**Solution :**
1. Attendez 30-60 secondes
2. Vérifiez que Eureka est démarré en premier
3. Redémarrez le service problématique

## 📚 Documentation Complémentaire

- [AUTH_SETUP_GUIDE.md](database/AUTH_SETUP_GUIDE.md) - Configuration de l'authentification
- [AUTH_TROUBLESHOOTING.md](AUTH_TROUBLESHOOTING.md) - Dépannage de l'authentification
- [PORTS_CONFIGURATION.md](PORTS_CONFIGURATION.md) - Configuration des ports
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Dépannage général

## 🎉 Félicitations !

Si vous avez suivi toutes les étapes, vous avez maintenant :

✅ Une architecture microservices complète
✅ Un système d'authentification JWT fonctionnel
✅ Un API Gateway pour router les requêtes
✅ Un service discovery avec Eureka
✅ Un frontend Angular moderne
✅ Une gestion des rôles (CLIENT/ADMIN)
✅ Des bases de données MySQL configurées

## 🚀 Prochaines Étapes

1. Créer des comptes bancaires pour les clients
2. Effectuer des transactions
3. Tester les fonctionnalités admin
4. Personnaliser l'application selon vos besoins

## 💡 Conseils

- Utilisez toujours le Gateway (port 8080) pour les appels API
- Ne modifiez pas les clés secrètes JWT en production
- Changez les mots de passe par défaut en production
- Surveillez les logs dans les consoles PowerShell
- Consultez Eureka pour voir l'état des services

## 📞 Support

En cas de problème :
1. Consultez les fichiers de dépannage
2. Vérifiez les logs des services
3. Vérifiez que tous les prérequis sont installés
4. Redémarrez les services dans le bon ordre
