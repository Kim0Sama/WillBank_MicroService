-- Reset password for test user pierre.bernard@example.com
-- Password: password123
-- BCrypt hash generated with strength 10

USE client_db;

-- Update the password with a fresh BCrypt hash for "password123"
UPDATE clients 
SET password = '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'
WHERE email = 'pierre.bernard@example.com';

-- Verify the update
SELECT 
    id,
    email,
    first_name,
    last_name,
    role,
    status,
    LENGTH(password) as password_length,
    SUBSTRING(password, 1, 20) as password_start
FROM clients 
WHERE email = 'pierre.bernard@example.com';
