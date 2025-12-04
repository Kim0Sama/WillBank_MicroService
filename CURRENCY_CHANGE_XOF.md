# Changement de devise : EUR → XOF (Franc CFA)

## Modifications effectuées

Toutes les devises du système WillBank ont été changées de EUR (Euro) à XOF (Franc CFA).

## Fichiers modifiés

### Backend

1. **account_service/src/main/java/com/willbank/account/entity/Account.java**
   - Valeur par défaut de `currency` changée de `"EUR"` à `"XOF"`

### Frontend

2. **Frontend/src/app/pages/dashboard/dashboard.component.html**
   - Format d'affichage : `currency: 'XOF':'symbol':'1.0-0'`

3. **Frontend/src/app/pages/transactions/transactions.component.html**
   - Format d'affichage : `currency: 'XOF':'symbol':'1.0-0'`

4. **Frontend/src/app/pages/admin/admin-dashboard/admin-dashboard.component.html**
   - Format d'affichage : `currency: 'XOF':'symbol':'1.0-0'`

5. **Frontend/src/app/pages/admin/admin-transactions/admin-transactions.component.html**
   - Format d'affichage : `currency: 'XOF':'symbol':'1.0-0'`

6. **Frontend/src/app/pages/admin/admin-accounts/admin-accounts.component.html**
   - Format d'affichage : `currency: 'XOF':'symbol':'1.0-0'`

### Base de données

7. **database/create-databases.sql**
   - Valeur par défaut : `DEFAULT 'XOF'`
   - Données de test mises à jour

8. **database/create-accounts-for-test-users.sql**
   - Tous les comptes créés avec devise XOF

9. **database/ensure-test-data.sql**
   - Tous les comptes de test avec devise XOF

10. **database/insert-test-data.sql**
    - Tous les comptes insérés avec devise XOF

11. **database/update-currency-to-xof.sql** (NOUVEAU)
    - Script pour mettre à jour les comptes existants

12. **database/UPDATE-CURRENCY-XOF.bat** (NOUVEAU)
    - Script batch pour exécuter la mise à jour

### Documentation

13. **API_DOCUMENTATION.md**
    - Exemples mis à jour avec XOF

## Mise à jour de la base de données existante

Si vous avez déjà des données en base avec la devise EUR, exécutez le script de mise à jour :

### Option 1 : Via le script batch (Windows)

```bash
cd database
UPDATE-CURRENCY-XOF.bat
```

### Option 2 : Via MySQL directement

```bash
mysql -u root -p < database/update-currency-to-xof.sql
```

### Option 3 : Via MySQL Workbench

1. Ouvrez MySQL Workbench
2. Connectez-vous à votre serveur
3. Ouvrez le fichier `database/update-currency-to-xof.sql`
4. Exécutez le script

## Format d'affichage

Le format d'affichage dans Angular a été configuré pour :
- **Code devise** : XOF
- **Symbole** : Affiche le symbole de la devise (CFA)
- **Décimales** : 0 (les francs CFA n'utilisent généralement pas de décimales)

Exemple : `5000 XOF` ou `5 000 F CFA`

## Taux de conversion (informatif)

Si vous aviez des données en EUR et souhaitez les convertir :
- **1 EUR ≈ 655.957 XOF** (taux fixe)

Exemple :
- 1000 EUR = 655 957 XOF
- 100 EUR = 65 596 XOF

**Note** : Le script de mise à jour ne convertit PAS les montants, il change uniquement le code devise. Si vous souhaitez convertir les montants, vous devez le faire manuellement.

## Script de conversion des montants (optionnel)

Si vous souhaitez également convertir les montants de EUR à XOF :

```sql
USE willbank_account_db;

-- Convertir les montants (1 EUR = 655.957 XOF)
UPDATE accounts 
SET 
    balance = balance * 655.957,
    currency = 'XOF'
WHERE currency = 'EUR';

-- Vérifier
SELECT account_number, balance, currency FROM accounts;
```

## Vérification

Après la mise à jour, vérifiez que :

1. **Backend** : Les nouveaux comptes sont créés avec XOF
2. **Frontend** : Les montants s'affichent avec le symbole XOF
3. **Base de données** : Tous les comptes ont la devise XOF

```sql
-- Vérifier les devises dans la base
SELECT currency, COUNT(*) as nombre_comptes, SUM(balance) as total
FROM accounts
GROUP BY currency;
```

## Redémarrage nécessaire

Après les modifications :

1. **Redémarrez le Account Service** :
   ```bash
   # Arrêtez le service (Ctrl+C)
   # Redémarrez
   cd account_service
   mvn spring-boot:run
   ```

2. **Rechargez le Frontend** :
   - Rechargez simplement la page (F5)
   - Ou redémarrez le serveur de développement si nécessaire

## Notes importantes

- Le code devise XOF est le code ISO 4217 officiel pour le Franc CFA (BCEAO)
- Le Franc CFA est utilisé dans 8 pays d'Afrique de l'Ouest
- Le taux de change avec l'Euro est fixe : 1 EUR = 655.957 XOF
- Les montants en Franc CFA sont généralement affichés sans décimales

## Support

Si vous rencontrez des problèmes :
1. Vérifiez que tous les services sont redémarrés
2. Vérifiez que la base de données a été mise à jour
3. Videz le cache du navigateur (Ctrl+Shift+Delete)
4. Consultez les logs des services pour les erreurs
