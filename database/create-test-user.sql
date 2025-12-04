-- Script pour créer un utilisateur de test
-- Email: jean.dupont@example.com
-- Password: password123
-- Hash BCrypt pour "password123": $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.rsS3/r/7HNtBJFgEy2

USE willbank_client_db;

-- Supprimer l'utilisateur s'il existe déjà
DELETE FROM clients WHERE email = 'jean.dupont@example.com';

-- Créer l'utilisateur Jean Dupont
INSERT INTO clients (
    first_name, 
    last_name, 
    email, 
    phone_number, 
    address, 
    city, 
    postal_code, 
    country, 
    date_of_birth, 
    national_id, 
    status, 
    kyc_status, 
    password, 
    role, 
    created_at, 
    updated_at
) VALUES (
    'Jean', 
    'Dupont', 
    'jean.dupont@example.com', 
    '+33612345678', 
    '123 Rue de la Paix', 
    'Paris', 
    '75001', 
    'France', 
    '1990-05-15', 
    'FR1234567890', 
    'ACTIVE', 
    'VERIFIED', 
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.rsS3/r/7HNtBJFgEy2',
    'CLIENT',
    NOW(),
    NOW()
);

-- Créer l'administrateur si pas déjà existant
INSERT INTO clients (
    first_name, 
    last_name, 
    email, 
    phone_number, 
    address, 
    city, 
    postal_code, 
    country, 
    date_of_birth, 
    national_id, 
    status, 
    kyc_status, 
    password, 
    role, 
    created_at, 
    updated_at
) VALUES (
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

-- Afficher les utilisateurs créés
SELECT id, first_name, last_name, email, role, status, kyc_status FROM clients WHERE email IN ('jean.dupont@example.com', 'admin@willbank.com');

COMMIT;
