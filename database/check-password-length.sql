-- Vérifier la longueur de la colonne password et des données
USE willbank_client_db;

-- 1. Structure de la colonne
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'willbank_client_db'
  AND TABLE_NAME = 'clients'
  AND COLUMN_NAME IN ('password', 'role');

-- 2. Longueur réelle des passwords stockés
SELECT 
    email,
    LENGTH(password) as password_length,
    password as full_password,
    role
FROM clients
LIMIT 5;
