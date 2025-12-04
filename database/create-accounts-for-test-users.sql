-- Créer des comptes pour les utilisateurs de test
USE willbank_account_db;

-- Vérifier les comptes existants
SELECT 'Comptes existants:' as '';
SELECT account_number, customer_id, account_type, balance, status FROM accounts ORDER BY customer_id;

-- Supprimer les anciens comptes de test s'ils existent
DELETE FROM accounts WHERE customer_id IN (6, 7, 8);

-- Créer des comptes pour Jean Dupont (ID 6)
INSERT INTO accounts (account_number, customer_id, account_type, balance, currency, status, created_at, updated_at)
VALUES
('ACC1006000001', 6, 'CHECKING', 5000.00, 'EUR', 'ACTIVE', NOW(), NOW()),
('ACC1006000002', 6, 'SAVINGS', 15000.00, 'EUR', 'ACTIVE', NOW(), NOW());

-- Créer des comptes pour Admin WillBank (ID 7)
INSERT INTO accounts (account_number, customer_id, account_type, balance, currency, status, created_at, updated_at)
VALUES
('ACC1007000001', 7, 'CHECKING', 100000.00, 'EUR', 'ACTIVE', NOW(), NOW()),
('ACC1007000002', 7, 'BUSINESS', 500000.00, 'EUR', 'ACTIVE', NOW(), NOW());

-- Créer des comptes pour Marie Martin (ID 8) si elle existe
INSERT INTO accounts (account_number, customer_id, account_type, balance, currency, status, created_at, updated_at)
VALUES
('ACC1008000001', 8, 'CHECKING', 7200.00, 'EUR', 'ACTIVE', NOW(), NOW()),
('ACC1008000002', 8, 'SAVINGS', 25000.00, 'EUR', 'ACTIVE', NOW(), NOW());

COMMIT;

-- Vérifier les comptes créés
SELECT '' as '';
SELECT 'Comptes après création:' as '';
SELECT account_number, customer_id, account_type, balance, currency, status FROM accounts WHERE customer_id IN (6, 7, 8) ORDER BY customer_id;

SELECT '' as '';
SELECT 'Résumé par client:' as '';
SELECT 
    customer_id,
    COUNT(*) as nombre_comptes,
    SUM(balance) as solde_total
FROM accounts 
WHERE customer_id IN (6, 7, 8)
GROUP BY customer_id;
