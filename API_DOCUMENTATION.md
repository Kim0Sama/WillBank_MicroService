# Documentation des APIs WillBank

## Vue d'ensemble

Cette documentation décrit tous les endpoints REST disponibles dans l'architecture microservices WillBank.

**URL de base (via Gateway)** : `http://localhost:8080`

**Authentification** : JWT Bearer Token (sauf endpoints `/api/auth/*`)

---

## 1. Service d'Authentification (Client Service)

### 1.1 Authentification

| Endpoint | Méthode | Rôle | Description |
|----------|---------|------|-------------|
| `/api/auth/login` | POST | Connexion utilisateur | Authentifie un utilisateur et retourne un token JWT |
| `/api/auth/validate` | POST | Validation de token | Vérifie la validité d'un token JWT |

#### Détails `/api/auth/login`

**Request Body:**
```json
{
  "email": "string",
  "password": "string"
}
```

**Response (200):**
```json
{
  "token": "string",
  "userId": "number",
  "email": "string",
  "firstName": "string",
  "lastName": "string",
  "role": "USER|ADMIN"
}
```

**Codes d'erreur:**
- `401` : Email ou mot de passe incorrect
- `403` : Compte suspendu ou fermé

---

## 2. Service Client (Client Service)

### 2.1 Gestion des Clients

| Endpoint | Méthode | Rôle | Description |
|----------|---------|------|-------------|
| `/api/clients` | POST | Créer un client | Crée un nouveau client dans le système |
| `/api/clients/{id}` | GET | Obtenir un client | Récupère les détails d'un client par ID |
| `/api/clients/email/{email}` | GET | Obtenir par email | Récupère un client par son email |
| `/api/clients` | GET | Liste des clients | Récupère tous les clients |
| `/api/clients/status/{status}` | GET | Filtrer par statut | Récupère les clients par statut |
| `/api/clients/kyc-status/{kycStatus}` | GET | Filtrer par KYC | Récupère les clients par statut KYC |
| `/api/clients/{id}` | PUT | Mettre à jour | Met à jour les informations d'un client |
| `/api/clients/{id}/status` | PATCH | Changer le statut | Met à jour le statut d'un client |
| `/api/clients/{id}/kyc` | PATCH | Mettre à jour KYC | Met à jour le statut KYC d'un client |
| `/api/clients/{id}` | DELETE | Supprimer | Supprime un client |

#### Détails `/api/clients` (POST)

**Request Body:**
```json
{
  "firstName": "string",
  "lastName": "string",
  "email": "string",
  "password": "string",
  "phoneNumber": "string",
  "address": "string",
  "city": "string",
  "postalCode": "string",
  "country": "string",
  "dateOfBirth": "date",
  "nationalId": "string"
}
```

#### Détails `/api/clients/{id}/status` (PATCH)

**Query Parameter:** `status` (ACTIVE, PENDING, SUSPENDED, CLOSED)

#### Détails `/api/clients/{id}/kyc` (PATCH)

**Request Body:**
```json
{
  "kycStatus": "VERIFIED|PENDING_VERIFICATION|REJECTED",
  "notes": "string"
}
```

### 2.2 Administration des Clients (Admin uniquement)

| Endpoint | Méthode | Rôle | Description |
|----------|---------|------|-------------|
| `/api/admin/clients` | GET | Liste admin | Récupère tous les clients (admin) |
| `/api/admin/clients/{id}` | GET | Détails admin | Récupère un client (admin) |
| `/api/admin/clients` | POST | Créer (admin) | Crée un client (admin) |
| `/api/admin/clients/{id}` | PUT | Modifier (admin) | Modifie un client (admin) |

**Note:** Tous les endpoints admin nécessitent le header `X-User-Role: ADMIN`

---

## 3. Service Compte (Account Service)

### 3.1 Gestion des Comptes

| Endpoint | Méthode | Rôle | Description |
|----------|---------|------|-------------|
| `/api/accounts` | POST | Créer un compte | Crée un nouveau compte bancaire |
| `/api/accounts/{accountNumber}` | GET | Obtenir un compte | Récupère les détails d'un compte |
| `/api/accounts/customer/{customerId}` | GET | Comptes d'un client | Récupère tous les comptes d'un client |
| `/api/accounts/{accountNumber}/balance` | PUT | Mettre à jour solde | Met à jour le solde d'un compte |
| `/api/accounts/{accountNumber}/status` | PUT | Changer le statut | Met à jour le statut d'un compte |
| `/api/accounts/{accountNumber}/balance` | GET | Obtenir le solde | Récupère le solde d'un compte |

#### Détails `/api/accounts` (POST)

**Request Body:**
```json
{
  "customerId": "number",
  "accountType": "SAVINGS|CHECKING|BUSINESS",
  "initialBalance": "number",
  "currency": "string"
}
```

