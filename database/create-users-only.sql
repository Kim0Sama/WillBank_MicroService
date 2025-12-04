-- Script pour créer uniquement les utilisateurs MySQL
-- À exécuter si le script principal échoue

-- Créer les utilisateurs
CREATE USER IF NOT EXISTS 'client_service_user'@'localhost' IDENTIFIED BY 'ClientService2024!';
CREATE USER IF NOT EXISTS 'account_service_user'@'localhost' IDENTIFIED BY 'AccountService2024!';
CREATE USER IF NOT EXISTS 'transaction_service_user'@'localhost' IDENTIFIED BY 'TransactionService2024!';

-- Accorder les privilèges
GRANT ALL PRIVILEGES ON willbank_client_db.* TO 'client_service_user'@'localhost';
GRANT ALL PRIVILEGES ON willbank_account_db.* TO 'account_service_user'@'localhost';
GRANT ALL PRIVILEGES ON willbank_transaction_db.* TO 'transaction_service_user'@'localhost';

-- Appliquer les changements
FLUSH PRIVILEGES;

-- Vérifier
SELECT User, Host FROM mysql.user WHERE User LIKE '%service%';
