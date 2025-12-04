# 🚀 WillBank - Guide de démarrage rapide

## ✅ Services actifs

### Backend Services
- **Eureka Server** : http://localhost:8761
- **Account Service** : http://localhost:8081
- **Transaction Service** : http://localhost:8082
- **Client Service** : http://localhost:8084

### Frontend Application
- **Angular App** : http://localhost:52340

## 📊 Données disponibles dans MySQL

### Clients (5 clients)
1. **Jean Dupont** (ID: 1) - ACTIVE, VERIFIED
   - Email: jean.dupont@example.com
   - 2 comptes bancaires

2. **Marie Martin** (ID: 2) - PENDING, PENDING_VERIFICATION
   - Email: marie.martin@example.com

3. **Pierre Bernard** (ID: 3) - ACTIVE, VERIFIED
   - Email: pierre.bernard@example.com
   - 2 comptes bancaires

4. **Sophie Dubois** (ID: 4) - SUSPENDED, VERIFIED
   - Email: sophie.dubois@example.com
   - 1 compte bancaire

5. **Luc Petit** (ID: 5) - PENDING, REJECTED
   - Email: luc.petit@example.com

### Comptes (5 comptes)
- **ACC1001001** - Jean Dupont - SAVINGS - 5,150.00 EUR
- **ACC1001002** - Jean Dupont - CURRENT - 2,500.00 EUR
- **ACC1003001** - Pierre Bernard - SAVINGS - 10,000.00 EUR
- **ACC1003002** - Pierre Bernard - CURRENT - 3,500.00 EUR
- **ACC1004001** - Sophie Dubois - SAVINGS - 1,500.00 EUR (SUSPENDED)

### Transactions (5+ transactions)
- Dépôts initiaux
- Retraits DAB
- Virements entre comptes

## 🎯 Accéder à l'application

### 1. Ouvrir le frontend
```
http://localhost:52340
```

### 2. Navigation
- **Dashboard** : Vue d'ensemble avec cartes de comptes et transactions récentes
- **Transactions** : Effectuer des dépôts, retraits et virements
- **Accounts** : Voir tous les comptes et créer de nouveaux comptes

### 3. Données affichées
Le frontend charge automatiquement :
- Les comptes du client ID 1 (Jean Dupont)
- Les transactions récentes
- Les soldes en temps réel

## 🧪 Tester les fonctionnalités

### Effectuer un dépôt
1. Aller sur **Transactions**
2. Sélectionner l'onglet **Deposit**
3. Choisir un compte
4. Entrer un montant (ex: 100 EUR)
5. Cliquer sur **Deposit**

### Effectuer un retrait
1. Aller sur **Transactions**
2. Sélectionner l'onglet **Withdrawal**
3. Choisir un compte
4. Entrer un montant (ex: 50 EUR)
5. Cliquer sur **Withdraw**

### Effectuer un virement
1. Aller sur **Transactions**
2. Sélectionner l'onglet **Transfer**
3. Choisir le compte source
4. Entrer le numéro de compte destination (ex: ACC1001002)
5. Entrer un montant
6. Cliquer sur **Transfer**

### Créer un nouveau compte
1. Aller sur **Accounts**
2. Cliquer sur **+ New Account**
3. Choisir le type de compte (Checking, Savings, Business)
4. Entrer le dépôt initial
5. Cliquer sur **Create Account**

## 📡 Tester les APIs directement

### Voir tous les clients
```powershell
Invoke-RestMethod -Uri "http://localhost:8084/api/clients" -Method Get
```

### Voir les comptes d'un client
```powershell
Invoke-RestMethod -Uri "http://localhost:8081/api/accounts/customer/1" -Method Get
```

### Voir les transactions d'un compte
```powershell
Invoke-RestMethod -Uri "http://localhost:8082/api/transactions/account/ACC1001001" -Method Get
```

### Effectuer un dépôt via API
```powershell
$body = @{
    accountNumber = "ACC1001001"
    amount = 100.00
    description = "Test deposit"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8082/api/transactions/deposit" `
  -Method Post `
  -ContentType "application/json" `
  -Body $body
```

## 🛑 Arrêter les services

### Arrêter le frontend
Dans le terminal où npm start est lancé, appuyez sur `Ctrl+C`

### Arrêter les services backend
```powershell
.\stop-all-services.ps1
```

## 🔧 Redémarrer tout

```powershell
# 1. Arrêter tout
.\stop-all-services.ps1

# 2. Démarrer les services backend
.\start-all-services.ps1

# 3. Démarrer le frontend
cd Frontend
npm start
```

## 📝 Notes importantes

- **Customer ID** : Le frontend est actuellement configuré pour afficher les données du client ID 1 (Jean Dupont)
- **Proxy** : Le frontend utilise un proxy pour rediriger les appels API vers les services backend
- **Base de données** : Les données sont persistées dans MySQL (willbank_client_db, willbank_account_db, willbank_transaction_db)

## 🎨 Fonctionnalités du frontend

✅ Dashboard avec cartes de comptes
✅ Liste des transactions récentes
✅ Formulaires de dépôt/retrait/virement
✅ Création de nouveaux comptes
✅ Navigation avec sidebar
✅ Design moderne inspiré de BankDash

## 🐛 En cas de problème

### Le frontend ne charge pas les données
1. Vérifier que les services backend sont actifs
2. Vérifier la console du navigateur (F12)
3. Vérifier que le proxy fonctionne

### Erreur 404 sur les APIs
1. Vérifier que les services sont bien démarrés
2. Vérifier les ports (8081, 8082, 8084)

### Erreur de connexion MySQL
1. Vérifier que MySQL est démarré
2. Vérifier les credentials dans les fichiers application.yaml
3. Exécuter le script de création des bases de données

Bon test ! 🚀
