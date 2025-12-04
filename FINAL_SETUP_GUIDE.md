# 🎉 WillBank - Guide de configuration finale

## ✅ Ce qui a été implémenté

### 1. Gateway Service (Port 8080)
- API Gateway avec Spring Cloud Gateway
- Authentification JWT
- Routage vers tous les microservices
- Gestion CORS

### 2. Authentification complète
- Login avec email/password
- Tokens JWT (expiration 24h)
- Gestion des rôles (CLIENT, ADMIN)
- Sécurisation de toutes les routes

### 3. Frontend Angular
- Page de login moderne
- Interface client (dashboard, transactions, comptes)
- Interface admin (gestion complète)
- Guards et intercepteurs
- Redirection automatique selon le rôle

## 🚀 Étapes de configuration

### Étape 1 : Mettre à jour MySQL

Exécutez le script SQL pour ajouter les colonnes d'authentification :

```sql
-- Dans MySQL Workbench ou ligne de commande MySQL
SOURCE database/update-clients-auth.sql;
```

Ou manuellement :

```sql
USE willbank_client_db;

-- Ajouter les colonnes
ALTER TABLE clients ADD COLUMN password VARCHAR(255);
ALTER TABLE clients ADD COLUMN role VARCHAR(20) DEFAULT 'CLIENT';

-- Mettre à jour les clients existants (mot de passe: password123)
UPDATE clients SET password = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.rsS3/r/7HNtBJFgEy2' WHERE password IS NULL;
UPDATE clients SET role = 'CLIENT' WHERE role IS NULL;

-- Créer l'administrateur
INSERT INTO clients (first_name, last_name, email, phone_number, address, city, postal_code, country, date_of_birth, national_id, status, kyc_status, password, role, created_at, updated_at) 
VALUES ('Admin', 'WillBank', 'admin@willbank.com', '+33600000000', '1 Place de la Banque', 'Paris', '75001', 'France', '1980-01-01', 'ADMIN000000001', 'ACTIVE', 'VERIFIED', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.rsS3/r/7HNtBJFgEy2', 'ADMIN', NOW(), NOW());
```

### Étape 2 : Compiler les services

```powershell
# Client Service (déjà compilé)
cd Client_service
.\mvnw.cmd clean package -DskipTests

# Gateway Service (déjà compilé)
cd ..\gateway_service
.\mvnw.cmd clean package -DskipTests
```

### Étape 3 : Démarrer les services

**Ordre de démarrage important** :

1. **Eureka Server** (port 8761)
```powershell
cd Eureka-Service\Eureka-Service
.\mvnw.cmd spring-boot:run
```

2. **Client Service** (port 8084)
```powershell
cd Client_service
.\mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=mysql
```

3. **Account Service** (port 8081)
```powershell
cd account_service
.\mvnw.cmd spring-boot:run
```

4. **Transaction Service** (port 8082)
```powershell
cd transaction_service
.\mvnw.cmd spring-boot:run
```

5. **Gateway Service** (port 8080)
```powershell
cd gateway_service
.\mvnw.cmd spring-boot:run
```

6. **Frontend Angular** (port 4200)
```powershell
cd Frontend
npm start
```

### Étape 4 : Accéder à l'application

Ouvrez votre navigateur sur : **http://localhost:4200**

## 👤 Comptes de test

### Client
- **Email** : jean.dupont@example.com
- **Mot de passe** : password123
- **Rôle** : CLIENT
- **Accès** : Dashboard personnel, transactions, comptes

### Administrateur
- **Email** : admin@willbank.com
- **Mot de passe** : password123
- **Rôle** : ADMIN
- **Accès** : Interface d'administration complète

## 🔄 Architecture finale

```
Frontend Angular (Port 4200)
    ↓
Gateway Service (Port 8080) - JWT Authentication
    ↓
    ├── Client Service (Port 8084) → willbank_client_db
    ├── Account Service (Port 8081) → willbank_account_db
    └── Transaction Service (Port 8082) → willbank_transaction_db
    
Eureka Server (Port 8761) - Service Discovery
```

## 📋 Checklist de vérification

