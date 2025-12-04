-- Script simple pour ajouter password et role aux clients existants
USE willbank_client_db;

-- Ignorer les erreurs si les colonnes existent déjà
SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0;

-- Essayer d'ajouter la colonne password (ignore si existe)
SET @s = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_SCHEMA='willbank_client_db' 
     AND TABLE_NAME='clients' 
     AND COLUMN_NAME='password') = 0,
    'ALTER TABLE clients ADD COLUMN password VARCHAR(255)',
    'SELECT "password column exists"'));
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Essayer d'ajouter la colonne role (ignore si existe)
SET @s = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_SCHEMA='willbank_client_db' 
     AND TABLE_NAME='clients' 
     AND COLUMN_NAME='role') = 0,
    'ALTER TABLE clients ADD COLUMN role VARCHAR(20)',
    'SELECT "role column exists"'));
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET SQL_NOTES=@OLD_SQL_NOTES;

-- Mettre à jour tous les clients avec le mot de passe par défaut
-- Hash BCrypt pour "password123"
UPDATE clients 
SET password = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.rsS3/r/7HNtBJFgEy2'
WHERE password IS NULL OR password = '';

-- Mettre à jour tous les clients avec le rôle CLIENT par défaut
UPDATE clients 
SET role = 'CLIENT'
WHERE role IS NULL OR role = '';

-- Mettre à jour ou créer Jean Dupont
UPDATE clients 
SET password = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.rsS3/r/7HNtBJFgEy2',
    role = 'CLIENT'
WHERE email = 'jean.dupont@example.com';

-- Mettre à jour ou créer Marie Martin  
UPDATE clients 
SET password = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.rsS3/r/7HNtBJFgEy2',
    role = 'CLIENT'
WHERE email = 'marie.martin@example.com';

-- Mettre à jour ou créer Admin
UPDATE clients 
SET password = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.rsS3/r/7HNtBJFgEy2',
    role = 'ADMIN'
WHERE email = 'admin@willbank.com';

-- Afficher tous les clients
SELECT 
    id,
    first_name,
    last_name,
    email,
    role,
    status,
    'password123' as mot_de_passe
FROM clients
ORDER BY 
    CASE role 
        WHEN 'ADMIN' THEN 1 
        ELSE 2 
    END,
    email;

SELECT '✓ Mise à jour terminée!' as 'STATUS';
SELECT 'Tous les utilisateurs ont le mot de passe: password123' as 'INFO';

COMMIT;
