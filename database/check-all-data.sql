-- Check all existing data in all databases

-- CLIENT DATABASE
USE client_db;
SELECT '=== CLIENT DATABASE ===' as info;
SELECT 'Clients:' as table_name;
SELECT id, email, first_name, last_name, role, status, kyc_status FROM clients ORDER BY id;

-- ACCOUNT DATABASE
USE account_db;
SELECT '=== ACCOUNT DATABASE ===' as info;
SELECT 'Accounts:' as table_name;
SELECT account_number, customer_id, account_type, balance, currency, status FROM accounts ORDER BY customer_id;

-- TRANSACTION DATABASE
USE transaction_db;
SELECT '=== TRANSACTION DATABASE ===' as info;
SELECT 'Transactions:' as table_name;
SELECT 
    SUBSTRING(transaction_id, 1, 8) as trans_id,
    from_account,
    to_account,
    amount,
    transaction_type,
    status,
    DATE_FORMAT(created_at, '%Y-%m-%d %H:%i') as created
FROM transactions 
ORDER BY created_at DESC
LIMIT 20;
