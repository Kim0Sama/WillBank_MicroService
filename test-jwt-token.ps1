# Test de validation du token JWT

Write-Host "=== Test de validation du token JWT ===" -ForegroundColor Cyan
Write-Host ""

# 1. Obtenir un token
Write-Host "1. Obtention d'un token..." -ForegroundColor Yellow

$loginBody = @{
    email = "jean.dupont@example.com"
    password = "password123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
        -Method Post `
        -ContentType "application/json" `
        -Body $loginBody `
        -ErrorAction Stop
    
    Write-Host "  Token obtenu" -ForegroundColor Green
    $token = $loginResponse.token
    $userId = $loginResponse.userId
    
    Write-Host "  User ID: $userId" -ForegroundColor Cyan
    Write-Host "  Token: $($token.Substring(0, 50))..." -ForegroundColor Cyan
}
catch {
    Write-Host "  Erreur lors du login" -ForegroundColor Red
    exit 1
}

# 2. Tester le token sur le Client Service directement
Write-Host "`n2. Test du token sur Client Service (port 8082)..." -ForegroundColor Yellow

$headers = @{ Authorization = "Bearer $token" }

try {
    $client = Invoke-RestMethod -Uri "http://localhost:8082/api/clients/$userId" `
        -Method Get `
        -Headers $headers `
        -ErrorAction Stop
    
    Write-Host "  Token valide sur Client Service" -ForegroundColor Green
    Write-Host "  Client: $($client.firstName) $($client.lastName)" -ForegroundColor Cyan
}
catch {
    Write-Host "  Token invalide sur Client Service" -ForegroundColor Red
    Write-Host "  Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
}

# 3. Tester le token sur le Account Service directement
Write-Host "`n3. Test du token sur Account Service (port 8081)..." -ForegroundColor Yellow

try {
    $accounts = Invoke-RestMethod -Uri "http://localhost:8081/api/accounts/customer/$userId" `
        -Method Get `
        -Headers $headers `
        -ErrorAction Stop
    
    Write-Host "  Requete reussie sur Account Service" -ForegroundColor Green
    Write-Host "  Nombre de comptes: $($accounts.Count)" -ForegroundColor Cyan
}
catch {
    Write-Host "  Erreur sur Account Service" -ForegroundColor Red
    Write-Host "  Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
}

# 4. Tester le token via le Gateway
Write-Host "`n4. Test du token via Gateway (port 8080)..." -ForegroundColor Yellow

try {
    $accountsViaGateway = Invoke-RestMethod -Uri "http://localhost:8080/api/accounts/customer/$userId" `
        -Method Get `
        -Headers $headers `
        -ErrorAction Stop
    
    Write-Host "  Token valide via Gateway" -ForegroundColor Green
    Write-Host "  Nombre de comptes: $($accountsViaGateway.Count)" -ForegroundColor Cyan
    
    Write-Host "`n=== Tout fonctionne! ===" -ForegroundColor Green
}
catch {
    Write-Host "  Token invalide via Gateway" -ForegroundColor Red
    Write-Host "  Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        if ($responseBody) {
            Write-Host "  Response: $responseBody" -ForegroundColor Yellow
        }
    }
    
    Write-Host "`n=== Probleme identifie ===" -ForegroundColor Red
    Write-Host ""
    Write-Host "Le token est rejete par le Gateway." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Causes possibles:" -ForegroundColor Yellow
    Write-Host "  1. Le Client Service n'a pas ete redemarre apres le changement du secret JWT" -ForegroundColor White
    Write-Host "  2. Les secrets JWT sont differents entre Client Service et Gateway" -ForegroundColor White
    Write-Host "  3. Le Gateway a un probleme de validation du token" -ForegroundColor White
    Write-Host ""
    Write-Host "Solution:" -ForegroundColor Cyan
    Write-Host "  1. Verifiez que les secrets JWT sont identiques:" -ForegroundColor White
    Write-Host "     - Client_service/src/main/resources/application.yaml" -ForegroundColor Gray
    Write-Host "     - gateway_service/src/main/resources/application.yaml" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  2. Redemarrez le Client Service:" -ForegroundColor White
    Write-Host "     cd Client_service" -ForegroundColor Gray
    Write-Host "     mvnw spring-boot:run" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  3. Redemarrez le Gateway:" -ForegroundColor White
    Write-Host "     cd gateway_service" -ForegroundColor Gray
    Write-Host "     mvnw spring-boot:run" -ForegroundColor Gray
    Write-Host ""
}

Write-Host ""
