-- Script pour ajouter les colonnes password et role aux clients existants
-- Mot de passe par défaut: password123 (hashé avec BCrypt)
-- Le hash BCrypt pour "password123" est: $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.rsS3/r/7HNtBJFgEy2

USE willbank_client_db;

-- Ajouter les colonnes si elles n'existent pas
ALTER TABLE clients ADD COLUMN IF NOT EXISTS password VARCHAR(255);
ALTER TABLE clients ADD COLUMN IF NOT EXISTS role VARCHAR(20) DEFAULT 'CLIENT';

-- Mettre à jour les clients existants avec un mot de passe par défaut
-- Hash BCrypt pour "password123"
UPDATE clients SET password = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.rsS3/r/7HNtBJFgEy2' WHERE password IS NULL;
UPDATE clients SET role = 'CLIENT' WHERE role IS NULL;

-- Créer l'administrateur
INSERT INTO clients (first_name, last_name, email, phone_number, address, city, postal_code, country, date_of_birth, national_id, status, kyc_status, password, role, created_at, updated_at) 
VALUES (
    'Admin', 
    'WillBank', 
    'admin@willbank.com', 
    '+33600000000', 
    '1 Place de la Banque', 
    'Paris', 
    '75001', 
    'France', 
    '1980-01-01', 
    'ADMIN000000001', 
    'ACTIVE', 
    'VERIFIED', 
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.rsS3/r/7HNtBJFgEy2',
    'ADMIN',
    NOW(),
    NOW()
) ON DUPLICATE KEY UPDATE role = 'ADMIN';

-- Vérifier les données
SELECT id, first_name, last_name, email, role, status FROM clients;

COMMIT;
