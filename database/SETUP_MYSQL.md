# Guide d'installation MySQL pour WillBank

## 📋 Vue d'ensemble

Chaque microservice WillBank utilise sa propre base de données MySQL pour une isolation complète :

| Service | Base de données | Utilisateur | Mot de passe |
|---------|----------------|-------------|--------------|
| Client Service | `willbank_client_db` | `client_service_user` | `ClientService2024!` |
| Account Service | `willbank_account_db` | `account_service_user` | `AccountService2024!` |
| Transaction Service | `willbank_transaction_db` | `transaction_service_user` | `TransactionService2024!` |

## 🚀 Installation rapide

### Étape 1 : Installer MySQL

#### Windows
1. Télécharger MySQL Installer : https://dev.mysql.com/downloads/installer/
2. Exécuter l'installeur
3. Choisir "Developer Default"
4. Définir un mot de passe root (ex: `root`)

#### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install mysql-server
sudo mysql_secure_installation
```

#### macOS
```bash
brew install mysql
brew services start mysql
mysql_secure_installation
```

### Étape 2 : Créer les bases de données

```bash
# Se connecter à MySQL en tant que root
mysql -u root -p

# Exécuter le script de création
source database/create-databases.sql

# Ou directement depuis la ligne de commande
mysql -u root -p < database/create-databases.sql
```

### Étape 3 : Vérifier l'installation

```sql
-- Se connecter à MySQL
mysql -u root -p

-- Vérifier les bases de données
SHOW DATABASES LIKE 'willbank%';

-- Devrait afficher :
-- +---------------------------+
-- | Database                  |
-- +---------------------------+
-- | willbank_account_db       |
-- | willbank_client_db        |
-- | willbank_transaction_db   |
-- +---------------------------+

-- Vérifier les utilisateurs
SELECT User, Host FROM mysql.user WHERE User LIKE '%service%';

-- Devrait afficher :
-- +---------------------------+-----------+
-- | User                      | Host      |
-- +---------------------------+-----------+
-- | account_service_user      | localhost |
-- | client_service_user       | localhost |
-- | transaction_service_user  | localhost |
-- +---------------------------+-----------+
```

### Étape 4 : Tester les connexions

```bash
# Test Client Service
mysql -u client_service_user -pClientService2024! willbank_client_db -e "SELECT COUNT(*) FROM clients;"

# Test Account Service
mysql -u account_service_user -pAccountService2024! willbank_account_db -e "SELECT COUNT(*) FROM accounts;"

# Test Transaction Service
mysql -u transaction_service_user -pTransactionService2024! willbank_transaction_db -e "SELECT COUNT(*) FROM transactions;"
```

## 📊 Structure des bases de données

### willbank_client_db
```sql
USE willbank_client_db;

-- Voir la structure
DESCRIBE clients;

-- Voir les données
SELECT id, first_name, last_name, email, status, kyc_status FROM clients;
```

### willbank_account_db
```sql
USE willbank_account_db;

-- Voir la structure
DESCRIBE accounts;

-- Voir les données
SELECT account_number, customer_id, account_type, balance, status FROM accounts;
```

### willbank_transaction_db
```sql
USE willbank_transaction_db;

-- Voir la structure
DESCRIBE transactions;

-- Voir les données
SELECT transaction_reference, account_number, transaction_type, amount, status FROM transactions;
```

## 🔧 Configuration des services

Les services sont déjà configurés pour utiliser MySQL. Vérifiez les fichiers :

- `Client_service/src/main/resources/application.yaml`
- `account_service/src/main/resources/application.yaml`
- `transaction_service/src/main/resources/application.yaml`

## 🚀 Démarrer les services

Une fois MySQL configuré, démarrez les services :

```bash
# 1. Eureka Server
cd Eureka-Service/Eureka-Service
.\mvnw.cmd spring-boot:run

# 2. Account Service
cd account_service
.\mvnw.cmd spring-boot:run

# 3. Transaction Service
cd transaction_service
.\mvnw.cmd spring-boot:run

# 4. Notification Service
cd Notification-service/Notification-service
.\mvnw.cmd spring-boot:run

# 5. Client Service
cd Client_service
.\mvnw.cmd spring-boot:run
```

## 🔍 Vérification

### Vérifier que les services se connectent à MySQL

Dans les logs de démarrage, vous devriez voir :
```
HikariPool-1 - Starting...
HikariPool-1 - Start completed.
Hibernate: create table if not exists clients ...
```

### Tester les APIs

```bash
# Client Service
curl http://localhost:8084/api/clients

# Account Service
curl http://localhost:8081/api/accounts

# Transaction Service
curl http://localhost:8082/api/transactions
```

## 🛠️ Dépannage

### Erreur : Access denied for user

```sql
-- Recréer l'utilisateur
DROP USER IF EXISTS 'client_service_user'@'localhost';
CREATE USER 'client_service_user'@'localhost' IDENTIFIED BY 'ClientService2024!';
GRANT ALL PRIVILEGES ON willbank_client_db.* TO 'client_service_user'@'localhost';
FLUSH PRIVILEGES;
```

### Erreur : Unknown database

```bash
# Réexécuter le script de création
mysql -u root -p < database/create-databases.sql
```

### Erreur : Communications link failure

- Vérifier que MySQL est démarré
- Vérifier le port 3306
- Vérifier le firewall

```bash
# Windows
netstat -ano | findstr 3306

# Linux/macOS
netstat -an | grep 3306
```

## 💾 Sauvegarde et restauration

### Sauvegarder toutes les bases de données

```bash
# Sauvegarder
mysqldump -u root -p --databases willbank_client_db willbank_account_db willbank_transaction_db > willbank_backup_$(date +%Y%m%d).sql

# Restaurer
mysql -u root -p < willbank_backup_20241203.sql
```

### Sauvegarder une base spécifique

```bash
# Client DB
mysqldump -u client_service_user -pClientService2024! willbank_client_db > client_db_backup.sql

# Account DB
mysqldump -u account_service_user -pAccountService2024! willbank_account_db > account_db_backup.sql

# Transaction DB
mysqldump -u transaction_service_user -pTransactionService2024! willbank_transaction_db > transaction_db_backup.sql
```

## 🔄 Réinitialisation

Pour réinitialiser toutes les bases de données :

```bash
mysql -u root -p < database/create-databases.sql
```

Cela supprimera et recréera toutes les bases de données avec les données de test.

## 📝 Requêtes utiles

### Statistiques

```sql
-- Nombre de clients par statut
SELECT status, COUNT(*) as count FROM willbank_client_db.clients GROUP BY status;

-- Solde total par type de compte
SELECT account_type, SUM(balance) as total FROM willbank_account_db.accounts GROUP BY account_type;

-- Transactions par type
SELECT transaction_type, COUNT(*) as count, SUM(amount) as total 
FROM willbank_transaction_db.transactions 
GROUP BY transaction_type;
```

### Monitoring

```sql
-- Voir les connexions actives
SHOW PROCESSLIST;

-- Taille des bases de données
SELECT 
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables
WHERE table_schema LIKE 'willbank%'
GROUP BY table_schema;
```

## 🎯 Avantages de cette architecture

✅ **Isolation complète** : Chaque service a sa propre base de données  
✅ **Sécurité** : Utilisateurs dédiés avec accès limité  
✅ **Évolutivité** : Possibilité de migrer chaque DB sur un serveur différent  
✅ **Maintenance** : Sauvegardes et restaurations indépendantes  
✅ **Performance** : Pas de contention entre services  

---

**Date de création :** 3 Décembre 2024  
**Version :** 1.0.0
