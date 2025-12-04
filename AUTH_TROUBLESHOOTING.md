# Guide de Dépannage - Authentification WillBank

## Erreur: "Email ou mot de passe incorrect"

### Causes possibles

1. **Les utilisateurs n'existent pas dans la base de données**
2. **Le mot de passe n'est pas correctement hashé**
3. **Le Client Service n'est pas démarré**
4. **Le Gateway ne route pas correctement**

### Solution Rapide

#### Étape 1: Créer les utilisateurs de test

Exécutez le script batch dans le dossier `database` :

```cmd
cd database
execute-test-user.bat
```

Entrez le mot de passe root MySQL quand demandé.

#### Étape 2: Vérifier que les services sont démarrés

```powershell
netstat -ano | findstr "8080 8084 8761"
```

Vous devriez voir :
- Port 8761 (Eureka)
- Port 8080 (Gateway)
- Port 8084 (Client Service)

Si un port manque, démarrez les services :

```powershell
.\start-services-clean.ps1
```

#### Étape 3: Tester l'authentification

Utilisez ces credentials :

**Utilisateur normal:**
- Email: `jean.dupont@example.com`
- Password: `password123`

**Administrateur:**
- Email: `admin@willbank.com`
- Password: `password123`

## Vérification Manuelle

### 1. Vérifier que MySQL est démarré

```powershell
Get-Service MySQL80
```

Si le service n'est pas démarré :

```powershell
Start-Service MySQL80
```

### 2. Vérifier la base de données

Ouvrez MySQL Workbench et exécutez :

```sql
USE willbank_client_db;

SELECT id, first_name, last_name, email, role, status 
FROM clients 
WHERE email IN ('jean.dupont@example.com', 'admin@willbank.com');
```

Vous devriez voir 2 utilisateurs.

### 3. Tester l'API directement

#### Via le Gateway (recommandé)

```powershell
curl -X POST http://localhost:8080/api/auth/login `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"jean.dupont@example.com\",\"password\":\"password123\"}'
```

#### Directement sur le Client Service

```powershell
curl -X POST http://localhost:8084/api/auth/login `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"jean.dupont@example.com\",\"password\":\"password123\"}'
```

### 4. Vérifier les logs

Regardez les logs dans les consoles PowerShell des services :

- **Client Service**: Recherchez "AuthController" ou "login"
- **Gateway Service**: Recherchez "auth-service" ou erreurs de routage

## Problèmes Courants

### Le Frontend ne peut pas se connecter au backend

**Symptôme**: Erreur CORS ou "Connection refused"

**Solution**:
1. Vérifiez que le Gateway est démarré sur le port 8080
2. Vérifiez que le Frontend est configuré pour utiliser `http://localhost:8080`
3. Vérifiez la configuration CORS dans `gateway_service/src/main/resources/application.yaml`

### Le token JWT n'est pas valide

**Symptôme**: "Invalid token" ou "Unauthorized"

**Solution**:
1. Vérifiez que la clé secrète JWT est la même dans :
   - `Client_service/src/main/resources/application.yaml`
   - `gateway_service/src/main/resources/application.yaml`
2. Les deux doivent avoir :
   ```yaml
   jwt:
     secret: WillBankSecretKeyForJWTTokenGenerationAndValidation2024!MustBeLongEnough
     expiration: 86400000
   ```

### Le mot de passe n'est pas reconnu

**Symptôme**: Toujours "Invalid email or password" même avec les bons credentials

**Solution**:
1. Vérifiez que le mot de passe est hashé avec BCrypt
2. Le hash pour "password123" doit être : `$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.rsS3/r/7HNtBJFgEy2`
3. Réexécutez le script `create-test-user.sql`

### Eureka ne voit pas le Client Service

**Symptôme**: Gateway ne peut pas router vers CLIENT-SERVICE

**Solution**:
1. Ouvrez http://localhost:8761
2. Vérifiez que CLIENT-SERVICE est enregistré
3. Si non, redémarrez le Client Service
4. Attendez 30 secondes pour l'enregistrement

## Commandes Utiles

### Redémarrer tous les services

```powershell
.\stop-services.ps1
.\start-services-clean.ps1
```

### Voir les processus Java en cours

```powershell
Get-Process java
```

### Tuer tous les processus Java

```powershell
Get-Process java | Stop-Process -Force
```

### Vérifier les ports utilisés

```powershell
netstat -ano | findstr "LISTENING"
```

## Credentials par Défaut

Tous les utilisateurs créés par les scripts ont le mot de passe : **password123**

| Email | Role | Description |
|-------|------|-------------|
| jean.dupont@example.com | CLIENT | Utilisateur normal |
| admin@willbank.com | ADMIN | Administrateur |

## Support

Si le problème persiste :

1. Vérifiez les logs dans les consoles PowerShell
2. Vérifiez que MySQL est accessible
3. Vérifiez que tous les services sont enregistrés dans Eureka
4. Consultez le fichier `TROUBLESHOOTING.md` pour d'autres problèmes
