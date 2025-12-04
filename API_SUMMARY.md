# Résumé des APIs WillBank

## Tableau récapitulatif par service

### 🔐 Service d'Authentification (Client Service - Port 8081)

| Endpoint | Méthode | Rôle | Description |
|----------|---------|------|-------------|
| `/api/auth/login` | POST | Connexion | Authentifie un utilisateur et retourne un JWT |
| `/api/auth/validate` | POST | Validation | Vérifie la validité d'un token JWT |

---

### 👥 Service Client (Client Service - Port 8081)

#### Endpoints Utilisateur

| Endpoint | Méthode | Rôle | Description |
|----------|---------|------|-------------|
| `/api/clients` | POST | Créer | Crée un nouveau client |
| `/api/clients/{id}` | GET | Consulter | Récupère un client par ID |
| `/api/clients/email/{email}` | GET | Consulter | Récupère un client par email |
| `/api/clients` | GET | Lister | Récupère tous les clients |
| `/api/clients/status/{status}` | GET | Filtrer | Filtre les clients par statut |
| `/api/clients/kyc-status/{kycStatus}` | GET | Filtrer | Filtre les clients par statut KYC |
| `/api/clients/{id}` | PUT | Modifier | Met à jour un client |
| `/api/clients/{id}/status` | PATCH | Changer statut | Change le statut (ACTIVE, SUSPENDED, etc.) |
| `/api/clients/{id}/kyc` | PATCH | Mettre à jour KYC | Change le statut KYC (VERIFIED, REJECTED, etc.) |
| `/api/clients/{id}` | DELETE | Supprimer | Supprime un client |

#### Endpoints Admin

| Endpoint | Méthode | Rôle | Description |
|----------|---------|------|-------------|
| `/api/admin/clients` | GET | Lister (Admin) | Liste tous les clients (admin uniquement) |
| `/api/admin/clients/{id}` | GET | Consulter (Admin) | Consulte un client (admin uniquement) |
| `/api/admin/clients` | POST | Créer (Admin) | Crée un client (admin uniquement) |
| `/api/admin/clients/{id}` | PUT | Modifier (Admin) | Modifie un client (admin uniquement) |

---

### 💳 Service Compte (Account Service - Port 8082)

#### Endpoints Utilisateur

| Endpoint | Méthode | Rôle | Description |
|----------|---------|------|-------------|
| `/api/accounts` | POST | Créer | Crée un nouveau compte bancaire |
| `/api/accounts/{accountNumber}` | GET | Consulter | Récupère un compte par numéro |
| `/api/accounts/customer/{customerId}` | GET | Lister | Liste les comptes d'un client |
| `/api/accounts/{accountNumber}/balance` | GET | Consulter solde | Récupère le solde d'un compte |
| `/api/accounts/{accountNumber}/balance` | PUT | Modifier solde | Met à jour le solde (ADD/SUBTRACT) |
| `/api/accounts/{accountNumber}/status` | PUT | Changer statut | Change le statut du compte |

#### Endpoints Admin

| Endpoint | Méthode | Rôle | Description |
|----------|---------|------|-------------|
| `/api/admin/accounts` | GET | Lister (Admin) | Liste tous les comptes (admin uniquement) |
| `/api/admin/accounts/{accountNumber}` | GET | Consulter (Admin) | Consulte un compte (admin uniquement) |
| `/api/admin/accounts` | POST | Créer (Admin) | Crée un compte (admin uniquement) |
| `/api/admin/accounts/{accountNumber}/status` | PUT | Changer statut (Admin) | Change le statut (admin uniquement) |

---

### 💸 Service Transaction (Transaction Service - Port 8083)

#### Endpoints Utilisateur

| Endpoint | Méthode | Rôle | Description |
|----------|---------|------|-------------|
| `/api/transactions/deposit` | POST | Dépôt | Effectue un dépôt sur un compte |
| `/api/transactions/withdrawal` | POST | Retrait | Effectue un retrait d'un compte |
| `/api/transactions/transfer` | POST | Virement | Effectue un virement entre deux comptes |
| `/api/transactions/account/{accountNumber}` | GET | Historique | Récupère l'historique des transactions |
| `/api/transactions/{transactionReference}` | GET | Consulter | Récupère une transaction par référence |

