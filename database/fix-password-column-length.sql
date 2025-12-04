-- Script pour corriger la longueur de la colonne password
-- Les hash BCrypt font 60 caractères, il faut VARCHAR(255) minimum

USE willbank_client_db;

-- Vérifier la longueur actuelle
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'willbank_client_db'
  AND TABLE_NAME = 'clients'
  AND COLUMN_NAME = 'password';

-- Modifier la colonne pour être assez longue
ALTER TABLE clients MODIFY COLUMN password VARCHAR(255);

-- Remettre le bon hash pour tous les utilisateurs
UPDATE clients 
SET password = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.rsS3/r/7HNtBJFgEy2';

-- Vérifier que le hash est complet maintenant
SELECT 
    email,
    LENGTH(password) as password_length,
    LEFT(password, 30) as password_start
FROM clients
LIMIT 5;

SELECT '✓ Colonne password corrigée et hash mis à jour!' as 'STATUS';
SELECT 'Mot de passe pour tous: password123' as 'INFO';

COMMIT;
