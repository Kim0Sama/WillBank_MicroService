# WillBank Frontend - Angular

Application Angular pour la plateforme bancaire WillBank.

## Prérequis

- Node.js 22.18.0
- Angular CLI 20.2.2
- Services backend démarrés (ports 8081, 8082, 8084)

## Installation

```bash
cd Frontend
npm install
```

## Démarrage

```bash
npm start
```

L'application sera accessible sur http://localhost:4200

## Services Backend

- Client Service: http://localhost:8084
- Account Service: http://localhost:8081
- Transaction Service: http://localhost:8082

## Fonctionnalités

- Dashboard avec vue d'ensemble des comptes
- Liste des comptes bancaires
- Historique des transactions
- Dépôts et retraits
- Virements entre comptes

## Structure

```
src/
├── app/
│   ├── components/     # Composants réutilisables
│   ├── pages/          # Pages principales
│   ├── services/       # Services API
│   ├── models/         # Interfaces TypeScript
│   └── shared/         # Modules partagés
```

## Build

```bash
npm run build
```

Les fichiers de production seront dans `dist/`.
