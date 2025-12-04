-- Insert test data for accounts and transactions
-- This will create sample accounts and transactions for existing clients

USE account_db;

-- Insert accounts for existing clients (IDs 1-5 from client_db)
INSERT INTO accounts (account_number, customer_id, account_type, balance, currency, status, created_at, updated_at)
VALUES
-- Client ID 1 (marie.martin@example.com)
('ACC1001000001', 1, 'CHECKING', 5000.00, 'XOF', 'ACTIVE', NOW(), NOW()),
('ACC1001000002', 1, 'SAVINGS', 15000.00, 'XOF', 'ACTIVE', NOW(), NOW()),

-- Client ID 2 (pierre.bernard@example.com)
('ACC1002000001', 2, 'CHECKING', 3500.00, 'EUR', 'ACTIVE', NOW(), NOW()),
('ACC1002000002', 2, 'BUSINESS', 25000.00, 'EUR', 'ACTIVE', NOW(), NOW()),

-- Client ID 3 (sophie.dubois@example.com)
('ACC1003000001', 3, 'CHECKING', 7200.00, 'EUR', 'ACTIVE', NOW(), NOW()),

-- Client ID 4 (luc.moreau@example.com)
('ACC1004000001', 4, 'SAVINGS', 12000.00, 'EUR', 'ACTIVE', NOW(), NOW()),

-- Client ID 5 (admin@willbank.com)
('ACC1005000001', 5, 'CHECKING', 100000.00, 'EUR', 'ACTIVE', NOW(), NOW())
ON DUPLICATE KEY UPDATE updated_at = NOW();

SELECT 'Accounts created successfully' as message;
SELECT * FROM accounts ORDER BY customer_id;

-- Switch to transaction database
USE transaction_db;

-- Insert sample transactions
INSERT INTO transactions (transaction_id, from_account, to_account, amount, transaction_type, status, description, created_at)
VALUES
-- Deposits
(UUID(), 'ACC1001000001', 'ACC1001000001', 1000.00, 'DEPOSIT', 'COMPLETED', 'Initial deposit', DATE_SUB(NOW(), INTERVAL 30 DAY)),
(UUID(), 'ACC1002000001', 'ACC1002000001', 500.00, 'DEPOSIT', 'COMPLETED', 'Salary deposit', DATE_SUB(NOW(), INTERVAL 15 DAY)),
(UUID(), 'ACC1003000001', 'ACC1003000001', 2000.00, 'DEPOSIT', 'COMPLETED', 'Freelance payment', DATE_SUB(NOW(), INTERVAL 10 DAY)),

-- Withdrawals
(UUID(), 'ACC1001000001', 'ACC1001000001', 200.00, 'WITHDRAWAL', 'COMPLETED', 'ATM withdrawal', DATE_SUB(NOW(), INTERVAL 5 DAY)),
(UUID(), 'ACC1002000001', 'ACC1002000001', 150.00, 'WITHDRAWAL', 'COMPLETED', 'Cash withdrawal', DATE_SUB(NOW(), INTERVAL 3 DAY)),

-- Transfers
(UUID(), 'ACC1001000001', 'ACC1002000001', 300.00, 'TRANSFER', 'COMPLETED', 'Payment to Pierre', DATE_SUB(NOW(), INTERVAL 7 DAY)),
(UUID(), 'ACC1002000001', 'ACC1003000001', 500.00, 'TRANSFER', 'COMPLETED', 'Payment to Sophie', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(UUID(), 'ACC1003000001', 'ACC1001000001', 250.00, 'TRANSFER', 'COMPLETED', 'Refund to Marie', DATE_SUB(NOW(), INTERVAL 1 DAY))
ON DUPLICATE KEY UPDATE created_at = created_at;

SELECT 'Transactions created successfully' as message;
SELECT 
    SUBSTRING(transaction_id, 1, 8) as trans_id,
    from_account,
    to_account,
    amount,
    transaction_type,
    status,
    description,
    DATE_FORMAT(created_at, '%Y-%m-%d') as date
FROM transactions 
ORDER BY created_at DESC
LIMIT 20;