**Response:**
```json
{
  "accountNumber": "string",
  "customerId": "number",
  "accountType": "string",
  "balance": "number",
  "currency": "string",
  "status": "ACTIVE|SUSPENDED|CLOSED",
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```

#### Détails `/api/accounts/{accountNumber}/balance` (PUT)

**Request Body:**
```json
{
  "amount": "number",
  "operation": "ADD|SUBTRACT"
}
```

#### Détails `/api/accounts/{accountNumber}/status` (PUT)

**Query Parameter:** `status` (ACTIVE, SUSPENDED, CLOSED)

### 3.2 Administration des Comptes (Admin uniquement)

| Endpoint | Méthode | Rôle | Description |
|----------|---------|------|-------------|
| `/api/admin/accounts` | GET | Liste admin | Récupère tous les comptes (admin) |
| `/api/admin/accounts/{accountNumber}` | GET | Détails admin | Récupère un compte (admin) |
| `/api/admin/accounts` | POST | Créer (admin) | Crée un compte (admin) |
| `/api/admin/accounts/{accountNumber}/status` | PUT | Changer statut (admin) | Change le statut d'un compte (admin) |

---

## 4. Service Transaction (Transaction Service)

### 4.1 Gestion des Transactions

| Endpoint | Méthode | Rôle | Description |
|----------|---------|------|-------------|
| `/api/transactions/deposit` | POST | Dépôt | Effectue un dépôt sur un compte |
| `/api/transactions/withdrawal` | POST | Retrait | Effectue un retrait d'un compte |
| `/api/transactions/transfer` | POST | Virement | Effectue un virement entre comptes |
| `/api/transactions/account/{accountNumber}` | GET | Historique | Récupère l'historique des transactions d'un compte |
| `/api/transactions/{transactionReference}` | GET | Détails transaction | Récupère les détails d'une transaction |

#### Détails `/api/transactions/deposit` (POST)

**Request Body:**
```json
{
  "accountNumber": "string",
  "amount": "number",
  "description": "string"
}
```

**Response:**
```json
{
  "transactionReference": "string",
  "accountNumber": "string",
  "transactionType": "DEPOSIT",
  "amount": "number",
  "balanceBefore": "number",
  "balanceAfter": "number",
  "description": "string",
  "status": "COMPLETED|PENDING|FAILED",
  "transactionDate": "datetime"
}
```

#### Détails `/api/transactions/withdrawal` (POST)

**Request Body:**
```json
{
  "accountNumber": "string",
  "amount": "number",
  "description": "string"
}
```

#### Détails `/api/transactions/transfer` (POST)

**Request Body:**
```json
{
  "fromAccountNumber": "string",
  "toAccountNumber": "string",
  "amount": "number",
  "description": "string"
}
```

**Response:** Retourne la transaction de débit (le crédit est créé automatiquement)

### 4.2 Administration des Transactions (Admin uniquement)

| Endpoint | Méthode | Rôle | Description |
|----------|---------|------|-------------|
| `/api/admin/transactions` | GET | Liste admin | Récupère toutes les transactions (admin) |
| `/api/admin/transactions/{id}` | GET | Détails admin | Récupère une transaction par ID (admin) |

---

## 5. Service Gateway

Le Gateway route toutes les requêtes vers les microservices appropriés et gère l'authentification JWT.

### 5.1 Routes configurées

| Pattern | Service cible | Port |
|---------|---------------|------|
| `/api/auth/**` | Client Service | 8081 |
| `/api/clients/**` | Client Service | 8081 |
| `/api/admin/clients/**` | Client Service | 8081 |
| `/api/accounts/**` | Account Service | 8082 |
| `/api/admin/accounts/**` | Account Service | 8082 |
| `/api/transactions/**` | Transaction Service | 8083 |
| `/api/admin/transactions/**` | Transaction Service | 8083 |

---

## 6. Codes de statut HTTP

| Code | Signification | Utilisation |
|------|---------------|-------------|
| 200 | OK | Requête réussie (GET, PUT, PATCH) |
| 201 | Created | Ressource créée avec succès (POST) |
| 204 | No Content | Suppression réussie (DELETE) |
| 400 | Bad Request | Données invalides |
| 401 | Unauthorized | Non authentifié ou token invalide |
| 403 | Forbidden | Accès refusé (rôle insuffisant) |
| 404 | Not Found | Ressource non trouvée |
| 500 | Internal Server Error | Erreur serveur |

---

## 7. Authentification et Autorisation

### 7.1 Obtenir un token

1. Appelez `/api/auth/login` avec email et password
2. Récupérez le token dans la réponse
3. Incluez le token dans toutes les requêtes suivantes