- [ ] MySQL est démarré
- [ ] Les 3 bases de données existent (willbank_client_db, willbank_account_db, willbank_transaction_db)
- [ ] Les colonnes password et role sont ajoutées à la table clients
- [ ] L'administrateur est créé (admin@willbank.com)
- [ ] Eureka Server est démarré (http://localhost:8761)
- [ ] Client Service est enregistré dans Eureka
- [ ] Account Service est enregistré dans Eureka
- [ ] Transaction Service est enregistré dans Eureka
- [ ] Gateway Service est démarré
- [ ] Frontend Angular est démarré
- [ ] La page de login s'affiche (http://localhost:4200)

## 🧪 Tests

### Test 1 : Login Client
1. Aller sur http://localhost:4200
2. Se connecter avec jean.dupont@example.com / password123
3. Vérifier la redirection vers /dashboard
4. Vérifier l'affichage des comptes et transactions

### Test 2 : Login Admin
1. Se déconnecter
2. Se connecter avec admin@willbank.com / password123
3. Vérifier la redirection vers /admin
4. Vérifier l'accès aux pages admin (clients, comptes, transactions)

### Test 3 : Transactions
1. Se connecter en tant que client
2. Aller sur Transactions
3. Effectuer un dépôt de 100 EUR
4. Vérifier la mise à jour du solde

### Test 4 : API Gateway
```powershell
# Test sans authentification (doit échouer)
Invoke-RestMethod -Uri "http://localhost:8080/api/clients" -Method Get

# Test avec authentification
$loginBody = @{
    email = "jean.dupont@example.com"
    password = "password123"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method Post -ContentType "application/json" -Body $loginBody

$token = $response.token

# Utiliser le token
$headers = @{
    Authorization = "Bearer $token"
}

Invoke-RestMethod -Uri "http://localhost:8080/api/clients" -Method Get -Headers $headers
```

## 🎯 Fonctionnalités disponibles

### Interface Client
- ✅ Login/Logout
- ✅ Dashboard avec cartes de comptes
- ✅ Transactions récentes
- ✅ Dépôt d'argent
- ✅ Retrait d'argent
- ✅ Virement entre comptes
- ✅ Création de nouveau compte
- ✅ Historique des transactions

### Interface Admin
- ✅ Login/Logout
- ✅ Dashboard avec statistiques globales
- ✅ Liste de tous les clients
- ✅ Filtrage et recherche de clients
- ✅ Détails complets des clients
- ✅ Liste de tous les comptes
- ✅ Solde total de la plateforme
- ✅ Liste de toutes les transactions
- ✅ Filtrage par type et statut

## 🔒 Sécurité

- Mots de passe hashés avec BCrypt
- Tokens JWT signés
- Routes protégées par authentification
- Séparation des rôles CLIENT/ADMIN
- CORS configuré
- Headers sécurisés

## 📝 Ports utilisés

| Service | Port | URL |
|---------|------|-----|
| Frontend | 4200 | http://localhost:4200 |
| Gateway | 8080 | http://localhost:8080 |
| Account Service | 8081 | http://localhost:8081 |
| Transaction Service | 8082 | http://localhost:8082 |
| Client Service | 8084 | http://localhost:8084 |
| Eureka Server | 8761 | http://localhost:8761 |
| MySQL | 3306 | localhost:3306 |

## 🐛 Dépannage

### Erreur "Invalid email or password"
- Vérifiez que le script SQL a été exécuté
- Vérifiez que le mot de passe est "password123"
- Vérifiez que le Client Service est démarré

### Erreur 401 Unauthorized
- Vérifiez que le Gateway Service est démarré
- Vérifiez que le token est valide
- Vérifiez les logs du Gateway

### Erreur CORS
- Vérifiez la configuration CORS dans le Gateway
- Vérifiez que le frontend utilise le port 4200

### Services non enregistrés dans Eureka
- Attendez 30 secondes après le démarrage
- Vérifiez les logs des services
- Vérifiez que Eureka est accessible

## 📚 Documentation

- `AUTH_IMPLEMENTATION.md` - Détails de l'authentification
- `ADMIN_GUIDE.md` - Guide de l'interface admin
- `FRONTEND_COMPLETE_GUIDE.md` - Guide complet du frontend
- `QUICK_START.md` - Guide de démarrage rapide

## 🎉 Félicitations !

Votre application WillBank est maintenant complète avec :
- ✅ Architecture microservices
- ✅ Service Discovery (Eureka)
- ✅ API Gateway avec authentification JWT
- ✅ 3 bases de données MySQL séparées
- ✅ Frontend Angular moderne
- ✅ Interface client et admin
- ✅ Gestion des rôles et permissions
- ✅ Transactions bancaires complètes

**L'application est prête à être utilisée !** 🚀
