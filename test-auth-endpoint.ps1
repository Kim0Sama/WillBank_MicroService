# Script de test de l'endpoint d'authentification
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test de l'Endpoint d'Authentification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Vérifier que le Gateway est accessible
Write-Host "Test 1: Gateway accessible..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -Method GET -ErrorAction Stop
    Write-Host "✓ Gateway est accessible (port 8080)" -ForegroundColor Green
} catch {
    Write-Host "✗ Gateway n'est pas accessible" -ForegroundColor Red
    Write-Host "  Démarrez le Gateway avec: .\start-services-clean.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Test 2: Vérifier que le Client Service est accessible
Write-Host "Test 2: Client Service accessible..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8084/actuator/health" -Method GET -ErrorAction Stop
    Write-Host "✓ Client Service est accessible (port 8084)" -ForegroundColor Green
} catch {
    Write-Host "✗ Client Service n'est pas accessible" -ForegroundColor Red
    Write-Host "  Démarrez les services avec: .\start-services-clean.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Test 3: Tester l'authentification avec un utilisateur
Write-Host "Test 3: Test d'authentification..." -ForegroundColor Yellow

$body = @{
    email = "jean.dupont@example.com"
    password = "password123"
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body $body `
        -ErrorAction Stop
    
    $result = $response.Content | ConvertFrom-Json
    
    Write-Host "✓ Authentification réussie!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Token JWT reçu:" -ForegroundColor Cyan
    Write-Host $result.token.Substring(0, 50) + "..." -ForegroundColor Gray
    Write-Host ""
    Write-Host "Utilisateur:" -ForegroundColor Cyan
    Write-Host "  ID: $($result.userId)" -ForegroundColor White
    Write-Host "  Email: $($result.email)" -ForegroundColor White
    Write-Host "  Nom: $($result.firstName) $($result.lastName)" -ForegroundColor White
    Write-Host "  Rôle: $($result.role)" -ForegroundColor White
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Tous les tests sont passés!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Vous pouvez maintenant:" -ForegroundColor White
    Write-Host "  1. Ouvrir http://localhost:4200" -ForegroundColor Cyan
    Write-Host "  2. Se connecter avec jean.dupont@example.com / password123" -ForegroundColor Cyan
    Write-Host ""
    
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    
    if ($statusCode -eq 401) {
        Write-Host "✗ Authentification échouée (401 Unauthorized)" -ForegroundColor Red
        Write-Host ""
        Write-Host "L'utilisateur n'existe pas ou le mot de passe est incorrect." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Solution:" -ForegroundColor Cyan
        Write-Host "  1. Exécutez: cd database" -ForegroundColor White
        Write-Host "  2. Exécutez: .\EXECUTE-AUTH-SETUP.ps1" -ForegroundColor White
        Write-Host "  3. Relancez ce test" -ForegroundColor White
        Write-Host ""
    } elseif ($statusCode -eq 404) {
        Write-Host "✗ Endpoint non trouvé (404 Not Found)" -ForegroundColor Red
        Write-Host ""
        Write-Host "Le Gateway ne route pas correctement vers le Client Service." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Solution:" -ForegroundColor Cyan
        Write-Host "  1. Vérifiez Eureka: http://localhost:8761" -ForegroundColor White
        Write-Host "  2. CLIENT-SERVICE doit être enregistré" -ForegroundColor White
        Write-Host "  3. Redémarrez les services si nécessaire" -ForegroundColor White
        Write-Host ""
    } else {
        Write-Host "✗ Erreur inattendue: $statusCode" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Yellow
        Write-Host ""
    }
    
    exit 1
}

Write-Host "Appuyez sur une touche pour continuer..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
