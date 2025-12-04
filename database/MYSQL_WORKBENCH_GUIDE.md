# Guide MySQL Workbench pour WillBank

## 🎯 Configuration rapide avec MySQL Workbench

### Étape 1 : Ouvrir MySQL Workbench

1. Lancez **MySQL Workbench**
2. Cliquez sur votre connexion locale (généralement "Local instance MySQL80")
3. Entrez votre mot de passe root

### Étape 2 : Exécuter le script de création

#### Méthode 1 : Via l'interface (Recommandé)

1. Dans MySQL Workbench, cliquez sur **File → Open SQL Script**
2. Naviguez vers : `D:\ARCHIDESSI\WillBank\WillBank_MicroService\database\create-databases.sql`
3. Cliquez sur **Open**
4. Cliquez sur l'icône **⚡ Execute** (ou appuyez sur Ctrl+Shift+Enter)
5. Attendez que le script se termine (vous verrez "Action Output" en bas)

#### Méthode 2 : Copier-coller

1. Ouvrez le fichier `database/create-databases.sql` dans un éditeur de texte
2. Copiez tout le contenu
3. Dans MySQL Workbench, collez dans une nouvelle query tab
4. Cliquez sur **⚡ Execute**

### Étape 3 : Vérifier la création

Exécutez ces requêtes dans MySQL Workbench :

```sql
-- 1. Voir les bases de données créées
SHOW DATABASES LIKE 'willbank%';
```

Vous devriez voir :
```
willbank_account_db
willbank_client_db
willbank_transaction_db
```

```sql
-- 2. Voir les utilisateurs créés
SELECT User, Host FROM mysql.user WHERE User LIKE '%service%';
```

Vous devriez voir :
```
account_service_user    localhost
client_service_user     localhost
transaction_service_user localhost
```

```sql
-- 3. Vérifier les données de test
USE willbank_client_db;
SELECT COUNT(*) as total_clients FROM clients;
SELECT first_name, last_name, email, status FROM clients;
```

Vous devriez voir 5 clients.

```sql
USE willbank_account_db;
SELECT COUNT(*) as total_accounts FROM accounts;
SELECT account_number, customer_id, account_type, balance FROM accounts;
```

Vous devriez voir 5 comptes.

```sql
USE willbank_transaction_db;
SELECT COUNT(*) as total_transactions FROM transactions;
SELECT transaction_reference, transaction_type, amount FROM transactions;
```

Vous devriez voir 5 transactions.

### Étape 4 : Tester les connexions

Dans MySQL Workbench, créez une nouvelle connexion pour chaque service :

#### Connexion Client Service

1. Cliquez sur **+** à côté de "MySQL Connections"
2. Remplissez :
   - **Connection Name** : WillBank Client Service
   - **Hostname** : localhost
   - **Port** : 3306
   - **Username** : client_service_user
   - **Password** : ClientService2024! (cliquez sur "Store in Vault")
   - **Default Schema** : willbank_client_db
3. Cliquez sur **Test Connection**
4. Si succès, cliquez sur **OK**

#### Connexion Account Service

- **Connection Name** : WillBank Account Service
- **Username** : account_service_user
- **Password** : AccountService2024!
- **Default Schema** : willbank_account_db

#### Connexion Transaction Service

- **Connection Name** : WillBank Transaction Service
- **Username** : transaction_service_user
- **Password** : TransactionService2024!
- **Default Schema** : willbank_transaction_db

## 🔧 Dépannage

### Problème : "Access denied for user"

Si vous obtenez cette erreur lors du test de connexion :

1. **Vérifiez que le script a bien été exécuté**
   ```sql
   SELECT User FROM mysql.user WHERE User = 'client_service_user';
   ```

2. **Si l'utilisateur n'existe pas, créez-le manuellement**
   ```sql
   CREATE USER 'client_service_user'@'localhost' IDENTIFIED BY 'ClientService2024!';
   GRANT ALL PRIVILEGES ON willbank_client_db.* TO 'client_service_user'@'localhost';
   FLUSH PRIVILEGES;
   ```

3. **Testez la connexion**
   ```sql
   -- Déconnectez-vous et reconnectez-vous avec client_service_user
   ```

### Problème : "Unknown database"

Si la base de données n'existe pas :

```sql
CREATE DATABASE willbank_client_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### Problème : Script ne s'exécute pas complètement

Exécutez le script par sections :

1. D'abord, créez les bases de données
2. Ensuite, créez les tables
3. Puis, insérez les données
4. Enfin, créez les utilisateurs

## 📊 Requêtes utiles dans Workbench

### Voir toutes les tables d'une base

```sql
USE willbank_client_db;
SHOW TABLES;
```

### Voir la structure d'une table

```sql
DESCRIBE clients;
```

### Exporter des données

1. Clic droit sur la table → **Table Data Export Wizard**
2. Choisissez le format (CSV, JSON, SQL)
3. Suivez l'assistant

### Importer des données

1. Clic droit sur la table → **Table Data Import Wizard**
2. Sélectionnez votre fichier
3. Suivez l'assistant

## ✅ Checklist de vérification

Avant de démarrer les services Spring Boot, vérifiez :

- [ ] MySQL Server est démarré
- [ ] Les 3 bases de données existent (willbank_client_db, willbank_account_db, willbank_transaction_db)
- [ ] Les 3 utilisateurs existent et ont les bons privilèges
- [ ] Les tables sont créées dans chaque base
- [ ] Les données de test sont insérées
- [ ] Les connexions de test fonctionnent dans Workbench

## 🚀 Après la configuration

Une fois MySQL configuré, démarrez les services :

```bash
# Client Service
cd Client_service
.\mvnw.cmd spring-boot:run

# Account Service
cd account_service
.\mvnw.cmd spring-boot:run

# Transaction Service
cd transaction_service
.\mvnw.cmd spring-boot:run
```

Les services devraient maintenant se connecter à MySQL sans erreur !

---

**Astuce** : Gardez MySQL Workbench ouvert pendant le développement pour monitorer les données en temps réel.
