# Fix: Service de création de compte

## Problème identifié

Le service de création de compte ne fonctionnait pas à cause d'une **incompatibilité de noms de champs** entre le frontend et le backend.

### Détails du problème

- **Frontend** : Envoyait `initialDeposit` dans la requête
- **Backend** : Attendait `initialBalance` dans le DTO

## Solution appliquée ✅

### 1. Modèle TypeScript mis à jour

**Fichier** : `Frontend/src/app/models/account.model.ts`

```typescript
export interface CreateAccountRequest {
  customerId: number;
  accountType: 'SAVINGS' | 'CHECKING' | 'BUSINESS';
  initialBalance: number;  // ✅ Changé de initialDeposit à initialBalance
}
```

### 2. Composant mis à jour

**Fichier** : `Frontend/src/app/pages/accounts/accounts.component.ts`

- Changé `createForm.initialDeposit` → `createForm.initialBalance`
- Mis à jour toutes les références dans le code

### 3. Template HTML mis à jour

**Fichier** : `Frontend/src/app/pages/accounts/accounts.component.html`

- Changé `[(ngModel)]="createForm.initialDeposit"` → `[(ngModel)]="createForm.initialBalance"`

## Prérequis pour créer un compte

Le backend vérifie que :

1. ✅ Le client existe
2. ✅ Le client a le statut `ACTIVE`
3. ✅ Le KYC du client est `VERIFIED`

Si ces conditions ne sont pas remplies, la création échouera.

## Test de la solution

### Option 1 : Via le script PowerShell

```powershell
.\test-account-creation.ps1
```

Ce script va :
- Se connecter avec jean.dupont@example.com
- Vérifier le statut du client
- Créer un compte de test
- Afficher les comptes existants

### Option 2 : Via le frontend

1. **Redémarrez le frontend** (si déjà démarré) :
   ```bash
   # Dans le terminal du frontend, arrêtez (Ctrl+C) puis :
   cd Frontend
   ng serve
   ```

2. **Ouvrez le navigateur** : http://localhost:4200

3. **Connectez-vous** :
   - Email: jean.dupont@example.com
   - Password: password123

4. **Allez dans "Accounts"**

5. **Cliquez sur "+ New Account"**

6. **Remplissez le formulaire** :
   - Account Type: Checking Account
   - Initial Deposit: 1000
   - Cliquez sur "Create Account"

7. **Vérifiez** : Le compte devrait apparaître dans la liste

## Si le problème persiste

### Erreur : "Client is not active"

Le client doit avoir le statut ACTIVE. Vérifiez dans la base de données :

```sql
USE willbank_client_db;
SELECT id, email, status, kyc_status FROM clients WHERE email = 'jean.dupont@example.com';
```

Si le statut n'est pas correct, mettez-le à jour :

```sql
UPDATE clients 
SET status = 'ACTIVE', kyc_status = 'VERIFIED' 
WHERE email = 'jean.dupont@example.com';
```

### Erreur : "Client KYC is not verified"

Même solution que ci-dessus.

### Erreur : "Unable to validate client"

Le Account Service ne peut pas contacter le Client Service. Vérifiez :

1. Que le Client Service est démarré
2. Que Eureka est démarré
3. Que les services sont enregistrés dans Eureka

```powershell
.\diagnose-services.ps1
```

### Erreur 401 (Non autorisé)

Le token JWT n'est pas valide. Assurez-vous que :

1. Le Client Service a été redémarré après le fix du secret JWT
2. Vous vous êtes reconnecté pour obtenir un nouveau token

## Vérification de la base de données

Pour vérifier que les clients de test ont les bons statuts :

```sql
USE willbank_client_db;

SELECT 
    id,
    email,
    first_name,
    last_name,
    status,
    kyc_status
FROM clients 
WHERE email IN ('jean.dupont@example.com', 'admin@willbank.com', 'marie.martin@example.com');
```

Tous devraient avoir :
- `status` = 'ACTIVE'
- `kyc_status` = 'VERIFIED'

Si ce n'est pas le cas, exécutez :

```sql
UPDATE clients 
SET status = 'ACTIVE', kyc_status = 'VERIFIED' 
WHERE email IN ('jean.dupont@example.com', 'admin@willbank.com', 'marie.martin@example.com');
```

## Résumé des changements

| Fichier | Changement |
|---------|-----------|
| `Frontend/src/app/models/account.model.ts` | `initialDeposit` → `initialBalance` |
| `Frontend/src/app/pages/accounts/accounts.component.ts` | Toutes les références mises à jour |
| `Frontend/src/app/pages/accounts/accounts.component.html` | ngModel mis à jour |

Le frontend envoie maintenant les bonnes données au backend, et la création de compte devrait fonctionner correctement.
