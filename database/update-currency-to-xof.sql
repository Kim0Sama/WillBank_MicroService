-- Script pour changer toutes les devises de EUR à XOF (Franc CFA)
-- À exécuter sur la base de données willbank_account_db

USE willbank_account_db;

-- Afficher les comptes avant la mise à jour
SELECT 'Comptes AVANT la mise à jour:' as '';
SELECT account_number, customer_id, balance, currency, status FROM accounts;

-- Mettre à jour toutes les devises EUR vers XOF
UPDATE accounts 
SET currency = 'XOF' 
WHERE currency = 'EUR';

-- Afficher les comptes après la mise à jour
SELECT '' as '';
SELECT 'Comptes APRÈS la mise à jour:' as '';
SELECT account_number, customer_id, balance, currency, status FROM accounts;

-- Afficher le résumé
SELECT '' as '';
SELECT 'Résumé:' as '';
SELECT 
    currency,
    COUNT(*) as nombre_comptes,
    SUM(balance) as solde_total
FROM accounts 
GROUP BY currency;

SELECT '' as '';
SELECT 'Mise à jour terminée avec succès!' as '';
