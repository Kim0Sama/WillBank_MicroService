-- Ensure test data exists in all databases
-- This script checks and inserts data only if it doesn't exist

-- ========================================
-- CLIENT DATABASE
-- ========================================
USE client_db;

SELECT '=== Checking CLIENT DATABASE ===' as status;
SELECT COUNT(*) as client_count FROM clients;

-- ========================================
-- ACCOUNT DATABASE
-- ========================================
USE account_db;

SELECT '=== Checking ACCOUNT DATABASE ===' as status;
SELECT COUNT(*) as account_count FROM accounts;

-- Insert accounts if they don't exist
INSERT IGNORE INTO accounts (account_number, customer_id, account_type, balance, currency, status, created_at, updated_at)
VALUES
-- Client ID 1
('ACC1001000001', 1, 'CHECKING', 5000.00, 'XOF', 'ACTIVE', NOW(), NOW()),
('ACC1001000002', 1, 'SAVINGS', 15000.00, 'XOF', 'ACTIVE', NOW(), NOW()),

-- Client ID 2
('ACC1002000001', 2, 'CHECKING', 3500.00, 'XOF', 'ACTIVE', NOW(), NOW()),
('ACC1002000002', 2, 'BUSINESS', 25000.00, 'XOF', 'ACTIVE', NOW(), NOW()),

-- Client ID 3
('ACC1003000001', 3, 'CHECKING', 7200.00, 'XOF', 'ACTIVE', NOW(), NOW()),

-- Client ID 4
('ACC1004000001', 4, 'SAVINGS', 12000.00, 'XOF', 'ACTIVE', NOW(), NOW()),

-- Client ID 5 (admin)
('ACC1005000001', 5, 'CHECKING', 100000.00, 'XOF', 'ACTIVE', NOW(), NOW());

SELECT 'Accounts after insert:' as status;
SELECT account_number, customer_id, account_type, balance, currency, status FROM accounts ORDER BY customer_id;

-- ========================================
-- TRANSACTION DATABASE
-- ========================================
USE transaction_db;

SELECT '=== Checking TRANSACTION DATABASE ===' as status;
SELECT COUNT(*) as transaction_count FROM transactions;

-- Insert sample transactions if they don't exist
INSERT IGNORE INTO transactions (transaction_reference, from_account, to_account, amount, transaction_type, status, description, created_at, processed_at)
VALUES
-- Deposits
('TXN' || LPAD(FLOOR(RAND() * 1000000), 10, '0'), 'ACC1001000001', 'ACC1001000001', 1000.00, 'DEPOSIT', 'COMPLETED', 'Initial deposit', DATE_SUB(NOW(), INTERVAL 30 DAY), DATE_SUB(NOW(), INTERVAL 30 DAY)),
('TXN' || LPAD(FLOOR(RAND() * 1000000), 10, '0'), 'ACC1002000001', 'ACC1002000001', 500.00, 'DEPOSIT', 'COMPLETED', 'Salary deposit', DATE_SUB(NOW(), INTERVAL 15 DAY), DATE_SUB(NOW(), INTERVAL 15 DAY)),
('TXN' || LPAD(FLOOR(RAND() * 1000000), 10, '0'), 'ACC1003000001', 'ACC1003000001', 2000.00, 'DEPOSIT', 'COMPLETED', 'Freelance payment', DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY)),

-- Withdrawals
('TXN' || LPAD(FLOOR(RAND() * 1000000), 10, '0'), 'ACC1001000001', NULL, 200.00, 'WITHDRAWAL', 'COMPLETED', 'ATM withdrawal', DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY)),
('TXN' || LPAD(FLOOR(RAND() * 1000000), 10, '0'), 'ACC1002000001', NULL, 150.00, 'WITHDRAWAL', 'COMPLETED', 'Cash withdrawal', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY)),

-- Transfers
('TXN' || LPAD(FLOOR(RAND() * 1000000), 10, '0'), 'ACC1001000001', 'ACC1002000001', 300.00, 'TRANSFER', 'COMPLETED', 'Payment to Pierre', DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY)),
('TXN' || LPAD(FLOOR(RAND() * 1000000), 10, '0'), 'ACC1002000001', 'ACC1003000001', 500.00, 'TRANSFER', 'COMPLETED', 'Payment to Sophie', DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),
('TXN' || LPAD(FLOOR(RAND() * 1000000), 10, '0'), 'ACC1003000001', 'ACC1001000001', 250.00, 'TRANSFER', 'COMPLETED', 'Refund to Marie', DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY));

SELECT 'Transactions after insert:' as status;
SELECT 
    SUBSTRING(transaction_reference, 1, 15) as trans_ref,
    from_account,
    to_account,
    amount,
    transaction_type,
    status,
    DATE_FORMAT(created_at, '%Y-%m-%d') as date
FROM transactions 
ORDER BY created_at DESC
LIMIT 20;

SELECT '=== DATA CHECK COMPLETE ===' as status;