#### Endpoints Admin

| Endpoint | Méthode | Rôle | Description |
|----------|---------|------|-------------|
| `/api/admin/transactions` | GET | Lister (Admin) | Liste toutes les transactions (admin uniquement) |
| `/api/admin/transactions/{id}` | GET | Consulter (Admin) | Consulte une transaction par ID (admin uniquement) |

---

### 🌐 Service Gateway (Port 8080)

Le Gateway est le point d'entrée unique pour toutes les requêtes. Il route automatiquement vers les microservices appropriés et gère l'authentification JWT.

**URL de base** : `http://localhost:8080`

---

## Statistiques

| Service | Endpoints Utilisateur | Endpoints Admin | Total |
|---------|----------------------|-----------------|-------|
| **Authentification** | 2 | 0 | 2 |
| **Client** | 10 | 4 | 14 |
| **Compte** | 6 | 4 | 10 |
| **Transaction** | 5 | 2 | 7 |
| **TOTAL** | **23** | **10** | **33** |

---

## Authentification requise

| Type d'endpoint | Authentification | Rôle requis |
|-----------------|------------------|-------------|
| `/api/auth/login` | ❌ Non | Aucun |
| `/api/auth/validate` | ✅ Oui | Aucun |
| `/api/clients/**` | ✅ Oui | USER ou ADMIN |
| `/api/admin/clients/**` | ✅ Oui | ADMIN uniquement |
| `/api/accounts/**` | ✅ Oui | USER ou ADMIN |
| `/api/admin/accounts/**` | ✅ Oui | ADMIN uniquement |
| `/api/transactions/**` | ✅ Oui | USER ou ADMIN |
| `/api/admin/transactions/**` | ✅ Oui | ADMIN uniquement |

---

## Formats de données

### Requête de création de client
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

### Requête de création de compte
```json
{
  "customerId": "number",
  "accountType": "SAVINGS|CHECKING|BUSINESS",
  "initialBalance": "number",
  "currency": "string"
}
```

### Requête de dépôt/retrait
```json
{
  "accountNumber": "string",
  "amount": "number",
  "description": "string"
}
```

### Requête de virement
```json
{
  "fromAccountNumber": "string",
  "toAccountNumber": "string",
  "amount": "number",
  "description": "string"
}
```

---

## Énumérations principales

| Type | Valeurs possibles |
|------|-------------------|
| **ClientStatus** | ACTIVE, PENDING, SUSPENDED, CLOSED |
| **KycStatus** | VERIFIED, PENDING_VERIFICATION, REJECTED |
| **AccountType** | SAVINGS, CHECKING, BUSINESS |
| **AccountStatus** | ACTIVE, SUSPENDED, CLOSED |
| **TransactionType** | DEPOSIT, WITHDRAWAL, TRANSFER_DEBIT, TRANSFER_CREDIT |
| **TransactionStatus** | COMPLETED, PENDING, FAILED |
| **Role** | USER, ADMIN |

---

## Codes HTTP courants

| Code | Signification | Quand |
|------|---------------|-------|
| 200 | OK | Requête réussie |
| 201 | Created | Ressource créée |
| 204 | No Content | Suppression réussie |
| 400 | Bad Request | Données invalides |
| 401 | Unauthorized | Token manquant/invalide |
| 403 | Forbidden | Rôle insuffisant |
| 404 | Not Found | Ressource introuvable |
| 500 | Server Error | Erreur serveur |

---

## Liens utiles

- **Documentation complète** : `API_DOCUMENTATION.md`
- **Collection Postman** : `WillBank_API_Tests.postman_collection.json`
- **Environnement Postman** : `WillBank_Environment.postman_environment.json`
- **Guide de démarrage** : `QUICK_START.md`
- **Dépannage** : `TROUBLESHOOTING.md`
