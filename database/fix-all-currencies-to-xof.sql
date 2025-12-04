-- Script pour changer TOUTES les devises vers XOF (Franc CFA)
-- Ce script change USD, EUR, et toute autre devise vers XOF
-- À exécuter sur la base de données willbank_account_db

USE willbank_account_db;

-- Afficher l'état AVANT la mise à jour
SELECT '========================================' as '';
SELECT 'ÉTAT AVANT LA MISE À JOUR' as '';
SELECT '========================================' as '';
SELECT '' as '';

SELECT 'Comptes par devise:' as '';
SELECT 
    currency,
    COUNT(*) as nombre_comptes,
    SUM(balance) as solde_total
FROM accounts 
GROUP BY currency;

SELECT '' as '';
SELECT 'Liste détaillée des comptes:' as '';
SELECT 
    account_number, 
    customer_id, 
    account_type,
    balance, 
    currency, 
    status 
FROM accounts 
ORDER BY customer_id, account_number;

-- Mettre à jour TOUTES les devises vers XOF
SELECT '' as '';
SELECT '========================================' as '';
SELECT 'MISE À JOUR EN COURS...' as '';
SELECT '========================================' as '';

UPDATE accounts 
SET currency = 'XOF' 
WHERE currency != 'XOF';

SELECT CONCAT('✓ ', ROW_COUNT(), ' compte(s) mis à jour') as '';

-- Afficher l'état APRÈS la mise à jour
SELECT '' as '';
SELECT '========================================' as '';
SELECT 'ÉTAT APRÈS LA MISE À JOUR' as '';
SELECT '========================================' as '';
SELECT '' as '';

SELECT 'Comptes par devise:' as '';
SELECT 
    currency,
    COUNT(*) as nombre_comptes,
    SUM(balance) as solde_total
FROM accounts 
GROUP BY currency;

SELECT '' as '';
SELECT 'Liste détaillée des comptes:' as '';
SELECT 
    account_number, 
    customer_id, 
    account_type,
    balance, 
    currency, 
    status 
FROM accounts 
ORDER BY customer_id, account_number;

-- Vérification finale
SELECT '' as '';
SELECT '========================================' as '';
SELECT 'VÉRIFICATION FINALE' as '';
SELECT '========================================' as '';
SELECT '' as '';

-- Compter les comptes qui ne sont PAS en XOF (devrait être 0)
SELECT 
    CASE 
        WHEN COUNT(*) = 0 THEN '✓ Tous les comptes sont en XOF'
        ELSE CONCAT('⚠ ATTENTION: ', COUNT(*), ' compte(s) ne sont pas en XOF!')
    END as 'Résultat'
FROM accounts 
WHERE currency != 'XOF';

SELECT '' as '';
SELECT '========================================' as '';
SELECT '✓ MISE À JOUR TERMINÉE AVEC SUCCÈS!' as '';
SELECT '========================================' as '';
