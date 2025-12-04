# Fix Login - Solution Finale

## Problème
Les utilisateurs ne peuvent pas se connecter (erreur 401 Unauthorized).

## Solution en 3 étapes

### Étape 1 : Fixer les mots de passe dans la base de données

Exécute ce script pour copier le mot de passe de l'admin (qui fonctionne) vers tous les utilisateurs :

```cmd
database\FIX-ALL-PASSWORDS-SIMPLE.bat
```

Entre ton mot de passe root MySQL quand demandé.

### Étape 2 : Redémarrer le Client Service

Le Client Service doit être redémarré pour prendre en compte les changements de code :

```cmd
restart-client-service.ps1
```

Ou arrête et redémarre tous les services :

```cmd
stop-all-services.ps1
start-all-services.ps1
```

### Étape 3 : Tester la connexion

1. Ouvre le frontend : http://localhost:4200
2. Connecte-toi avec :
   - **Email:** marie.martin@example.com
   - **Password:** password123

3. Ou teste avec l'admin :
   - **Email:** admin@willbank.com
   - **Password:** password123

## Vérification

Si la connexion fonctionne, tu devrais :
- Être redirigé vers le dashboard
- Voir ton nom dans la sidebar
- Voir tes comptes (si des données existent)

## Si ça ne fonctionne toujours pas

### Vérifier les logs du Client Service

Regarde le terminal où le Client Service tourne. Tu devrais voir :
```
=== LOGIN ATTEMPT ===
Email: marie.martin@example.com
Client found: marie.martin@example.com
Password in DB: EXISTS
Role in DB: CLIENT
Attempting password match...
Password match result: true
Password matches!
```

Si tu vois `Password match result: false`, le problème de hash persiste.

### Solution de dernier recours : Réinitialiser complètement

1. Supprime toutes les données clients :
```sql
USE client_db;
DELETE FROM clients;
```

2. Exécute le script de setup complet :
```cmd
database\EXECUTE-AUTH-SETUP.bat
```

## Après la connexion réussie

Une fois connecté, si tu ne vois pas de comptes/transactions, exécute :

```cmd
database\ENSURE-TEST-DATA.bat
```

Cela créera des comptes et transactions de test pour tous les utilisateurs.
