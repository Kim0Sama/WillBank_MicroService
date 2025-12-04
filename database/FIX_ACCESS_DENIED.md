# Fix: Access Denied for MySQL Users

## Problème
```
Access denied for user 'client_service_user'@'localhost' (using password: YES)
```

## Cause
Les utilisateurs MySQL pour les microservices n'ont pas été créés.

## Solution Rapide

### Option 1: Script PowerShell (Recommandé)
```powershell
cd database
.\create-mysql-users.ps1
```

### Option 2: MySQL Workbench
1. Ouvrir MySQL Workbench
2. Se connecter en tant que root
3. Ouvrir le fichier `database/create-databases.sql`
4. Exécuter le script complet (⚡ Execute)

### Option 3: Ligne de commande MySQL
```bash
mysql -u root -p < database/create-databases.sql
```

## Vérification

Après l'exécution, vérifiez que les utilisateurs sont créés :

```sql
-- Se connecter à MySQL en tant que root
mysql -u root -p

-- Vérifier les utilisateurs
SELECT User, Host FROM mysql.user WHERE User LIKE '%service%';

-- Vérifier les bases de données
SHOW DATABASES LIKE 'willbank%';
```

Vous devriez voir :
- **Utilisateurs**: client_service_user, account_service_user, transaction_service_user
- **Bases de données**: willbank_client_db, willbank_account_db, willbank_transaction_db

## Identifiants des Services

| Service | Base de données | Utilisateur | Mot de passe |
|---------|----------------|-------------|--------------|
| Client Service | willbank_client_db | client_service_user | ClientService2024! |
| Account Service | willbank_account_db | account_service_user | AccountService2024! |
| Transaction Service | willbank_transaction_db | transaction_service_user | TransactionService2024! |

## Après la création

Une fois les utilisateurs créés, redémarrez le Client Service :
```bash
cd Client_service
mvn spring-boot:run
```

Le service devrait démarrer sans erreur sur le port 8084.
