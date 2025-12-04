# Guide de test manuel des boutons admin

## Prérequis

1. **Démarrer tous les services** :
   ```powershell
   .\start-all-services.ps1
   ```

2. **Démarrer le frontend** :
   ```bash
   cd Frontend
   ng serve
   ```

3. **Attendre que tous les services soient prêts** (environ 30 secondes)

## Test des boutons

### Étape 1 : Connexion admin

1. Ouvrez http://localhost:4200
2. Vous devez être redirigé vers `/login`
3. Connectez-vous avec :
   - **Email** : `admin@willbank.com`
   - **Password** : `admin123`
4. Vous devez être redirigé vers `/admin`

### Étape 2 : Accéder à la gestion des clients

1. Dans la sidebar, cliquez sur **"Clients"**
2. Vous devez voir la liste de tous les clients
3. Notez les informations d'un client (statut, KYC)

### Étape 3 : Tester le bouton "Voir"

1. Cliquez sur **"👁️ Voir"** pour un client
2. Un modal doit s'ouvrir avec les détails du client
3. Vous devez voir trois boutons en bas :
   - **Activer** (bleu)
   - **Suspendre** (orange)
   - **Vérifier KYC** (vert)

### Étape 4 : Tester le bouton "Activer"

1. Cliquez sur **"Activer"**
2. **Résultat attendu** :
   - ✅ Message : "Statut du client mis à jour avec succès"
   - ✅ Le modal se ferme
   - ✅ La liste se recharge
   - ✅ Le statut du client est maintenant "ACTIVE"

### Étape 5 : Tester le bouton "Suspendre"

1. Cliquez à nouveau sur **"👁️ Voir"** pour le même client
2. Cliquez sur **"Suspendre"**
3. **Résultat attendu** :
   - ✅ Message : "Statut du client mis à jour avec succès"
   - ✅ Le modal se ferme
   - ✅ La liste se recharge
   - ✅ Le statut du client est maintenant "SUSPENDED"

### Étape 6 : Tester le bouton "Vérifier KYC"

1. Cliquez à nouveau sur **"👁️ Voir"** pour le même client
2. Cliquez sur **"Vérifier KYC"**
3. **Résultat attendu** :
   - ✅ Message : "Statut KYC mis à jour avec succès"
   - ✅ Le modal se ferme
   - ✅ La liste se recharge
   - ✅ Le statut KYC du client est maintenant "VERIFIED"

## Débogage en cas de problème

### Si les boutons ne font rien

1. **Ouvrez la console du navigateur** (F12)
2. **Cliquez sur un bouton**
3. **Vérifiez les erreurs** :
   - Erreurs JavaScript dans l'onglet "Console"
   - Erreurs HTTP dans l'onglet "Network"

### Erreurs courantes

#### Erreur 401 (Non autorisé)
- **Cause** : Token expiré ou invalide
- **Solution** : Déconnectez-vous et reconnectez-vous

#### Erreur 403 (Interdit)
- **Cause** : Vous n'êtes pas admin
- **Solution** : Connectez-vous avec le compte admin

#### Erreur 404 (Non trouvé)
- **Cause** : Endpoint incorrect
- **Solution** : Vérifiez que le Client Service est démarré

#### Erreur 500 (Erreur serveur)
- **Cause** : Erreur backend
- **Solution** : Vérifiez les logs du Client Service

### Vérifier les logs backend

```powershell
# Vérifier les logs du Client Service
Get-Content Client_service/logs/application.log -Tail 50
```

### Vérifier les requêtes HTTP

1. Ouvrez DevTools (F12)
2. Allez dans l'onglet **"Network"**
3. Cliquez sur un bouton
4. Vérifiez la requête :
   - **URL** : Doit être `/api/clients/{id}/status` ou `/api/clients/{id}/kyc`
   - **Method** : Doit être `PATCH`
   - **Headers** : Doit contenir `Authorization: Bearer {token}`
   - **Response** : Vérifiez le code de statut et le body

## Test avec le script PowerShell

Si les services sont démarrés, vous pouvez tester les endpoints directement :

```powershell
.\test-admin-buttons.ps1
```

Ce script teste automatiquement tous les endpoints.

## Vérification dans la base de données

Pour vérifier que les changements sont bien enregistrés :

```sql
-- Connectez-vous à MySQL
mysql -u root -p

-- Sélectionnez la base de données
USE client_db;

-- Vérifiez le statut d'un client
SELECT id, first_name, last_name, email, status, kyc_status 
FROM clients 
WHERE id = 1;
```

## Résultat attendu final

Après tous les tests, vous devriez avoir :
- ✅ Les boutons fonctionnent correctement
- ✅ Les statuts sont mis à jour dans la base de données
- ✅ Les messages de confirmation s'affichent
- ✅ La liste se recharge automatiquement
- ✅ Aucune erreur dans la console

## En cas de problème persistant

1. **Redémarrez le frontend** :
   ```bash
   cd Frontend
   # Arrêtez avec Ctrl+C
   ng serve
   ```

2. **Videz le cache du navigateur** :
   - Chrome/Edge : Ctrl+Shift+Delete
   - Cochez "Cached images and files"
   - Cliquez sur "Clear data"

3. **Vérifiez que les modifications sont bien appliquées** :
   - Ouvrez `Frontend/src/app/services/admin.service.ts`
   - Vérifiez que les méthodes `updateClientStatus` et `updateClientKycStatus` existent

4. **Contactez le support** avec :
   - Les erreurs de la console
   - Les logs du backend
   - Les captures d'écran
