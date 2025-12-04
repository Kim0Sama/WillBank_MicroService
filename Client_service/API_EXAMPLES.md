# Exemples d'utilisation de l'API Client Service

## Prérequis
- Le service doit être démarré sur le port 8081
- Utiliser curl ou Postman pour tester les endpoints

## 1. Créer un nouveau client

```bash
curl -X POST http://localhost:8081/api/clients \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Alice",
    "lastName": "Durand",
    "email": "alice.durand@example.com",
    "phoneNumber": "+33678901234",
    "address": "10 Rue de la Paix",
    "city": "Paris",
    "postalCode": "75002",
    "country": "France",
    "dateOfBirth": "1992-06-15",
    "nationalId": "1920615678901"
  }'
```

## 2. Récupérer tous les clients

```bash
curl -X GET http://localhost:8081/api/clients
```

## 3. Récupérer un client par ID

```bash
curl -X GET http://localhost:8081/api/clients/1
```

## 4. Récupérer un client par email

```bash
curl -X GET http://localhost:8081/api/clients/email/jean.dupont@example.com
```

## 5. Récupérer les clients par statut

```bash
# Clients actifs
curl -X GET http://localhost:8081/api/clients/status/ACTIVE

# Clients en attente
curl -X GET http://localhost:8081/api/clients/status/PENDING

# Clients suspendus
curl -X GET http://localhost:8081/api/clients/status/SUSPENDED
```

## 6. Récupérer les clients par statut KYC

```bash
# Clients vérifiés
curl -X GET http://localhost:8081/api/clients/kyc-status/VERIFIED

# Clients en cours de vérification
curl -X GET http://localhost:8081/api/clients/kyc-status/PENDING_VERIFICATION

# Clients rejetés
curl -X GET http://localhost:8081/api/clients/kyc-status/REJECTED
```

## 7. Mettre à jour les informations d'un client

```bash
curl -X PUT http://localhost:8081/api/clients/1 \
  -H "Content-Type: application/json" \
  -d '{
    "phoneNumber": "+33699887766",
    "address": "20 Avenue des Champs-Élysées",
    "city": "Paris",
    "postalCode": "75008"
  }'
```

## 8. Mettre à jour le statut d'un client

```bash
# Activer un client
curl -X PATCH "http://localhost:8081/api/clients/1/status?status=ACTIVE"

# Suspendre un client
curl -X PATCH "http://localhost:8081/api/clients/1/status?status=SUSPENDED"

# Fermer un compte client
curl -X PATCH "http://localhost:8081/api/clients/1/status?status=CLOSED"
```

## 9. Mettre à jour le statut KYC d'un client

```bash
# Vérifier un client
curl -X PATCH http://localhost:8081/api/clients/1/kyc \
  -H "Content-Type: application/json" \
  -d '{
    "kycStatus": "VERIFIED",
    "notes": "Documents vérifiés avec succès"
  }'

# Rejeter la vérification KYC
curl -X PATCH http://localhost:8081/api/clients/2/kyc \
  -H "Content-Type: application/json" \
  -d '{
    "kycStatus": "REJECTED",
    "notes": "Documents incomplets"
  }'
```

## 10. Supprimer un client

```bash
curl -X DELETE http://localhost:8081/api/clients/5
```

## Exemples avec PowerShell (Windows)

### Créer un client
```powershell
$body = @{
    firstName = "Bob"
    lastName = "Martin"
    email = "bob.martin@example.com"
    phoneNumber = "+33612345678"
    address = "15 Rue Victor Hugo"
    city = "Lyon"
    postalCode = "69001"
    country = "France"
    dateOfBirth = "1988-03-20"
    nationalId = "1880320123456"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8081/api/clients" `
  -Method Post `
  -ContentType "application/json" `
  -Body $body
```

### Récupérer tous les clients
```powershell
Invoke-RestMethod -Uri "http://localhost:8081/api/clients" -Method Get
```

### Mettre à jour un client
```powershell
$body = @{
    phoneNumber = "+33699887766"
    city = "Marseille"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8081/api/clients/1" `
  -Method Put `
  -ContentType "application/json" `
  -Body $body
```

## Gestion des erreurs

### Client non trouvé (404)
```bash
curl -X GET http://localhost:8081/api/clients/999
```

Réponse :
```json
{
  "timestamp": "2024-01-15T10:30:00",
  "status": 404,
  "error": "Not Found",
  "message": "Client not found with ID: 999",
  "path": "/api/clients/999"
}
```

### Email déjà utilisé (409)
```bash
curl -X POST http://localhost:8081/api/clients \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "User",
    "email": "jean.dupont@example.com",
    ...
  }'
```

Réponse :
```json
{
  "timestamp": "2024-01-15T10:30:00",
  "status": 409,
  "error": "Conflict",
  "message": "Client with email jean.dupont@example.com already exists",
  "path": "/api/clients"
}
```

### Validation échouée (400)
```bash
curl -X POST http://localhost:8081/api/clients \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "",
    "email": "invalid-email"
  }'
```

Réponse :
```json
{
  "timestamp": "2024-01-15T10:30:00",
  "status": 400,
  "error": "Validation Failed",
  "errors": {
    "firstName": "First name is required",
    "email": "Email must be valid",
    "lastName": "Last name is required"
  },
  "path": "/api/clients"
}
```

## Accès à la documentation Swagger

Une fois le service démarré, accédez à :
- Swagger UI : http://localhost:8081/swagger-ui.html
- API Docs JSON : http://localhost:8081/api-docs

## Console H2

Pour accéder à la console H2 et voir les données :
- URL : http://localhost:8081/h2-console
- JDBC URL : `jdbc:h2:mem:clientdb`
- Username : `sa`
- Password : (laisser vide)
