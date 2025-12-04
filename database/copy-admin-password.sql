-- Copy the working admin password hash to all other users
-- This ensures all users have the same valid BCrypt hash

USE client_db;

-- First, let's see the current state
SELECT 'BEFORE UPDATE:' as status;
SELECT email, role, LENGTH(password) as password_length FROM clients ORDER BY email;

-- Copy admin's password to all CLIENT users
UPDATE clients c1
SET c1.password = (SELECT c2.password FROM (SELECT password FROM clients WHERE email = 'admin@willbank.com') c2)
WHERE c1.role = 'CLIENT';

-- Verify the update
SELECT 'AFTER UPDATE:' as status;
SELECT email, role, LENGTH(password) as password_length FROM clients ORDER BY email;

SELECT 'All users now have the same password as admin: password123' as message;
