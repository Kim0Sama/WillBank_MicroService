# Script de test du flux d'authentification
Write-Host "=== Test du flux d'authentification WillBank ===" -ForegroundColor Cyan
Write-Host ""

# Test 1: Vérifier que l'accès au dashboard sans token est refusé
Write-Host "Test 1: Accès au dashboard sans authentification..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:4200/dashboard" -Method GET -MaximumRedirection 0 -ErrorAction SilentlyContinue
    Write-Host "ATTENTION: Le dashboard est accessible sans authentification!" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 302 -or $_.Exception.Response.StatusCode -eq 401) {
        Write-Host "✓ Accès refusé correctement (redirection ou 401)" -ForegroundColor Green
    } else {
        Write-Host "✓ Accès refusé" -ForegroundColor Green
    }
}
Write-Host ""

# Test 2: Login avec des credentials valides
Write-Host "Test 2: Login avec credentials valides..." -ForegroundColor Yellow
$loginData = @{
    email = "john.doe@example.com"
    password = "password123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    Write-Host "✓ Login réussi!" -ForegroundColor Green
    Write-Host "  Token: $($loginResponse.token.Substring(0, 20))..." -ForegroundColor Gray
    Write-Host "  User: $($loginResponse.firstName) $($loginResponse.lastName)" -ForegroundColor Gray
    Write-Host "  Role: $($loginResponse.role)" -ForegroundColor Gray
    $token = $loginResponse.token
} catch {
    Write-Host "✗ Échec du login: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 3: Accès au dashboard avec token valide
Write-Host "Test 3: Accès au dashboard avec token valide..." -ForegroundColor Yellow
try {
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    $clientResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/clients/$($loginResponse.userId)" -Method GET -Headers $headers
    Write-Host "✓ Accès autorisé avec token valide" -ForegroundColor Green
    Write-Host "  Client ID: $($clientResponse.id)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Échec de l'accès: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 4: Accès avec token invalide
Write-Host "Test 4: Accès avec token invalide..." -ForegroundColor Yellow
try {
    $headers = @{
        "Authorization" = "Bearer invalid_token_12345"
    }
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/clients/1" -Method GET -Headers $headers
    Write-Host "✗ ATTENTION: Accès autorisé avec token invalide!" -ForegroundColor Red
} catch {
    Write-Host "✓ Accès refusé correctement avec token invalide" -ForegroundColor Green
}
Write-Host ""

Write-Host "=== Tests terminés ===" -ForegroundColor Cyan
