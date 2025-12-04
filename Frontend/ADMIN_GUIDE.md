# 👨‍💼 WillBank - Guide d'administration

## 🎯 Interface d'administration

L'interface d'administration permet de gérer l'ensemble de la plateforme WillBank avec un accès complet à toutes les bases de données.

## 📱 Pages disponibles

### 1. Admin Dashboard (`/admin`)
Vue d'ensemble complète de la plateforme :
- **Statistiques globales** :
  - Total clients (avec nombre de clients actifs)
  - Total comptes
  - Solde total de tous les comptes
  - Nombre de transactions
  - KYC en attente de vérification
- **Clients récents** : Liste des 5 derniers clients créés
- **Transactions récentes** : Dernières transactions effectuées

### 2. Gestion des Clients (`/admin/clients`)
Interface complète de gestion des clients :
- **Tableau de tous les clients** avec :
  - ID, Nom complet, Email, Téléphone
  - Ville, Statut, Statut KYC
  - Date de création
- **Filtres** :
  - Recherche par nom ou email
  - Filtre par statut (ACTIVE, PENDING, SUSPENDED, CLOSED)
  - Filtre par statut KYC (VERIFIED, PENDING_VERIFICATION, REJECTED)
- **Actions** :
  - Voir les détails complets d'un client
  - Modifier le statut du client
  - Mettre à jour le statut KYC

### 3. Gestion des Comptes (`/admin/accounts`)
Vue d'ensemble de tous les comptes bancaires :
- **Tableau de tous les comptes** avec :
  - Numéro de compte
  - Nom du client propriétaire
  - Type de compte (SAVINGS, CHECKING, BUSINESS)
  - Solde actuel
  - Devise
  - Statut
  - Dates de création et mise à jour
- **Filtres** :
  - Recherche par numéro de compte
  - Filtre par type de compte
  - Filtre par statut
- **Statistiques** :
  - Nombre total de comptes
  - Solde total de tous les comptes

### 4. Gestion des Transactions (`/admin/transactions`)
Historique complet de toutes les transactions :
- **Tableau de toutes les transactions** avec :
  - Référence unique
  - Type (DEPOSIT, WITHDRAWAL, TRANSFER)
  - Compte source
  - Compte destination (pour les virements)
  - Montant
  - Description
  - Statut (COMPLETED, PENDING, FAILED)
  - Dates de création et traitement
- **Filtres** :
  - Recherche par référence ou numéro de compte
  - Filtre par type de transaction
  - Filtre par statut
- **Statistiques** :
  - Nombre total de transactions
  - Montant total des transactions

## 🎨 Fonctionnalités

### Recherche et filtrage
Toutes les pages admin incluent :
- Barre de recherche en temps réel
- Filtres multiples combinables
- Compteurs dynamiques

### Visualisation des données
- Tableaux responsives avec scroll horizontal
- Badges colorés pour les statuts
- Icônes pour les types de transactions
- Formatage des montants en devise

### Navigation
- Sidebar avec sections Client et Administration
- Liens rapides depuis le dashboard admin
- Breadcrumbs pour la navigation

## 🔐 Données accessibles

L'administrateur a accès à **toutes les bases de données** :

### Base `willbank_client_db`
- 5 clients avec différents statuts
- Informations personnelles complètes
- Statuts KYC

### Base `willbank_account_db`
- 5 comptes bancaires
- Soldes en temps réel
- Types de comptes variés

### Base `willbank_transaction_db`
- Toutes les transactions historiques
- Dépôts, retraits, virements
- Statuts de traitement

## 🚀 Accès à l'interface admin

### URL
```
http://localhost:52340/admin
```

### Navigation depuis la sidebar
1. Section **Administration**
2. Cliquer sur **Admin Dashboard**

## 📊 Cas d'usage

### Vérifier un client KYC
1. Aller sur `/admin/clients`
2. Filtrer par `KYC: PENDING_VERIFICATION`
3. Cliquer sur "👁️ Voir" pour un client
4. Cliquer sur "Vérifier KYC"

### Surveiller les transactions
1. Aller sur `/admin/transactions`
2. Filtrer par type ou statut
3. Voir les détails de chaque transaction

### Analyser les comptes
1. Aller sur `/admin/accounts`
2. Voir le solde total de la plateforme
3. Filtrer par type de compte

### Vue d'ensemble
1. Aller sur `/admin`
2. Voir toutes les statistiques clés
3. Accéder rapidement aux sections via les liens

## 🎯 Différences Client vs Admin

### Interface Client (`/dashboard`, `/transactions`, `/accounts`)
- Vue limitée aux données du client connecté (ID: 1)
- Peut effectuer des transactions
- Peut créer de nouveaux comptes
- Vue personnelle

### Interface Admin (`/admin/*`)
- Vue globale de tous les clients
- Accès à toutes les bases de données
- Statistiques agrégées
- Gestion et supervision
- Pas de modification directe (lecture seule pour l'instant)

## 🔧 Fonctionnalités futures

Les fonctionnalités suivantes peuvent être ajoutées :
- Modification des informations clients
- Activation/Désactivation de comptes
- Validation/Rejet de transactions
- Export de données (CSV, PDF)
- Graphiques et analytics avancés
- Logs d'audit
- Notifications admin
- Gestion des rôles et permissions

## 📝 Notes techniques

### Chargement des données
- Les données sont chargées depuis les APIs REST
- Agrégation côté frontend pour les statistiques
- Filtrage en temps réel sans appel API

### Performance
- Chargement initial de toutes les données
- Filtrage local pour une réactivité optimale
- Pagination à implémenter pour de gros volumes

### APIs utilisées
- `GET /api/clients` - Liste tous les clients
- `GET /api/accounts/customer/{id}` - Comptes par client
- `GET /api/transactions/account/{accountNumber}` - Transactions par compte

## 🎨 Design

L'interface admin utilise :
- Tableaux avec hover effects
- Badges colorés pour les statuts
- Filtres intuitifs
- Design cohérent avec l'interface client
- Responsive (scroll horizontal sur petits écrans)

Profitez de votre interface d'administration complète ! 🚀
