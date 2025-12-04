# Diagnostic de l'erreur 500 sur login

Write-Host "=== Diagnostic de l'erreur de connexion ===" -ForegroundColor Cyan
Write-Host ""

# Test 1: Vérifier que les services sont démarrés
Write-Host "1. Verification des services..." -ForegroundColor Yellow

$services = @(
    @{ Name = "Eureka"; Url = "http://localhost:8761" },
    @{ Name = "Gateway"; Url = "http://localhost:8080" },
    @{ Name = "Client Service"; Url = "http://localhost:8082/actuator/health" }
)

$allRunning = $true
foreach ($service in $services) {
    Write-Host "  $($service.Name)..." -NoNewline
    try {
        $response = Invoke-WebRequest -Uri $service.Url -Method Get -TimeoutSec 3 -ErrorAction Stop
        Write-Host " OK" -ForegroundColor Green
    }
    catch {
        Write-Host " FAILED" -ForegroundColor Red
        $allRunning = $false
    }
}

if (-not $allRunning) {
    Write-Host "`nCertains services ne sont pas demarres!" -ForegroundColor Red
    Write-Host "Demarrez tous les services avec: .\start-all-services.ps1" -ForegroundColor Yellow
    exit 1
}

# Test 2: Tester le login directement sur le Client Service
Write-Host "`n2. Test de login direct sur Client Service (port 8082)..." -ForegroundColor Yellow

$loginBody = @{
    email = "jean.dupont@example.com"
    password = "password123"
} | ConvertTo-Json

try {
    $directResponse = Invoke-RestMethod -Uri "http://localhost:8082/api/auth/login" `
        -Method Post `
        -ContentType "application/json" `
        -Body $loginBody `
        -ErrorAction Stop
    
    Write-Host "  Login direct OK" -ForegroundColor Green
    Write-Host "  User ID: $($directResponse.userId)" -ForegroundColor Cyan
    Write-Host "  Token genere: Oui" -ForegroundColor Cyan
}
catch {
    Write-Host "  Login direct FAILED" -ForegroundColor Red
    Write-Host "  Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "  Error: $responseBody" -ForegroundColor Yellow
    }
    
    Write-Host "`nLe probleme vient du Client Service!" -ForegroundColor Red
    Write-Host "Verifiez les logs du Client Service pour plus de details." -ForegroundColor Yellow
    exit 1
}

# Test 3: Tester le login via le Gateway
Write-Host "`n3. Test de login via Gateway (port 8080)..." -ForegroundColor Yellow

try {
    $gatewayResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
        -Method Post `
        -ContentType "application/json" `
        -Body $loginBody `
        -ErrorAction Stop
    
    Write-Host "  Login via Gateway OK" -ForegroundColor Green
    Write-Host "  User ID: $($gatewayResponse.userId)" -ForegroundColor Cyan
}
catch {
    Write-Host "  Login via Gateway FAILED" -ForegroundColor Red
    Write-Host "  Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "  Error: $responseBody" -ForegroundColor Yellow
    }
    
    Write-Host "`nLe probleme vient du Gateway!" -ForegroundColor Red
    Write-Host "Verifiez:" -ForegroundColor Yellow
    Write-Host "  1. La configuration CORS du Gateway" -ForegroundColor White
    Write-Host "  2. Les routes du Gateway" -ForegroundColor White
    Write-Host "  3. Les logs du Gateway" -ForegroundColor White
    exit 1
}

# Test 4: Vérifier la configuration JWT
Write-Host "`n4. Verification de la configuration JWT..." -ForegroundColor Yellow

$clientConfig = Get-Content "Client_service/src/main/resources/application.yaml" -Raw
$gatewayConfig = Get-Content "gateway_service/src/main/resources/application.yaml" -Raw

if ($clientConfig -match "jwt:\s+secret:\s+(\S+)") {
    $clientSecret = $matches[1]
    Write-Host "  Client Service JWT secret: $($clientSecret.Substring(0, 20))..." -ForegroundColor Cyan
}

if ($gatewayConfig -match "jwt:\s+secret:\s+(\S+)") {
    $gatewaySecret = $matches[1]
    Write-Host "  Gateway JWT secret: $($gatewaySecret.Substring(0, 20))..." -ForegroundColor Cyan
}

if ($clientSecret -eq $gatewaySecret) {
    Write-Host "  Les secrets JWT correspondent" -ForegroundColor Green
} else {
    Write-Host "  ATTENTION: Les secrets JWT sont differents!" -ForegroundColor Red
    Write-Host "  Cela causera des problemes d'authentification." -ForegroundColor Yellow
}

# Test 5: Vérifier l'utilisateur dans la base de données
Write-Host "`n5. Verification de l'utilisateur..." -ForegroundColor Yellow
Write-Host "  Email: jean.dupont@example.com" -ForegroundColor Cyan
Write-Host "  Cet utilisateur doit exister avec:" -ForegroundColor Cyan
Write-Host "    - status = ACTIVE" -ForegroundColor White
Write-Host "    - kyc_status = VERIFIED" -ForegroundColor White
Write-Host "    - password = hash BCrypt de 'password123'" -ForegroundColor White

Write-Host "`n=== Diagnostic termine ===" -ForegroundColor Cyan
Write-Host ""

if ($allRunning) {
    Write-Host "Tous les tests sont passes!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Si le frontend affiche toujours une erreur 500:" -ForegroundColor Yellow
    Write-Host "  1. Ouvrez la console du navigateur (F12)" -ForegroundColor White
    Write-Host "  2. Allez dans l'onglet Network" -ForegroundColor White
    Write-Host "  3. Essayez de vous connecter" -ForegroundColor White
    Write-Host "  4. Cliquez sur la requete 'login' en echec" -ForegroundColor White
    Write-Host "  5. Regardez la reponse pour voir l'erreur exacte" -ForegroundColor White
    Write-Host ""
    Write-Host "Ou testez avec curl:" -ForegroundColor Yellow
    Write-Host '  curl -X POST http://localhost:8080/api/auth/login -H "Content-Type: application/json" -d "{\"email\":\"jean.dupont@example.com\",\"password\":\"password123\"}"' -ForegroundColor White
}

Write-Host ""
