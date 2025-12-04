-- Script pour modifier la table clients et ajouter les champs d'authentification
-- Ce script est idempotent (peut être exécuté plusieurs fois sans erreur)

USE willbank_client_db;

-- Désactiver les vérifications de clés étrangères temporairement
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

-- Afficher la structure de la table
DESCRIBE clients;

-- Mettre à jour les clients existants qui n'ont pas de password
UPDATE clients 
SET password = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.rsS3/r/7HNtBJFgEy2' 
WHERE password IS NULL OR password = '';

-- Mettre à jour les clients existants qui n'ont pas de role
UPDATE clients 
SET role = 'CLIENT' 
WHERE role IS NULL OR role = '';

-- Afficher un résumé
SELECT 
    COUNT(*) as total_clients,
    SUM(CASE WHEN role = 'CLIENT' THEN 1 ELSE 0 END) as clients,
    SUM(CASE WHEN role = 'ADMIN' THEN 1 ELSE 0 END) as admins
FROM clients;

COMMIT;

SELECT '✓ Table clients modifiée avec succès!' as status;
