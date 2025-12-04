-- Fix all passwords by copying the working admin password to all users

USE client_db;

-- First, show current state
SELECT 'BEFORE:' as status;
SELECT id, email, role, LENGTH(password) as pwd_len, SUBSTRING(password, 1, 30) as pwd_start FROM clients ORDER BY id;

-- Get admin's password and update all other users
UPDATE clients c1
CROSS JOIN (SELECT password FROM clients WHERE email = 'admin@willbank.com' LIMIT 1) c2
SET c1.password = c2.password
WHERE c1.email != 'admin@willbank.com';

-- Show result
SELECT 'AFTER:' as status;
SELECT id, email, role, LENGTH(password) as pwd_len, SUBSTRING(password, 1, 30) as pwd_start FROM clients ORDER BY id;

SELECT 'All users now have the same password as admin: password123' as message;
