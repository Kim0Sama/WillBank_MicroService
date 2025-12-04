# Correction des boutons admin (Activer, Suspendre, Vérifier KYC)

## Problème identifié
Les boutons "Activer", "Suspendre" et "Vérifier KYC" dans la page admin des clients ne fonctionnaient pas car :
1. Les méthodes utilisaient directement `http.put` avec un mauvais endpoint
2. Le format des données envoyées ne correspondait pas à ce que le backend attendait
3. Les endpoints corrects n'étaient pas utilisés

## Solution appliquée

### 1. Ajout des méthodes dans AdminService
Ajout de deux nouvelles méthodes dans `Frontend/src/app/services/admin.service.ts` :

```typescript
updateClientStatus(id: number, status: string): Observable<any> {
  return this.http.patch<any>(`/api/clients/${id}/status?status=${status}`, {});
}

updateClientKycStatus(id: number, kycStatus: string, notes?: string): Observable<any> {
  return this.http.patch<any>(`/api/clients/${id}/kyc`, { kycStatus, notes });
}
```

### 2. Correction du composant AdminClients
Dans `Frontend/src/app/pages/admin/admin-clients/admin-clients.component.ts` :

- Import du `AdminService`
- Injection du service dans le constructeur
- Utilisation des méthodes du service au lieu de `http.put` direct
- Ajout de logs d'erreur dans la console pour faciliter le débogage

### 3. Endpoints backend utilisés
Les boutons utilisent maintenant les bons endpoints :

- **Activer/Suspendre** : `PATCH /api/clients/{id}/status?status={status}`
- **Vérifier KYC** : `PATCH /api/clients/{id}/kyc` avec body `{ kycStatus, notes }`

## Fichiers modifiés

1. `Frontend/src/app/services/admin.service.ts` - Ajout des méthodes de mise à jour
2. `Frontend/src/app/pages/admin/admin-clients/admin-clients.component.ts` - Correction des appels API

## Test de la correction

### Test automatique
Exécutez le script de test :
```powershell
.\test-admin-buttons.ps1
```

Ce script teste :
- ✅ Connexion en tant qu'admin
- ✅ Récupération de la liste des clients
- ✅ Mise à jour du statut (Activer)
- ✅ Suspension du client
- ✅ Vérification KYC

### Test manuel dans le frontend

1. **Connectez-vous en tant qu'admin** :
   - Email: `admin@willbank.com`
   - Password: `admin123`

2. **Allez dans Admin > Clients**

3. **Cliquez sur "👁️ Voir"** pour un client

4. **Testez les boutons** :
   - **Activer** : Change le statut à ACTIVE
   - **Suspendre** : Change le statut à SUSPENDED
   - **Vérifier KYC** : Change le statut KYC à VERIFIED

5. **Vérifiez** :
   - Un message de confirmation s'affiche
   - La liste des clients se recharge
   - Le modal se ferme
   - Les changements sont visibles dans la liste

## Débogage

Si les boutons ne fonctionnent toujours pas :

1. **Ouvrez la console du navigateur** (F12)
   - Vérifiez les erreurs JavaScript
   - Vérifiez les erreurs de requêtes HTTP (onglet Network)

2. **Vérifiez l'authentification** :
   - Assurez-vous d'être connecté en tant qu'admin
   - Vérifiez que le token est présent dans localStorage

3. **Vérifiez les services backend** :
   - Client Service doit être démarré sur le port 8081
   - Gateway doit être démarré sur le port 8080

4. **Redémarrez le frontend** :
   ```bash
   cd Frontend
   ng serve
   ```

## Statuts disponibles

### Statuts client
- `ACTIVE` - Client actif
- `PENDING` - En attente
- `SUSPENDED` - Suspendu
- `CLOSED` - Fermé

### Statuts KYC
- `VERIFIED` - Vérifié
- `PENDING_VERIFICATION` - En attente de vérification
- `REJECTED` - Rejeté

## Prochaines améliorations possibles

1. Ajouter des confirmations avant les actions critiques (suspension, etc.)
2. Ajouter un champ de notes pour expliquer les changements de statut
3. Afficher l'historique des changements de statut
4. Ajouter des notifications toast au lieu d'alertes
5. Ajouter la possibilité de rejeter un KYC avec une raison
