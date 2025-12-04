# 🔧 Correction Rapide du Problème de Login

## ❌ Problème Actuel

- Erreur 404 sur `/api/auth/login` → **RÉSOLU** ✅
- "Invalid email or password" → **À CORRIGER**

## ✅ Solution en 3 Étapes

### Étape 1: Redémarrer le Frontend avec le Proxy

Le proxy Angular n'était pas activé. C'est maintenant corrigé.

**Arrête le serveur Angular (Ctrl+C) et redémarre :**

```powershell
cd Frontend
npm start
```

### Étape 2: Créer les Utilisateurs dans la Base de Données

**Exécute ce script :**

```cmd
cd database
EXECUTE-AUTH-SETUP.bat
```

Ou en PowerShell :

```powershell
cd database
.\EXECUTE-AUTH-SETUP.ps1
```

**Entre le mot de passe root MySQL quand demandé.**

### Étape 3: Tester la Connexion

1. Ouvre http://localhost:4200/login
2. Connecte-toi avec :
   - Email: `jean.dupont@example.com`
   - Password: `password123`

## 🎯 Ce qui a été Corrigé

### 1. Configuration du Proxy Angular

**Avant :**
```json
"serve": {
  "builder": "@angular/build:dev-server",
  "configurations": { ... }
}
```

**Après :**
```json
"serve": {
  "builder": "@angular/build:dev-server",
  "options": {
    "proxyConfig": "proxy.conf.json"  ← AJOUTÉ
  },
  "configurations": { ... }
}
```

### 2. Le Proxy Redirige Maintenant

- Frontend : `http://localhost:4200/api/auth/login`
- Proxy → Gateway : `http://localhost:8080/api/auth/login`
- Gateway → Client Service : `http://localhost:8084/api/auth/login`

## ✅ Vérification

### Vérifier que le Gateway répond

```powershell
curl.exe http://localhost:8080/api/auth/login
```

Devrait retourner une erreur 405 (Method Not Allowed) car GET n'est pas supporté.

### Vérifier que les services sont enregistrés

Ouvre http://localhost:8761 et vérifie que tu vois :
- CLIENT-SERVICE
- GATEWAY-SERVICE

## 🐛 Si ça ne Marche Toujours Pas

### 1. Vérifier la Console du Navigateur

Ouvre les DevTools (F12) et regarde l'onglet Network :
- L'URL appelée doit être : `http://localhost:4200/api/auth/login`
- Le statut doit être 401 (Unauthorized) et non 404

### 2. Vérifier les Logs du Gateway

Regarde la console PowerShell du Gateway Service et cherche :
```
Routing to: lb://CLIENT-SERVICE
```

### 3. Vérifier les Logs du Client Service

Regarde la console PowerShell du Client Service et cherche :
```
AuthController - login attempt for: jean.dupont@example.com
```

## 📋 Checklist Complète

- [x] Services backend démarrés (8080, 8084, 8761)
- [x] Proxy Angular configuré
- [ ] Frontend redémarré avec le proxy
- [ ] Script SQL exécuté (EXECUTE-AUTH-SETUP.bat)
- [ ] Test de connexion réussi

## 🎉 Après la Correction

Tu pourras :
- ✅ Te connecter avec jean.dupont@example.com
- ✅ Te connecter avec admin@willbank.com
- ✅ Accéder au dashboard client
- ✅ Accéder au dashboard admin

## 💡 Note Importante

**Le Frontend DOIT être redémarré** après la modification de `angular.json` pour que le proxy soit activé !

```powershell
# Dans le terminal du Frontend, appuie sur Ctrl+C
# Puis relance :
npm start
```
