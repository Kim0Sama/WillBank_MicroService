# 🔐 WillBank - Système d'authentification

## ✅ Ce qui a été implémenté

### 1. Gateway Service (Port 8080)
Un nouveau microservice Spring Cloud Gateway qui :
- Route toutes les requêtes vers les services appropriés
- Valide les tokens JWT
- Ajoute les informations utilisateur aux headers pour les services downstream
- Gère les CORS

### 2. Authentification JWT
- Génération de tokens JWT lors de la connexion
- Validation des tokens sur chaque requête
- Expiration configurable (24h par défaut)

### 3. Page de Login Angular
- Interface de connexion moderne
- Gestion des erreurs
- Redirection automatique selon le rôle

### 4. Gestion des rôles
- **CLIENT** : Accès à son espace personnel (dashboard, transactions, comptes)
- **ADMIN** : Accès à l'interface d'administration complète

## 🚀 Démarrage

### 1. Mettre à jour la base de données

Exécutez le script SQL pour ajouter les colonnes password et role :

```sql
-- Dans MySQL Workbench ou ligne de commande
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

### 2. Recompiler le Client Service

```powershell
cd Client_service
.\mvnw clean package -DskipTests
```

### 3. Compiler le Gateway Service

```powershell
cd gateway_service
.\mvnw clean package -DskipTests
```

### 4. Démarrer les services

Ordre de démarrage :
1. Eureka Server (port 8761)
2. Client Service (port 8084)
3. Account Service (port 8081)
4. Transaction Service (port 8082)
5. Gateway Service (port 8080)
6. Frontend Angular (port 4200)

### 5. Accéder à l'application

```
http://localhost:4200
```

## 👤 Comptes de démonstration

### Client
- **Email** : jean.dupont@example.com
- **Mot de passe** : password123
- **Accès** : Dashboard, Transactions, Comptes personnels

### Administrateur
- **Email** : admin@willbank.com
- **Mot de passe** : password123
- **Accès** : Interface d'administration complète

## 🔄 Flux d'authentification

```
1. Utilisateur → Page de Login
2. Login → POST /api/auth/login (via Gateway)
3. Gateway → Client Service (validation credentials)
4. Client Service → Génère JWT token
5. Token → Stocké dans localStorage
6. Requêtes suivantes → Token dans header Authorization
7. Gateway → Valide token → Route vers service approprié
```

## 📁 Fichiers créés/modifiés

### Gateway Service (nouveau)
```
gateway_service/
├── pom.xml
├── src/main/java/com/willbank/gateway/
│   ├── GatewayServiceApplication.java
│   ├── config/JwtUtil.java
│   └── filter/AuthenticationFilter.java
└── src/main/resources/application.yaml
```

### Client Service (modifié)
```
Client_service/src/main/java/com/willbank/client/
├── entity/
│   ├── Client.java (+ password, role)
│   └── Role.java (nouveau)
├── config/
│   ├── SecurityConfig.java (nouveau)
│   └── JwtUtil.java (nouveau)
├── controller/
│   └── AuthController.java (nouveau)
└── dto/
    ├── LoginRequest.java (nouveau)
    └── LoginResponse.java (nouveau)
```

### Frontend Angular (modifié)
```
Frontend/src/app/
├── pages/login/ (nouveau)
│   ├── login.component.ts
│   ├── login.component.html
│   └── login.component.scss
├── services/
│   └── auth.service.ts (nouveau)
├── guards/
│   └── auth.guard.ts (nouveau)
├── interceptors/
│   └── auth.interceptor.ts (nouveau)
├── app.routes.ts (modifié)
├── app.config.ts (modifié)
├── app.ts (modifié)
└── components/sidebar/ (modifié)
```

### Base de données
```
database/
└── update-clients-auth.sql (nouveau)
```

## 🔒 Sécurité

### Token JWT
- Algorithme : HS256
- Expiration : 24 heures
- Claims : userId, email, role

### Routes protégées
- `/api/auth/**` : Publiques (login, validate)
- `/api/clients/**` : Authentification requise
- `/api/accounts/**` : Authentification requise
- `/api/transactions/**` : Authentification requise

### Routes Frontend
- `/login` : Publique
- `/dashboard`, `/transactions`, `/accounts` : Authentification requise
- `/admin/**` : Authentification + rôle ADMIN requis

## 🎨 Interface de Login

La page de login inclut :
- Logo WillBank
- Formulaire email/mot de passe
- Gestion des erreurs
- Indicateur de chargement
- Informations de démonstration

## 🔧 Configuration

### JWT (application.yaml)
```yaml
jwt:
  secret: WillBankSecretKey2024VeryLongSecretKeyForJWTTokenGeneration123456789
  expiration: 86400000  # 24 heures en millisecondes
```

### Gateway Routes (application.yaml)
```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: auth-service
          uri: lb://CLIENT-SERVICE
          predicates:
            - Path=/api/auth/**
        - id: client-service
          uri: lb://CLIENT-SERVICE
          predicates:
            - Path=/api/clients/**
          filters:
            - AuthenticationFilter
        # ... autres routes
```

## 📝 Notes importantes

1. **Mot de passe par défaut** : `password123` pour tous les comptes de test
2. **Hash BCrypt** : Les mots de passe sont hashés avec BCrypt
3. **Token storage** : Le token est stocké dans localStorage
4. **Redirection** : Après login, redirection automatique selon le rôle
5. **Déconnexion** : Supprime le token et redirige vers /login

## 🐛 Dépannage

### Erreur "Invalid email or password"
- Vérifiez que le script SQL a été exécuté
- Vérifiez que le mot de passe est bien "password123"

### Erreur 401 Unauthorized
- Vérifiez que le Gateway Service est démarré
- Vérifiez que le token est bien envoyé dans les headers

### Erreur CORS
- Vérifiez la configuration CORS dans le Gateway
- Vérifiez que le frontend utilise le bon port (8080)

## 🚀 Améliorations futures

- Refresh tokens
- Mot de passe oublié
- Inscription
- 2FA (authentification à deux facteurs)
- OAuth2 (Google, Facebook)
- Gestion des sessions
- Logs d'audit des connexions
