-- Script de création de la base de données MySQL pour WillBank

-- Créer la base de données
CREATE DATABASE IF NOT EXISTS willbank_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE willbank_db;

-- Table des clients
CREATE TABLE IF NOT EXISTS clients (
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

-- Table des comptes
CREATE TABLE IF NOT EXISTS accounts (
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
    INDEX idx_status (status),
    FOREIGN KEY (customer_id) REFERENCES clients(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des transactions
CREATE TABLE IF NOT EXISTS transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    transaction_reference VARCHAR(50) NOT NULL UNIQUE,
    account_number VARCHAR(20) NOT NULL,
    transaction_type VARCHAR(20) NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    balance_before DECIMAL(15, 2) NOT NULL,
    balance_after DECIMAL(15, 2) NOT NULL,
    description VARCHAR(500),
    status VARCHAR(20) NOT NULL DEFAULT 'COMPLETED',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_transaction_reference (transaction_reference),
    INDEX idx_account_number (account_number),
    INDEX idx_transaction_type (transaction_type),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),
    FOREIGN KEY (account_number) REFERENCES accounts(account_number) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des notifications
CREATE TABLE IF NOT EXISTS notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    recipient_email VARCHAR(255) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    sent_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_recipient_email (recipient_email),
    INDEX idx_status (status),
    INDEX idx_notification_type (notification_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Données de test pour les clients
INSERT INTO clients (first_name, last_name, email, phone_number, address, city, postal_code, country, date_of_birth, national_id, status, kyc_status) VALUES
('Jean', 'Dupont', 'jean.dupont@example.com', '+33612345678', '123 Rue de la République', 'Paris', '75001', 'France', '1985-03-15', '1850315123456', 'ACTIVE', 'VERIFIED'),
('Marie', 'Martin', 'marie.martin@example.com', '+33623456789', '456 Avenue des Champs', 'Lyon', '69001', 'France', '1990-07-22', '1900722234567', 'PENDING', 'PENDING_VERIFICATION'),
('Pierre', 'Bernard', 'pierre.bernard@example.com', '+33634567890', '789 Boulevard Saint-Germain', 'Marseille', '13001', 'France', '1988-11-30', '1881130345678', 'ACTIVE', 'VERIFIED'),
('Sophie', 'Dubois', 'sophie.dubois@example.com', '+33645678901', '321 Rue Victor Hugo', 'Toulouse', '31000', 'France', '1992-05-18', '1920518456789', 'SUSPENDED', 'VERIFIED'),
('Luc', 'Petit', 'luc.petit@example.com', '+33656789012', '654 Place de la Liberté', 'Nice', '06000', 'France', '1995-09-25', '1950925567890', 'PENDING', 'REJECTED');

-- Données de test pour les comptes
INSERT INTO accounts (account_number, customer_id, account_type, balance, currency, status) VALUES
('ACC1001001', 1, 'SAVINGS', 5000.00, 'EUR', 'ACTIVE'),
('ACC1001002', 1, 'CURRENT', 2500.00, 'EUR', 'ACTIVE'),
('ACC1003001', 3, 'SAVINGS', 10000.00, 'EUR', 'ACTIVE'),
('ACC1003002', 3, 'CURRENT', 3500.00, 'EUR', 'ACTIVE'),
('ACC1004001', 4, 'SAVINGS', 1500.00, 'EUR', 'SUSPENDED');

-- Données de test pour les transactions
INSERT INTO transactions (transaction_reference, account_number, transaction_type, amount, balance_before, balance_after, description, status) VALUES
('TXN20240101001', 'ACC1001001', 'DEPOSIT', 1000.00, 4000.00, 5000.00, 'Dépôt initial', 'COMPLETED'),
('TXN20240101002', 'ACC1001002', 'DEPOSIT', 2500.00, 0.00, 2500.00, 'Dépôt initial', 'COMPLETED'),
('TXN20240102001', 'ACC1003001', 'DEPOSIT', 10000.00, 0.00, 10000.00, 'Dépôt initial', 'COMPLETED'),
('TXN20240102002', 'ACC1001001', 'WITHDRAWAL', 500.00, 5000.00, 4500.00, 'Retrait DAB', 'COMPLETED'),
('TXN20240103001', 'ACC1001002', 'TRANSFER', 200.00, 2500.00, 2300.00, 'Virement vers compte épargne', 'COMPLETED');

COMMIT;
