-- Script de création des bases de données MySQL pour chaque microservice WillBank
-- Chaque service aura sa propre base de données pour une isolation complète

-- ============================================
-- 1. BASE DE DONNÉES CLIENT SERVICE
-- ============================================
DROP DATABASE IF EXISTS willbank_client_db;
CREATE DATABASE willbank_client_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE willbank_client_db;

-- Table des clients
CREATE TABLE clients (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone_number VARCHAR(20) NOT NULL,
    address VARCHAR(255),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    date_of_birth DATE,
    national_id VARCHAR(50) UNIQUE,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    kyc_status VARCHAR(30) NOT NULL DEFAULT 'NOT_VERIFIED',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_national_id (national_id),
    INDEX idx_status (status),
    INDEX idx_kyc_status (kyc_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Données de test pour les clients
INSERT INTO clients (first_name, last_name, email, phone_number, address, city, postal_code, country, date_of_birth, national_id, status, kyc_status) VALUES
('Jean', 'Dupont', 'jean.dupont@example.com', '+33612345678', '123 Rue de la République', 'Paris', '75001', 'France', '1985-03-15', '1850315123456', 'ACTIVE', 'VERIFIED'),
('Marie', 'Martin', 'marie.martin@example.com', '+33623456789', '456 Avenue des Champs', 'Lyon', '69001', 'France', '1990-07-22', '1900722234567', 'PENDING', 'PENDING_VERIFICATION'),
('Pierre', 'Bernard', 'pierre.bernard@example.com', '+33634567890', '789 Boulevard Saint-Germain', 'Marseille', '13001', 'France', '1988-11-30', '1881130345678', 'ACTIVE', 'VERIFIED'),
('Sophie', 'Dubois', 'sophie.dubois@example.com', '+33645678901', '321 Rue Victor Hugo', 'Toulouse', '31000', 'France', '1992-05-18', '1920518456789', 'SUSPENDED', 'VERIFIED'),
('Luc', 'Petit', 'luc.petit@example.com', '+33656789012', '654 Place de la Liberté', 'Nice', '06000', 'France', '1995-09-25', '1950925567890', 'PENDING', 'REJECTED');

-- ============================================
-- 2. BASE DE DONNÉES ACCOUNT SERVICE
-- ============================================
DROP DATABASE IF EXISTS willbank_account_db;
CREATE DATABASE willbank_account_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE willbank_account_db;

-- Table des comptes
CREATE TABLE accounts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    account_number VARCHAR(20) NOT NULL UNIQUE,
    customer_id BIGINT NOT NULL,
    account_type VARCHAR(20) NOT NULL,
    balance DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    currency VARCHAR(3) NOT NULL DEFAULT 'EUR',
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_account_number (account_number),
    INDEX idx_customer_id (customer_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Données de test pour les comptes
INSERT INTO accounts (account_number, customer_id, account_type, balance, currency, status) VALUES
('ACC1001001', 1, 'SAVINGS', 5000.00, 'EUR', 'ACTIVE'),
('ACC1001002', 1, 'CURRENT', 2500.00, 'EUR', 'ACTIVE'),
('ACC1003001', 3, 'SAVINGS', 10000.00, 'EUR', 'ACTIVE'),
('ACC1003002', 3, 'CURRENT', 3500.00, 'EUR', 'ACTIVE'),
('ACC1004001', 4, 'SAVINGS', 1500.00, 'EUR', 'SUSPENDED');

-- ============================================
-- 3. BASE DE DONNÉES TRANSACTION SERVICE
-- ============================================
DROP DATABASE IF EXISTS willbank_transaction_db;
CREATE DATABASE willbank_transaction_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE willbank_transaction_db;

-- Table des transactions (compatible avec l'entité JPA)
CREATE TABLE transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    transaction_reference VARCHAR(50) NOT NULL UNIQUE,
    transaction_type VARCHAR(20) NOT NULL,
    from_account VARCHAR(20) NOT NULL,
    to_account VARCHAR(20),
    amount DECIMAL(15, 2) NOT NULL,
    description VARCHAR(500),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP NULL,
    INDEX idx_transaction_reference (transaction_reference),
    INDEX idx_from_account (from_account),
    INDEX idx_to_account (to_account),
    INDEX idx_transaction_type (transaction_type),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Données de test pour les transactions
INSERT INTO transactions (transaction_reference, transaction_type, from_account, to_account, amount, description, status, processed_at) VALUES
('TXN20240101001', 'DEPOSIT', 'ACC1001001', NULL, 1000.00, 'Dépôt initial', 'COMPLETED', CURRENT_TIMESTAMP),
('TXN20240101002', 'DEPOSIT', 'ACC1001002', NULL, 2500.00, 'Dépôt initial', 'COMPLETED', CURRENT_TIMESTAMP),
('TXN20240102001', 'DEPOSIT', 'ACC1003001', NULL, 10000.00, 'Dépôt initial', 'COMPLETED', CURRENT_TIMESTAMP),
('TXN20240102002', 'WITHDRAWAL', 'ACC1001001', NULL, 500.00, 'Retrait DAB', 'COMPLETED', CURRENT_TIMESTAMP),
('TXN20240103001', 'TRANSFER', 'ACC1001002', 'ACC1001001', 200.00, 'Virement vers compte épargne', 'COMPLETED', CURRENT_TIMESTAMP);

-- ============================================
-- 4. CRÉATION DES UTILISATEURS
-- ============================================

-- Utilisateur pour Client Service
DROP USER IF EXISTS 'client_service_user'@'localhost';
CREATE USER 'client_service_user'@'localhost' IDENTIFIED BY 'ClientService2024!';
GRANT ALL PRIVILEGES ON willbank_client_db.* TO 'client_service_user'@'localhost';

-- Utilisateur pour Account Service
DROP USER IF EXISTS 'account_service_user'@'localhost';
CREATE USER 'account_service_user'@'localhost' IDENTIFIED BY 'AccountService2024!';
GRANT ALL PRIVILEGES ON willbank_account_db.* TO 'account_service_user'@'localhost';

-- Utilisateur pour Transaction Service
DROP USER IF EXISTS 'transaction_service_user'@'localhost';
CREATE USER 'transaction_service_user'@'localhost' IDENTIFIED BY 'TransactionService2024!';
GRANT ALL PRIVILEGES ON willbank_transaction_db.* TO 'transaction_service_user'@'localhost';

-- Appliquer les changements
FLUSH PRIVILEGES;

-- ============================================
-- 5. VÉRIFICATION
-- ============================================

-- Afficher les bases de données créées
SHOW DATABASES LIKE 'willbank%';

-- Afficher les utilisateurs créés
SELECT User, Host FROM mysql.user WHERE User LIKE '%service%';

COMMIT;
