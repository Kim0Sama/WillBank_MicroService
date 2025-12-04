-- Fix ALL client passwords with valid BCrypt hashes for "password123"
-- This hash is the standard BCrypt hash for "password123" with strength 10

USE client_db;

-- Update ALL clients with the correct BCrypt hash for "password123"
UPDATE clients 
SET password = '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'
WHERE role = 'CLIENT';

-- Update admin separately (already working but let's ensure consistency)
UPDATE clients 
SET password = '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'
WHERE role = 'ADMIN';

-- Verify all passwords are now 60 characters
SELECT 
    id,
    email,
    first_name,
    last_name,
    role,
    LENGTH(password) as password_length,
    CASE 
        WHEN LENGTH(password) = 60 THEN 'OK'
        ELSE 'INVALID'
    END as status
FROM clients 
ORDER BY role, email;
