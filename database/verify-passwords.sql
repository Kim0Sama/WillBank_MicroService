-- Verify all passwords are identical and valid

USE client_db;

SELECT 
    id,
    email,
    role,
    LENGTH(password) as pwd_length,
    password,
    CASE 
        WHEN LENGTH(password) = 60 THEN 'OK'
        ELSE 'INVALID LENGTH'
    END as status
FROM clients 
ORDER BY id;

-- Check if all passwords are the same
SELECT 
    COUNT(DISTINCT password) as unique_passwords,
    CASE 
        WHEN COUNT(DISTINCT password) = 1 THEN 'All passwords are identical'
        ELSE 'Passwords are different!'
    END as result
FROM clients;
