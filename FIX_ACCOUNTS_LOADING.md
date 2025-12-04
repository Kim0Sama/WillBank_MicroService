# Fix: Erreur de chargement des comptes

## Problème identifié

L'erreur "Failed to load accounts" vient de deux problèmes :

1. **Secret JWT différent** : Le Client Service et le Gateway utilisaient des secrets JWT différents
2. **Pas de comptes** : Les utilisateurs de test n'ont pas de comptes dans la base de données

## Solution appliquée

### 1. Secret JWT unifié ✅

Le fichier `Client_service/src/main/resources/application.yaml` a été mis à jour pour utiliser le même secret JWT que le Gateway :

```yaml
jwt:
  secret: WillBankSecretKey2024VeryLongSecretKeyForJWTTokenGeneration123456789
  expiration: 86400000
```

### 2. Redémarrer le Client Service

**IMPORTANT** : Vous devez redémarrer le Client Service pour que le changement prenne effet.

```powershell
# Dans le terminal du Client Service, arrêtez-le (Ctrl+C) puis redémarrez :
cd Client_service
mvnw spring-boot:run
```

### 3. Tester la connexion

Une fois le Client Service redémarré, exécutez ce script pour tester :

```powershell
.\test-different-users.ps1
```

Vous devriez voir :
- ✅ Connexion réussie pour jean.dupont@example.com
- ✅ Comptes récupérés (ou message "0 comptes" si pas encore créés)

### 4. Créer des comptes

Si l'utilisateur n'a pas de comptes, vous pouvez :

**Option A : Via le frontend**
1. Connectez-vous avec jean.dupont@example.com / password123
2. Allez dans "Accounts"
3. Cliquez sur "+ New Account"
4. Créez un compte

**Option B : Via l'API**
Exécutez le script :
```powershell
.\create-accounts-via-api.ps1
```

**Option C : Via SQL**
```powershell
cd database
.\create-accounts.ps1
```

## Vérification finale

1. **Démarrez le frontend** (si pas déjà fait) :
   ```powershell
   cd Frontend
   ng serve
   ```

2. **Ouvrez le navigateur** : http://localhost:4200

3. **Connectez-vous** :
   - Email: jean.dupont@example.com
   - Password: password123

4. **Vérifiez** :
   - Le dashboard doit charger sans erreur
   - Les comptes doivent s'afficher (ou message "No accounts found" si aucun compte)
   - Vous pouvez créer un nouveau compte

## Utilisateurs de test disponibles

| Email | Password | Role | ID |
|-------|----------|------|-----|
| jean.dupont@example.com | password123 | CLIENT | 6 |
| admin@willbank.com | password123 | ADMIN | 7 |
| marie.martin@example.com | password123 | CLIENT | 8 |

## Si le problème persiste

1. Vérifiez que tous les services sont démarrés :
   ```powershell
   .\diagnose-services.ps1
   ```

2. Vérifiez les logs du Client Service pour voir les erreurs JWT

3. Vérifiez que le secret JWT est identique dans :
   - `Client_service/src/main/resources/application.yaml`
   - `gateway_service/src/main/resources/application.yaml`

4. Redémarrez TOUS les services :
   ```powershell
   .\stop-all-services.ps1
   .\start-all-services.ps1
   ```
