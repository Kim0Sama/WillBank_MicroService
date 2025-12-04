# Configuration de la base de données MySQL pour WillBank

## ⚠️ IMPORTANT - Configuration de l'Authentification

**Après avoir créé les bases de données, vous DEVEZ configurer l'authentification :**

```powershell
.\EXECUTE-AUTH-SETUP.ps1
```

Ou :

```cmd
EXECUTE-AUTH-SETUP.bat
```

📖 **Voir [AUTH_SETUP_GUIDE.md](AUTH_SETUP_GUIDE.md) pour les détails complets**

---

## 🚀 Démarrage Rapide - 3 Méthodes

### ⭐ Méthode 1: Script Batch (LE PLUS SIMPLE)
```bash
cd database
EXECUTE_ME.bat
```
Double-cliquez sur `EXECUTE_ME.bat` ou exécutez-le en ligne de commande. Entrez votre mot de passe root MySQL quand demandé.

### ⭐ Méthode 2: MySQL Workbench (RECOMMANDÉ)
1. Ouvrez MySQL Workbench
2. Connectez-vous en tant que root
3. Fichier > Ouvrir un script SQL
4. Sélectionnez `create-databases.sql`
5. Cliquez sur l'éclair ⚡ pour exécuter

### ⭐ Méthode 3: Ligne de commande PowerShell
```powershell
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p < create-databases.sql
```

## 📋 Ce qui sera créé

✅ **3 Bases de données:**
- `willbank_client_db` - Gestion des clients
- `willbank_account_db` - Gestion des comptes
- `willbank_transaction_db` - Gestion des transactions

✅ **3 Utilisateurs avec privilèges:**
- `client_service_user` / `ClientService2024!`
- `account_service_user` / `AccountService2024!`
- `transaction_service_user` / `TransactionService2024!`

✅ **Tables et données de test** pour chaque service

## Prérequis

- MySQL Server 8.0 ou supérieur installé
- Accès root ou utilisateur avec privilèges de création de base de données

## Installation et configuration

### 1. Installer MySQL (si nécessaire)

#### Windows
Télécharger et installer MySQL depuis : https://dev.mysql.com/downloads/installer/

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
```

### 2. Créer la base de données et les tables

#### Option 1 : Via ligne de commande MySQL

```bash
# Se connecter à MySQL
mysql -u root -p

# Exécuter le script
source database/mysql_setup.sql

# Ou directement
mysql -u root -p < database/mysql_setup.sql
```

#### Option 2 : Via MySQL Workbench
1. Ouvrir MySQL Workbench
2. Se connecter au serveur MySQL
3. Ouvrir le fichier `mysql_setup.sql`
4. Exécuter le script (⚡ Execute)

### 3. Créer un utilisateur pour l'application

```sql
-- Se connecter à MySQL en tant que root
mysql -u root -p

-- Créer l'utilisateur
CREATE USER 'willbank_user'@'localhost' IDENTIFIED BY 'WillBank2024!';

-- Accorder les privilèges
GRANT ALL PRIVILEGES ON willbank_db.* TO 'willbank_user'@'localhost';

-- Appliquer les changements
FLUSH PRIVILEGES;

-- Vérifier
SHOW GRANTS FOR 'willbank_user'@'localhost';
```

### 4. Vérifier l'installation

```sql
USE willbank_db;

-- Vérifier les tables
SHOW TABLES;

-- Vérifier les données de test
SELECT * FROM clients;
SELECT * FROM accounts;
SELECT * FROM transactions;
```

## Configuration des microservices

### Client Service (Port 8081)

Mettre à jour `Client_service/src/main/resources/application.yaml` :

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/willbank_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
    username: willbank_user
    password: WillBank2024!
    driver-class-name: com.mysql.cj.jdbc.Driver
  
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.MySQL8Dialect
        format_sql: true
```

### Account Service (Port 8082)

Mettre à jour `account_service/src/main/resources/application.yaml` :

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/willbank_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
    username: willbank_user
    password: WillBank2024!
    driver-class-name: com.mysql.cj.jdbc.Driver
  
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.MySQL8Dialect
        format_sql: true
```

### Transaction Service (Port 8083)

Mettre à jour `transaction_service/src/main/resources/application.yaml` :

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/willbank_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
    username: willbank_user
    password: WillBank2024!
    driver-class-name: com.mysql.cj.jdbc.Driver
  
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.MySQL8Dialect
        format_sql: true
```

## Ajouter la dépendance MySQL

Dans chaque `pom.xml` des services, ajouter :

```xml
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>8.0.33</version>
</dependency>
```

## Structure de la base de données

### Table `clients`
- Stocke les informations des clients
- Gère le statut KYC
- Index sur email, national_id, status, kyc_status

### Table `accounts`
- Stocke les comptes bancaires
- Lié aux clients via customer_id
- Index sur account_number, customer_id, status

### Table `transactions`
- Stocke l'historique des transactions
- Lié aux comptes via account_number
- Index sur transaction_reference, account_number, type, status

### Table `notifications`
- Stocke les notifications envoyées
- Index sur recipient_email, status, type

## Commandes utiles

### Sauvegarder la base de données
```bash
mysqldump -u willbank_user -p willbank_db > willbank_backup.sql
```

### Restaurer la base de données
```bash
mysql -u willbank_user -p willbank_db < willbank_backup.sql
```

### Réinitialiser la base de données
```bash
mysql -u root -p -e "DROP DATABASE IF EXISTS willbank_db;"
mysql -u root -p < database/mysql_setup.sql
```

### Voir les logs MySQL
```bash
# Linux
sudo tail -f /var/log/mysql/error.log

# Windows
# Vérifier dans : C:\ProgramData\MySQL\MySQL Server 8.0\Data\*.err
```

## Dépannage

### Erreur de connexion
- Vérifier que MySQL est démarré : `sudo systemctl status mysql`
- Vérifier le port : `netstat -an | grep 3306`
- Vérifier les credentials dans application.yaml

### Erreur de timezone
Ajouter `serverTimezone=UTC` dans l'URL JDBC

### Erreur SSL
Ajouter `useSSL=false` dans l'URL JDBC pour le développement

### Erreur de privilèges
```sql
GRANT ALL PRIVILEGES ON willbank_db.* TO 'willbank_user'@'localhost';
FLUSH PRIVILEGES;
```

## Monitoring

### Voir les connexions actives
```sql
SHOW PROCESSLIST;
```

### Voir la taille de la base de données
```sql
SELECT 
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables
WHERE table_schema = 'willbank_db'
GROUP BY table_schema;
```

### Voir les statistiques des tables
```sql
SELECT 
    table_name,
    table_rows,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.tables
WHERE table_schema = 'willbank_db'
ORDER BY (data_length + index_length) DESC;
```
