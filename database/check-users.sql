-- Script pour vérifier les utilisateurs dans la base de données
USE willbank_client_db;

SELECT 
    id,
    first_name,
    last_name,
    email,
    role,
    status,
    CASE 
        WHEN password IS NULL THEN '✗ PAS DE MOT DE PASSE'
        WHEN password = '' THEN '✗ MOT DE PASSE VIDE'
        WHEN password = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.rsS3/r/7HNtBJFgEy2' THEN '✓ password123'
        ELSE '? autre mot de passe'
    END as password_status
FROM clients
ORDER BY id;
