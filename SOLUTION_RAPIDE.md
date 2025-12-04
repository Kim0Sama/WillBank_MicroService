# Solution rapide - Erreur 500 sur login

## Le problème

Vous voyez une erreur 500 dans le navigateur lors de la connexion, mais **le backend fonctionne correctement**.

## La solution (3 étapes)

### 1. Redémarrez le frontend

Le frontend Angular doit être redémarré après les modifications des fichiers TypeScript.

```bash
# Dans le terminal du frontend, appuyez sur Ctrl+C pour arrêter
# Puis redémarrez :
cd Frontend
ng serve
```

Attendez que le message "Compiled successfully" apparaisse.

### 2. Videz le cache du navigateur

**Option A : Hard refresh**
- Windows/Linux : `Ctrl + Shift + R`
- Mac : `Cmd + Shift + R`

**Option B : DevTools**
1. Ouvrez les DevTools (F12)
2. Cliquez droit sur le bouton de rafraîchissement
3. Sélectionnez "Vider le cache et actualiser"

**Option C : Navigation privée**
- Chrome : `Ctrl + Shift + N`
- Firefox : `Ctrl + Shift + P`
- Puis allez sur http://localhost:4200

### 3. Testez la connexion

Connectez-vous avec :
- **Email** : `jean.dupont@example.com`
- **Password** : `password123`

## Vérification

Si vous voyez toujours une erreur :

1. **Ouvrez la console du navigateur** (F12 → Console)
2. **Regardez les erreurs** affichées en rouge
3. **Allez dans Network** (F12 → Network)
4. **Essayez de vous connecter**
5. **Cliquez sur la requête "login"**
6. **Regardez la réponse**

## Test rapide du backend

Pour vérifier que le backend fonctionne :

```powershell
.\test-different-users.ps1
```

Devrait afficher :
```
Test avec: jean.dupont@example.com OK
  User ID: 6
  Name: Jean Dupont
  Role: CLIENT

  Comptes recuperes: X compte(s)
```

## Si ça ne fonctionne toujours pas

### Vérifiez que tous les services sont démarrés

```powershell
.\diagnose-services.ps1
```

Tous les services doivent être "OK" :
- ✅ Eureka Server
- ✅ Gateway
- ✅ Client Service
- ✅ Account Service

### Redémarrez tous les services

```powershell
.\stop-all-services.ps1
.\start-all-services.ps1
```

Attendez 30 secondes que tous les services démarrent.

### Vérifiez les logs

Dans le terminal du **Client Service**, cherchez des erreurs comme :
- `Exception`
- `Error`
- `Failed`

## Utilisateurs de test disponibles

| Email | Password | Role |
|-------|----------|------|
| jean.dupont@example.com | password123 | CLIENT |
| admin@willbank.com | password123 | ADMIN |

## Résumé

1. ✅ Redémarrez le frontend : `cd Frontend && ng serve`
2. ✅ Videz le cache : `Ctrl + Shift + R`
3. ✅ Testez : jean.dupont@example.com / password123

Le backend fonctionne. Le problème vient du cache ou du frontend qui n'a pas été redémarré.
