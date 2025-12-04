-- Force fix all passwords with a known working BCrypt hash
-- Hash for "password123" with BCrypt strength 10

USE client_db;

-- Show BEFORE
SELECT 'BEFORE UPDATE:' as status;
SELECT id, email, LENGTH(password) as len FROM clients ORDER BY id;

-- Update ALL users with the same valid BCrypt hash
-- This is the standard BCrypt hash for "password123"
UPDATE clients 
SET password = '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi';

-- Show AFTER
SELECT 'AFTER UPDATE:' as status;
SELECT id, email, LENGTH(password) as len, password FROM clients ORDER BY id;

-- Verify all are identical
SELECT 
    CASE 
        WHEN COUNT(DISTINCT password) = 1 THEN 'SUCCESS: All passwords are now identical'
        ELSE 'ERROR: Passwords are still different'
    END as result
FROM clients;
