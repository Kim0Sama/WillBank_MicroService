# Guide d'implémentation Frontend WillBank

## ✅ Projet créé

Le projet Angular a été initialisé avec succès :
- Angular CLI 20.2.2
- Routing activé
- SCSS pour les styles
- Structure de base créée

## 📋 Prochaines étapes

### 1. Installer les dépendances

```bash
cd Frontend
npm install
```

### 2. Créer les services API

Créez les fichiers suivants dans `src/app/services/` :

**client.service.ts** - Communication avec Client Service (port 8084)
**account.service.ts** - Communication avec Account Service (port 8081)
**transaction.service.ts** - Communication avec Transaction Service (port 8082)

### 3. Créer les modèles TypeScript

Dans `src/app/models/` :
- `client.model.ts`
- `account.model.ts`
- `transaction.model.ts`

### 4. Créer les composants

```bash
ng generate component pages/dashboard
ng generate component pages/accounts
ng generate component pages/transactions
ng generate component pages/transfer
ng generate component components/account-card
ng generate component components/transaction-list
```

### 5. Configuration du proxy

Créez `proxy.conf.json` à la racine du projet Frontend :

```json
{
  "/api/clients": {
    "target": "http://localhost:8084",
    "secure": false
  },
  "/api/accounts": {
    "target": "http://localhost:8081",
    "secure": false
  },
  "/api/transactions": {
    "target": "http://localhost:8082",
    "secure": false
  }
}
```

Modifiez `package.json` :
```json
"start": "ng serve --proxy-config proxy.conf.json"
```

### 6. Routes principales

Dans `src/app/app.routes.ts` :

```typescript
export const routes: Routes = [
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  { path: 'dashboard', component: DashboardComponent },
  { path: 'accounts', component: AccountsComponent },
  { path: 'transactions', component: TransactionsComponent },
  { path: 'transfer', component: TransferComponent }
];
```

## 🎨 Design

Basé sur l'image fournie, implémentez :

1. **Sidebar** avec navigation :
   - Dashboard
   - Transactions
   - Accounts
   - Services

2. **Dashboard** :
   - Cartes de comptes (My Cards)
   - Transactions récentes
   - Graphiques d'activité
   - Quick Transfer

3. **Comptes** :
   - Liste des comptes
   - Soldes
   - Détails

4. **Transactions** :
   - Historique complet
   - Filtres par type
   - Recherche

## 📦 Bibliothèques recommandées

```bash
npm install @angular/material @angular/cdk
npm install chart.js ng2-charts
npm install @fortawesome/fontawesome-free
```

## 🔗 Endpoints API disponibles

### Client Service (8084)
- GET /api/clients
- GET /api/clients/{id}
- POST /api/clients

### Account Service (8081)
- GET /api/accounts/customer/{customerId}
- GET /api/accounts/{accountNumber}
- GET /api/accounts/{accountNumber}/balance
- POST /api/accounts

### Transaction Service (8082)
- GET /api/transactions/account/{accountNumber}
- POST /api/transactions/deposit
- POST /api/transactions/withdrawal
- POST /api/transactions/transfer

## 🚀 Démarrage rapide

1. Installez les dépendances : `npm install`
2. Démarrez les services backend
3. Lancez le frontend : `npm start`
4. Accédez à http://localhost:4200

## 📝 Notes importantes

- Utilisez HttpClient pour les appels API
- Implémentez la gestion des erreurs
- Ajoutez des intercepteurs pour les headers
- Utilisez RxJS pour la gestion asynchrone
- Implémentez le routing guards si nécessaire

## 🎯 Fonctionnalités prioritaires

1. ✅ Dashboard avec liste des comptes
2. ✅ Affichage du solde
3. ✅ Historique des transactions
4. ✅ Formulaire de virement
5. ✅ Dépôt/Retrait

Le projet est prêt à être développé !
