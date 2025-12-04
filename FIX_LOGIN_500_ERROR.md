# Fix: Erreur 500 sur le login

## Diagnostic

L'erreur 500 apparaît dans le frontend Angular, mais les tests montrent que **le backend fonctionne correctement**.

### Tests effectués ✅

1. ✅ Le Gateway répond (port 8080)
2. ✅ Le Client Service répond (port 8082)
3. ✅ Le login via PowerShell fonctionne
4. ✅ Le login via curl fonctionne
5. ✅ Le proxy Angular est configuré

## Causes possibles

### 1. Le frontend n'a pas été redémarré

Après les modifications des fichiers TypeScript, Angular doit être redémarré.

**Solution** :
```bash
# Arrêtez le frontend (Ctrl+C dans son terminal)
cd Frontend
ng serve
```

### 2. Cache du navigateur

Le navigateur peut avoir mis en cache une ancienne version.

**Solution** :
- Ouvrez les DevTools (F12)
- Faites un clic droit sur le bouton de rafraîchissement
- Sélectionnez "Vider le cache et actualiser"

Ou en navigation privée :
- Ctrl+Shift+N (Chrome) ou Ctrl+Shift+P (Firefox)
- Allez sur http://localhost:4200

### 3. Erreur dans la console du navigateur

**Vérification** :
1. Ouvrez la console du navigateur (F12)
2. Allez dans l'onglet "Console"
3. Essayez de vous connecter
4. Regardez les erreurs affichées

**Vérification Network** :
1. Ouvrez l'onglet "Network" dans les DevTools
2. Essayez de vous connecter
3. Cliquez sur la requête "login"
4. Regardez :
   - Request Headers
   - Request Payload
   - Response

### 4. CORS (peu probable vu la config)

Le Gateway est configuré pour accepter les requêtes depuis `http://localhost:4200`.

**Vérification** :
```yaml
# gateway_service/src/main/resources/application.yaml
spring:
  cloud:
    gateway:
      globalcors:
        corsConfigurations:
          '[/**]':
            allowedOrigins: "http://localhost:4200"
```

## Test manuel

### Test 1 : Via curl

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"jean.dupont@example.com","password":"password123"}'
```

Devrait retourner :
```json
{
  "token": "eyJ...",
  "userId": 6,
  "email": "jean.dupont@example.com",
  "firstName": "Jean",
  "lastName": "Dupont",
  "role": "CLIENT"
}
```

### Test 2 : Via PowerShell

```powershell
.\test-different-users.ps1
```

### Test 3 : Via le navigateur

Ouvrez la console du navigateur et exécutez :

```javascript
fetch('http://localhost:8080/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    email: 'jean.dupont@example.com',
    password: 'password123'
  })
})
.then(r => r.json())
.then(data => console.log('Success:', data))
.catch(err => console.error('Error:', err));
```

## Solution rapide

1. **Redémarrez le frontend** :
   ```bash
   cd Frontend
   # Ctrl+C pour arrêter
   ng serve
   ```

2. **Videz le cache du navigateur** :
   - F12 → Network → Disable cache (cochez la case)
   - Ou utilisez la navigation privée

3. **Vérifiez la console** :
   - F12 → Console
   - Regardez les erreurs

4. **Testez avec les identifiants** :
   - Email: `jean.dupont@example.com`
   - Password: `password123`

## Si le problème persiste

### Vérifiez les logs

**Client Service** :
```bash
cd Client_service
# Regardez les logs dans le terminal où le service tourne
```

Cherchez des erreurs comme :
- `NullPointerException`
- `BadCredentialsException`
- `DataAccessException`

**Gateway** :
```bash
# Regardez les logs du Gateway
```

### Vérifiez la base de données

```sql
USE willbank_client_db;

SELECT id, email, first_name, last_name, status, kyc_status, 
       LENGTH(password) as password_length
FROM clients 
WHERE email = 'jean.dupont@example.com';
```

Devrait retourner :
- `status` = 'ACTIVE'
- `kyc_status` = 'VERIFIED'
- `password_length` = 60 (hash BCrypt)

### Recréez l'utilisateur

Si l'utilisateur est corrompu :

```sql
USE willbank_client_db;

DELETE FROM clients WHERE email = 'jean.dupont@example.com';

INSERT INTO clients (
    first_name, last_name, email, password, role,
    phone_number, address, city, postal_code, country,
    date_of_birth, national_id, status, kyc_status,
    created_at, updated_at
) VALUES (
    'Jean', 'Dupont', 'jean.dupont@example.com',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.rsS3/r/7HNtBJFgEy2',
    'CLIENT', '+33612345678', '123 Rue de la Paix', 'Paris',
    '75001', 'France', '1990-05-15', 'FR1234567890',
    'ACTIVE', 'VERIFIED', NOW(), NOW()
);
```

## Résumé

Le backend fonctionne. Le problème vient probablement :
1. Du cache du navigateur
2. Du frontend qui n'a pas été redémarré
3. D'une erreur JavaScript dans la console

**Action immédiate** : Redémarrez le frontend et videz le cache du navigateur.