### 7.2 Utiliser le token

Ajoutez le header suivant à toutes vos requêtes :

```
Authorization: Bearer {votre_token_jwt}
```

### 7.3 Rôles

- **USER** : Accès aux endpoints standards
- **ADMIN** : Accès à tous les endpoints, y compris `/api/admin/*`

---

## 8. Exemples d'utilisation

### 8.1 Flux complet : Créer un client et un compte

```bash
# 1. Créer un client
curl -X POST http://localhost:8080/api/clients \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Jean",
    "lastName": "Dupont",
    "email": "jean.dupont@example.com",
    "password": "password123",
    "phoneNumber": "+33612345678",
    "address": "123 Rue de la Paix",
    "city": "Paris",
    "postalCode": "75001",
    "country": "France",
    "dateOfBirth": "1990-01-01",
    "nationalId": "1234567890123"
  }'

# 2. Se connecter
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "jean.dupont@example.com",
    "password": "password123"
  }'

# 3. Créer un compte (avec le token obtenu)
curl -X POST http://localhost:8080/api/accounts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {token}" \
  -d '{
    "customerId": 1,
    "accountType": "CHECKING",
    "initialBalance": 1000,
    "currency": "XOF"
  }'

# 4. Effectuer un dépôt
curl -X POST http://localhost:8080/api/transactions/deposit \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {token}" \
  -d '{
    "accountNumber": "ACC123456789",
    "amount": 500,
    "description": "Dépôt initial"
  }'
```

### 8.2 Flux admin : Gérer les clients

```bash
# 1. Se connecter en tant qu'admin
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@willbank.com",
    "password": "admin123"
  }'

# 2. Récupérer tous les clients
curl -X GET http://localhost:8080/api/admin/clients \
  -H "Authorization: Bearer {admin_token}" \
  -H "X-User-Role: ADMIN"

# 3. Suspendre un client
curl -X PATCH http://localhost:8080/api/clients/1/status?status=SUSPENDED \
  -H "Authorization: Bearer {admin_token}"

# 4. Vérifier le KYC d'un client
curl -X PATCH http://localhost:8080/api/clients/1/kyc \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {admin_token}" \
  -d '{
    "kycStatus": "VERIFIED",
    "notes": "Documents vérifiés"
  }'
```

---

## 9. Énumérations

### 9.1 ClientStatus
- `ACTIVE` : Client actif
- `PENDING` : En attente d'activation
- `SUSPENDED` : Compte suspendu
- `CLOSED` : Compte fermé

### 9.2 KycStatus
- `VERIFIED` : KYC vérifié
- `PENDING_VERIFICATION` : En attente de vérification
- `REJECTED` : KYC rejeté

### 9.3 AccountType
- `SAVINGS` : Compte épargne
- `CHECKING` : Compte courant
- `BUSINESS` : Compte professionnel

### 9.4 AccountStatus
- `ACTIVE` : Compte actif
- `SUSPENDED` : Compte suspendu
- `CLOSED` : Compte fermé

### 9.5 TransactionType
- `DEPOSIT` : Dépôt
- `WITHDRAWAL` : Retrait
- `TRANSFER_DEBIT` : Virement (débit)
- `TRANSFER_CREDIT` : Virement (crédit)

### 9.6 TransactionStatus
- `COMPLETED` : Transaction complétée
- `PENDING` : Transaction en attente
- `FAILED` : Transaction échouée

---

## 10. Collection Postman

Une collection Postman complète est disponible dans le fichier `WillBank_API_Tests.postman_collection.json` avec tous les exemples de requêtes.

**Variables d'environnement** (fichier `WillBank_Environment.postman_environment.json`) :
- `base_url` : http://localhost:8080
- `token` : (sera rempli automatiquement après login)
- `userId` : (sera rempli automatiquement après login)

---

## 11. Notes importantes

1. **Sécurité** : Tous les endpoints (sauf `/api/auth/login`) nécessitent un token JWT valide
2. **CORS** : Le backend accepte les requêtes de toutes les origines (à restreindre en production)
3. **Validation** : Tous les champs marqués comme requis doivent être fournis
4. **Format des dates** : ISO 8601 (ex: `2025-12-04T10:30:00Z`)
5. **Format des montants** : Nombres décimaux (ex: `1000.50`)
6. **Numéros de compte** : Générés automatiquement au format `ACC{timestamp}`
7. **Références de transaction** : Générées automatiquement au format `TXN{timestamp}`

---

## 12. Support et Contact

Pour toute question ou problème :
- Consultez le fichier `TROUBLESHOOTING.md`
- Vérifiez les logs des services
- Utilisez les scripts de diagnostic fournis (`diagnose-services.ps1`, etc.)
