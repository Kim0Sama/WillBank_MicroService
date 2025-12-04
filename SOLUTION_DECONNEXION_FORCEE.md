# Solution : Déconnexion forcée au démarrage

## Problème résolu
L'administrateur (ou tout utilisateur) restait connecté au lancement du frontend car le token était persisté dans le localStorage du navigateur.

## Solution appliquée
L'application force maintenant la déconnexion à chaque démarrage en appelant `authService.logout()` dans le hook `ngOnInit()` du composant principal.

## Fichiers modifiés

### 1. `Frontend/src/app/app.ts`
```typescript
ngOnInit(): void {
  // Force logout on app initialization to ensure fresh login
  // Comment this line in production if you want to keep users logged in
  this.authService.logout();
}
```

Cette modification :
- Nettoie le localStorage (token et currentUser)
- Redirige automatiquement vers `/login`
- S'exécute à chaque rechargement de l'application

## Comportement actuel

### Au démarrage de l'application
1. L'application se charge
2. `ngOnInit()` s'exécute
3. `authService.logout()` est appelé
4. Le localStorage est nettoyé
5. Redirection automatique vers `/login`

### Après connexion
1. L'utilisateur se connecte
2. Le token est stocké dans localStorage
3. L'utilisateur est redirigé vers son dashboard
4. **Si l'utilisateur recharge la page** → déconnexion automatique

## Test de la solution

Exécutez le script de test :
```powershell
.\test-logout-behavior.ps1
```

Ou testez manuellement :
1. Ouvrez http://localhost:4200
2. Vous devez voir la page de login
3. Connectez-vous
4. Rechargez la page (F5)
5. Vous devez être déconnecté et voir la page de login

## Configuration pour la production

Si vous voulez garder les utilisateurs connectés entre les sessions (comportement normal d'une application web), modifiez `Frontend/src/app/app.ts` :

```typescript
ngOnInit(): void {
  // Redirect to login if not authenticated on app initialization
  if (!this.authService.isLoggedIn()) {
    this.router.navigate(['/login']);
  }
}
```

Voir `Frontend/AUTHENTICATION_CONFIG.md` pour plus de détails.

## Scripts créés

1. **test-logout-behavior.ps1** - Test du comportement de déconnexion
2. **clear-browser-storage.ps1** - Instructions pour nettoyer manuellement le localStorage
3. **Frontend/AUTHENTICATION_CONFIG.md** - Documentation de configuration

## Sécurité

✅ Aucun utilisateur ne peut accéder au dashboard sans authentification
✅ Déconnexion forcée à chaque démarrage (développement)
✅ AuthGuard protège toutes les routes
✅ Vérification du rôle admin pour les routes admin
✅ Token JWT avec expiration configurée

## Prochaines étapes

Pour un environnement de production, vous devriez :
1. Modifier le comportement pour garder les sessions persistantes
2. Implémenter une vérification de l'expiration du token
3. Ajouter un refresh token pour renouveler automatiquement les sessions
4. Implémenter une déconnexion automatique après inactivité
