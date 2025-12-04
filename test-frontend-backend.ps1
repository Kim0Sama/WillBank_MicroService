# Test complet frontend-backend

Write-Host "=== Test complet Frontend-Backend ===" -ForegroundColor Cyan
Write-Host ""

# 1. Vérifier que le frontend est démarré
Write-Host "1. Verification du frontend..." -ForegroundColor Yellow
try {
    $frontendResponse = Invoke-WebRequest -Uri "http://localhost:4200" -Method Get -TimeoutSec 3 -ErrorAction Stop
    Write-Host "  Frontend OK (port 4200)" -ForegroundColor Green
}
catch {
    Write-Host "  Frontend non demarre!" -ForegroundColor Red
    Write-Host "  Demarrez-le avec: cd Frontend && ng serve" -ForegroundColor Yellow
    exit 1
}

# 2. Vérifier le backend
Write-Host "`n2. Verification du backend..." -ForegroundColor Yellow

$backendTests = @(
    @{ Name = "Gateway"; Url = "http://localhost:8080" },
    @{ Name = "Client Service"; Url = "http://localhost:8082/actuator/health" },
    @{ Name = "Account Service"; Url = "http://localhost:8081/actuator/health" }
)

$allBackendOk = $true
foreach ($test in $backendTests) {
    Write-Host "  $($test.Name)..." -NoNewline
    try {
        Invoke-WebRequest -Uri $test.Url -Method Get -TimeoutSec 3 -ErrorAction Stop | Out-Null
        Write-Host " OK" -ForegroundColor Green
    }
    catch {
        Write-Host " FAILED" -ForegroundColor Red
        $allBackendOk = $false
    }
}

if (-not $allBackendOk) {
    Write-Host "`nCertains services backend ne sont pas demarres!" -ForegroundColor Red
    exit 1
}

# 3. Test de login via API
Write-Host "`n3. Test de login via API..." -ForegroundColor Yellow

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
    
    Write-Host "  Login API OK" -ForegroundColor Green
    Write-Host "  User ID: $($loginResponse.userId)" -ForegroundColor Cyan
    Write-Host "  Token: $($loginResponse.token.Substring(0, 30))..." -ForegroundColor Cyan
    
    $token = $loginResponse.token
    $userId = $loginResponse.userId
}
catch {
    Write-Host "  Login API FAILED" -ForegroundColor Red
    Write-Host "  Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
    exit 1
}

# 4. Test de récupération des comptes
Write-Host "`n4. Test de recuperation des comptes..." -ForegroundColor Yellow

$headers = @{ Authorization = "Bearer $token" }

try {
    $accounts = Invoke-RestMethod -Uri "http://localhost:8080/api/accounts/customer/$userId" `
        -Method Get `
        -Headers $headers `
        -ErrorAction Stop
    
    Write-Host "  Recuperation OK" -ForegroundColor Green
    Write-Host "  Nombre de comptes: $($accounts.Count)" -ForegroundColor Cyan
    
    if ($accounts.Count -eq 0) {
        Write-Host "`n  Aucun compte trouve. Creation d'un compte de test..." -ForegroundColor Yellow
        
        $accountBody = @{
            customerId = $userId
            accountType = "CHECKING"
            initialBalance = 1000.00
        } | ConvertTo-Json
        
        try {
            $newAccount = Invoke-RestMethod -Uri "http://localhost:8080/api/accounts" `
                -Method Post `
                -Headers $headers `
                -ContentType "application/json" `
                -Body $accountBody `
                -ErrorAction Stop
            
            Write-Host "  Compte cree: $($newAccount.accountNumber)" -ForegroundColor Green
        }
        catch {
            Write-Host "  Erreur creation compte: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}
catch {
    Write-Host "  Recuperation FAILED" -ForegroundColor Red
    Write-Host "  Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
}

# 5. Instructions pour le frontend
Write-Host "`n5. Test du frontend..." -ForegroundColor Yellow
Write-Host ""
Write-Host "  Le backend fonctionne correctement!" -ForegroundColor Green
Write-Host ""
Write-Host "  Pour tester le frontend:" -ForegroundColor Cyan
Write-Host "    1. Ouvrez http://localhost:4200 dans votre navigateur" -ForegroundColor White
Write-Host "    2. Ouvrez les DevTools (F12)" -ForegroundColor White
Write-Host "    3. Allez dans l'onglet Console" -ForegroundColor White
Write-Host "    4. Connectez-vous avec:" -ForegroundColor White
Write-Host "       Email: jean.dupont@example.com" -ForegroundColor White
Write-Host "       Password: password123" -ForegroundColor White
Write-Host "    5. Regardez les erreurs dans la console" -ForegroundColor White
Write-Host ""
Write-Host "  Si vous voyez une erreur 500:" -ForegroundColor Yellow
Write-Host "    - Verifiez l'onglet Network dans les DevTools" -ForegroundColor White
Write-Host "    - Cliquez sur la requete 'login' en echec" -ForegroundColor White
Write-Host "    - Regardez la reponse complete" -ForegroundColor White
Write-Host ""
Write-Host "  Si le frontend ne se connecte pas:" -ForegroundColor Yellow
Write-Host "    1. Arretez le frontend (Ctrl+C)" -ForegroundColor White
Write-Host "    2. Videz le cache: rm -r Frontend/.angular" -ForegroundColor White
Write-Host "    3. Redemarrez: cd Frontend && ng serve" -ForegroundColor White
Write-Host ""

Write-Host "=== Test termine ===" -ForegroundColor Cyan
Write-Host ""
