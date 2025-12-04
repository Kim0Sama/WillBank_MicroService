-- Script complet pour configurer l'authentification WillBank
-- Exécute ce script pour tout configurer en une seule fois

USE willbank_client_db;

-- ============================================
-- ÉTAPE 1: Modifier la structure de la table
-- ============================================

-- Désactiver les vérifications de clés étrangères
SET FOREIGN_KEY_CHECKS = 0;

-- Ajouter la colonne password si elle n'existe pas
SELECT COUNT(*) INTO @password_exists 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'willbank_client_db' 
  AND TABLE_NAME = 'clients' 
  AND COLUMN_NAME = 'password';

SET @sql_password = IF(@password_exists = 0,
    'ALTER TABLE clients ADD COLUMN password VARCHAR(255) NOT NULL DEFAULT "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.rsS3/r/7HNtBJFgEy2" AFTER email',
    'SELECT "Column password already exists" AS message');

PREPARE stmt_password FROM @sql_password;
EXECUTE stmt_password;
DEALLOCATE PREPARE stmt_password;

-- Ajouter la colonne role si elle n'existe pas
SELECT COUNT(*) INTO @role_exists 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'willbank_client_db' 
  AND TABLE_NAME = 'clients' 
  AND COLUMN_NAME = 'role';

SET @sql_role = IF(@role_exists = 0,
    'ALTER TABLE clients ADD COLUMN role VARCHAR(20) NOT NULL DEFAULT "CLIENT" AFTER password',
    'SELECT "Column role already exists" AS message');

PREPARE stmt_role FROM @sql_role;
EXECUTE stmt_role;
DEALLOCATE PREPARE stmt_role;

-- Réactiver les vérifications de clés étrangères
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- ÉTAPE 2: Mettre à jour les données existantes
-- ============================================

-- Mettre à jour les clients existants qui n'ont pas de password
UPDATE clients 
SET password = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.rsS3/r/7HNtBJFgEy2' 
WHERE password IS NULL OR password = '' OR password = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.rsS3/r/7HNtBJFgEy2';

-- Mettre à jour les clients existants qui n'ont pas de role
UPDATE clients 
SET role = 'CLIENT' 
WHERE role IS NULL OR role = '' OR role NOT IN ('CLIENT', 'ADMIN');

-- ============================================
-- ÉTAPE 3: Créer les utilisateurs de test
-- ============================================

-- Supprimer les utilisateurs de test s'ils existent
DELETE FROM clients WHERE email IN ('jean.dupont@example.com', 'admin@willbank.com');

-- Créer Jean Dupont (CLIENT)
INSERT INTO clients (
    first_name, 
    last_name, 
    email, 
    password,
    role,
    phone_number, 
    address, 
    city, 
    postal_code, 
    country, 
    date_of_birth, 
    national_id, 
    status, 
    kyc_status, 
    created_at, 
    updated_at
) VALUES (
    'Jean', 
    'Dupont', 
    'jean.dupont@example.com',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.rsS3/r/7HNtBJFgEy2',
    'CLIENT',
    '+33612345678', 
    '123 Rue de la Paix', 
    'Paris', 
    '75001', 
    'France', 
    '1990-05-15', 
    'FR1234567890', 
    'ACTIVE', 
    'VERIFIED', 
    NOW(),
    NOW()
);

-- Créer Admin WillBank (ADMIN)
INSERT INTO clients (
    first_name, 
    last_name, 
    email,
    password,
    role,
    phone_number, 
    address, 
    city, 
    postal_code, 
    country, 
    date_of_birth, 
    national_id, 
    status, 
    kyc_status, 
    created_at, 
    updated_at
) VALUES (
    'Admin', 
    'WillBank', 
    'admin@willbank.com',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.rsS3/r/7HNtBJFgEy2',
    'ADMIN',
    '+33600000000', 
    '1 Place de la Banque', 
    'Paris', 
    '75001', 
    'France', 
    '1980-01-01', 
    'ADMIN000000001', 
    'ACTIVE', 
    'VERIFIED', 
    NOW(),
    NOW()
);

-- Créer Marie Martin (CLIENT)
INSERT INTO clients (
    first_name, 
    last_name, 
    email,
    password,
    role,
    phone_number, 
    address, 
    city, 
    postal_code, 
    country, 
    date_of_birth, 
    national_id, 
    status, 
    kyc_status, 
    created_at, 
    updated_at
) VALUES (
    'Marie', 
    'Martin', 
    'marie.martin@example.com',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.rsS3/r/7HNtBJFgEy2',
    'CLIENT',
    '+33698765432', 
    '456 Avenue des Champs', 
    'Lyon', 
    '69001', 
    'France', 
    '1985-08-20', 
    'FR9876543210', 
    'ACTIVE', 
    'VERIFIED', 
    NOW(),
    NOW()
);

COMMIT;

-- ============================================
-- ÉTAPE 4: Vérification
-- ============================================

SELECT '============================================' as '';
SELECT '✓ Configuration terminée avec succès!' as 'STATUS';
SELECT '============================================' as '';
SELECT '' as '';

SELECT 'Structure de la table clients:' as '';
DESCRIBE clients;

SELECT '' as '';
SELECT 'Statistiques:' as '';
SELECT 
    COUNT(*) as total_clients,
    SUM(CASE WHEN role = 'CLIENT' THEN 1 ELSE 0 END) as clients,
    SUM(CASE WHEN role = 'ADMIN' THEN 1 ELSE 0 END) as admins
FROM clients;

SELECT '' as '';
SELECT 'Utilisateurs de test créés:' as '';
SELECT 
    id,
    first_name,
    last_name,
    email,
    role,
    status,
    kyc_status,
    CASE 
        WHEN password = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.rsS3/r/7HNtBJFgEy2' THEN '✓ password123'
        ELSE '✗ autre'
    END as password_status
FROM clients 
WHERE email IN ('jean.dupont@example.com', 'admin@willbank.com', 'marie.martin@example.com')
ORDER BY role DESC, email;

SELECT '' as '';
SELECT '============================================' as '';
SELECT 'Credentials pour se connecter:' as '';
SELECT '============================================' as '';
SELECT 'CLIENT: jean.dupont@example.com / password123' as '';
SELECT 'CLIENT: marie.martin@example.com / password123' as '';
SELECT 'ADMIN:  admin@willbank.com / password123' as '';
SELECT '============================================' as '';
