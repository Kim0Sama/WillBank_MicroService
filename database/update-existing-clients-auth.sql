-- Script pour mettre à jour les clients existants avec password et role
-- Ce script ne crée PAS de nouveaux utilisateurs, il met seulement à jour les existants

USE willbank_client_db;

-- ============================================
-- ÉTAPE 1: Ajouter les colonnes si nécessaire
-- ============================================

SET FOREIGN_KEY_CHECKS = 0;

-- Ajouter password si n'existe pas
SELECT COUNT(*) INTO @password_exists 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'willbank_client_db' 
  AND TABLE_NAME = 'clients' 
  AND COLUMN_NAME = 'password';

SET @sql_password = IF(@password_exists = 0,
    'ALTER TABLE clients ADD COLUMN password VARCHAR(255) DEFAULT NULL AFTER email',
    'SELECT "Column password already exists" AS message');

PREPARE stmt_password FROM @sql_password;
EXECUTE stmt_password;
DEALLOCATE PREPARE stmt_password;

-- Ajouter role si n'existe pas
SELECT COUNT(*) INTO @role_exists 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'willbank_client_db' 
  AND TABLE_NAME = 'clients' 
  AND COLUMN_NAME = 'role';

SET @sql_role = IF(@role_exists = 0,
    'ALTER TABLE clients ADD COLUMN role VARCHAR(20) DEFAULT NULL AFTER password',
    'SELECT "Column role already exists" AS message');

PREPARE stmt_role FROM @sql_role;
EXECUTE stmt_role;
DEALLOCATE PREPARE stmt_role;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- ÉTAPE 2: Mettre à jour TOUS les clients existants
-- ============================================

-- Hash BCrypt pour "password123"
SET @default_password = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.rsS3/r/7HNtBJFgEy2';

-- Mettre à jour les clients qui n'ont pas de password
UPDATE clients 
SET password = @default_password
WHERE password IS NULL OR password = '';

-- Mettre à jour les clients qui n'ont pas de role (tous deviennent CLIENT par défaut)
UPDATE clients 
SET role = 'CLIENT' 
WHERE role IS NULL OR role = '' OR role NOT IN ('CLIENT', 'ADMIN');

-- ============================================
-- ÉTAPE 3: Créer/Mettre à jour les utilisateurs spécifiques
-- ============================================

-- Jean Dupont
INSERT INTO clients (
    first_name, last_name, email, password, role,
    phone_number, address, city, postal_code, country,
    date_of_birth, national_id, status, kyc_status,
    created_at, updated_at
) VALUES (
    'Jean', 'Dupont', 'jean.dupont@example.com', @default_password, 'CLIENT',
    '+33612345678', '123 Rue de la Paix', 'Paris', '75001', 'France',
    '1990-05-15', 'FR1234567890', 'ACTIVE', 'VERIFIED',
    NOW(), NOW()
)
ON DUPLICATE KEY UPDATE
    password = @default_password,
    role = 'CLIENT',
    updated_at = NOW();

-- Marie Martin
INSERT INTO clients (
    first_name, last_name, email, password, role,
    phone_number, address, city, postal_code, country,
    date_of_birth, national_id, status, kyc_status,
    created_at, updated_at
) VALUES (
    'Marie', 'Martin', 'marie.martin@example.com', @default_password, 'CLIENT',
    '+33698765432', '456 Avenue des Champs', 'Lyon', '69001', 'France',
    '1985-08-20', 'FR9876543210', 'ACTIVE', 'VERIFIED',
    NOW(), NOW()
)
ON DUPLICATE KEY UPDATE
    password = @default_password,
    role = 'CLIENT',
    updated_at = NOW();

-- Admin WillBank
INSERT INTO clients (
    first_name, last_name, email, password, role,
    phone_number, address, city, postal_code, country,
    date_of_birth, national_id, status, kyc_status,
    created_at, updated_at
) VALUES (
    'Admin', 'WillBank', 'admin@willbank.com', @default_password, 'ADMIN',
    '+33600000000', '1 Place de la Banque', 'Paris', '75001', 'France',
    '1980-01-01', 'ADMIN000000001', 'ACTIVE', 'VERIFIED',
    NOW(), NOW()
)
ON DUPLICATE KEY UPDATE
    password = @default_password,
    role = 'ADMIN',
    updated_at = NOW();

COMMIT;

-- ============================================
-- ÉTAPE 4: Vérification
-- ============================================

SELECT '============================================' as '';
SELECT '✓ Mise à jour terminée avec succès!' as 'STATUS';
SELECT '============================================' as '';

SELECT '' as '';
SELECT 'Tous les clients:' as '';
SELECT 
    id,
    first_name,
    last_name,
    email,
    role,
    status,
    CASE 
        WHEN password = @default_password THEN '✓ password123'
        WHEN password IS NOT NULL THEN '✓ autre mot de passe'
        ELSE '✗ pas de mot de passe'
    END as password_status
FROM clients
ORDER BY 
    CASE role 
        WHEN 'ADMIN' THEN 1 
        WHEN 'CLIENT' THEN 2 
        ELSE 3 
    END,
    email;

SELECT '' as '';
SELECT '============================================' as '';
SELECT 'Credentials pour se connecter:' as '';
SELECT '============================================' as '';
SELECT 'Tous les utilisateurs ont le mot de passe: password123' as '';
SELECT '============================================' as '';
