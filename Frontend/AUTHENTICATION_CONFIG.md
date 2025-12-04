# Configuration de l'authentification

## Comportement actuel

L'application force maintenant la déconnexion à chaque démarrage pour garantir que tous les utilisateurs passent par la page de login.

## Modifier le comportement

### Pour le développement (déconnexion forcée)
Dans `Frontend/src/app/app.ts`, utilisez :

```typescript
ngOnInit(): void {
  // Force logout on app initialization to ensure fresh login
  this.authService.logout();
}
```

### Pour la production (session persistante)
Dans `Frontend/src/app/app.ts`, utilisez :

```typescript
ngOnInit(): void {
  // Redirect to login if not authenticated on app initialization
  if (!this.authService.isLoggedIn()) {
    this.router.navigate(['/login']);
  }
}
```

## Nettoyer manuellement le localStorage

Si vous voulez déconnecter un utilisateur sans modifier le code :

### Via la console du navigateur (F12)
```javascript
localStorage.clear();
location.reload();
```

### Via les DevTools
1. Ouvrir DevTools (F12)
2. Aller dans l'onglet 'Application' ou 'Storage'
3. Cliquer sur 'Local Storage' > 'http://localhost:4200'
4. Supprimer les clés 'token' et 'currentUser'
5. Recharger la page (F5)

### Mode navigation privée
Ouvrir le frontend en mode navigation privée (Ctrl+Shift+N dans Chrome/Edge)

## Sécurité

Le système d'authentification vérifie :
- ✅ Présence du token dans localStorage
- ✅ Autorisation via AuthGuard sur toutes les routes protégées
- ✅ Vérification du rôle admin pour les routes admin
- ✅ Redirection automatique vers login si non authentifié
- ✅ Interception des requêtes HTTP pour ajouter le token

## Durée de vie du token

Le token JWT a une durée de vie configurée dans le backend :
- Voir `Client_service/src/main/java/com/willbank/client/config/JwtUtil.java`
- Par défaut : 24 heures (86400000 ms)

Pour modifier la durée de vie, changez la valeur dans `JwtUtil.java` :
```java
private static final long JWT_TOKEN_VALIDITY = 24 * 60 * 60 * 1000; // 24 heures
```
