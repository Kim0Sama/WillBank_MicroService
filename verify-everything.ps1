# Vérification complète de l'application WillBank

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  VERIFICATION COMPLETE WILLBANK" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# 1. Vérifier les services
Write-Host "1. SERVICES" -ForegroundColor Yellow
Write-Host "   Verification des services backend..." -ForegroundColor Gray

$services = @(
    @{ Name = "Eureka"; Port = 8761; Path = "" },
    @{ Name = "Gateway"; Port = 8080; Path = "/api/auth/login" },
    @{ Name = "Client Service"; Port = 8082; Path = "/actuator/health" },
    @{ Name = "Account Service"; Port = 8081; Path = "/actuator/health" }
)

foreach ($service in $services) {
    Write-Host "   - $($service.Name) (port $($service.Port))..." -NoNewline
    try {
        $url = "http://localhost:$($service.Port)$($service.Path)"
        Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 3 -ErrorAction Stop | Out-Null
        Write-Host " OK" -ForegroundColor Green
    }
    catch {
        Write-Host " FAILED" -ForegroundColor Red
        $allGood = $false
    }
}

if (-not $allGood) {
    Write-Host ""
    Write-Host "   ERREUR: Certains services ne sont pas demarres!" -ForegroundColor Red
    Write-Host "   Action: Demarrez tous les services avec .\start-all-services.ps1" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# 2. Vérifier les secrets JWT
Write-Host ""
Write-Host "2. CONFIGURATION JWT" -ForegroundColor Yellow
Write-Host "   Verification des secrets JWT..." -ForegroundColor Gray

$clientConfig = Get-Content "Client_service/src/main/resources/application.yaml" -Raw
$gatewayConfig = Get-Content "gateway_service/src/main/resources/application.yaml" -Raw

$clientSecret = ""
$gatewaySecret = ""

if ($clientConfig -match "jwt:\s+secret:\s+(\S+)") {
    $clientSecret = $matches[1]
}

if ($gatewayConfig -match "jwt:\s+secret:\s+(\S+)") {
    $gatewaySecret = $matches[1]
}

if ($clientSecret -eq $gatewaySecret -and $clientSecret -ne "") {
    Write-Host "   - Secrets JWT identiques" -ForegroundColor Green
} else {
    Write-Host "   - ERREUR: Secrets JWT differents!" -ForegroundColor Red
    Write-Host "     Client: $($clientSecret.Substring(0, 20))..." -ForegroundColor Gray
    Write-Host "     Gateway: $($gatewaySecret.Substring(0, 20))..." -ForegroundColor Gray
    $allGood = $false
}

# 3. Tester l'authentification
Write-Host ""
Write-Host "3. AUTHENTIFICATION" -ForegroundColor Yellow
Write-Host "   Test de connexion..." -ForegroundColor Gray

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
    
    Write-Host "   - Login reussi" -ForegroundColor Green
    Write-Host "     User ID: $($loginResponse.userId)" -ForegroundColor Gray
    
    $token = $loginResponse.token
    $userId = $loginResponse.userId
}
catch {
    Write-Host "   - ERREUR: Login echoue" -ForegroundColor Red
    Write-Host "     Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Gray
    $allGood = $false
    exit 1
}

# 4. Tester la validation du token
Write-Host ""
Write-Host "4. VALIDATION TOKEN JWT" -ForegroundColor Yellow
Write-Host "   Test du token via Gateway..." -ForegroundColor Gray

$headers = @{ Authorization = "Bearer $token" }

try {
    $client = Invoke-RestMethod -Uri "http://localhost:8080/api/clients/$userId" `
        -Method Get `
        -Headers $headers `
        -ErrorAction Stop
    
    Write-Host "   - Token valide" -ForegroundColor Green
    Write-Host "     Client: $($client.firstName) $($client.lastName)" -ForegroundColor Gray
}
catch {
    Write-Host "   - ERREUR: Token invalide" -ForegroundColor Red
    Write-Host "     Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   CAUSE: Le Client Service n'a pas ete redemarre!" -ForegroundColor Yellow
    Write-Host "   ACTION: Redemarrez le Client Service:" -ForegroundColor Yellow
    Write-Host "     cd Client_service" -ForegroundColor White
    Write-Host "     mvnw spring-boot:run" -ForegroundColor White
    Write-Host ""
    $allGood = $false
    exit 1
}

# 5. Tester la récupération des comptes
Write-Host ""
Write-Host "5. RECUPERATION DES COMPTES" -ForegroundColor Yellow
Write-Host "   Test de l'endpoint accounts..." -ForegroundColor Gray

try {
    $accounts = Invoke-RestMethod -Uri "http://localhost:8080/api/accounts/customer/$userId" `
        -Method Get `
        -Headers $headers `
        -ErrorAction Stop
    
    Write-Host "   - Recuperation reussie" -ForegroundColor Green
    Write-Host "     Nombre de comptes: $($accounts.Count)" -ForegroundColor Gray
    
    if ($accounts.Count -eq 0) {
        Write-Host "     (Aucun compte - normal pour un nouvel utilisateur)" -ForegroundColor Gray
    }
}
catch {
    Write-Host "   - ERREUR: Recuperation echouee" -ForegroundColor Red
    Write-Host "     Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Gray
    $allGood = $false
}

# 6. Tester la création de compte
Write-Host ""
Write-Host "6. CREATION DE COMPTE" -ForegroundColor Yellow
Write-Host "   Test de creation d'un compte..." -ForegroundColor Gray

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
    
    Write-Host "   - Creation reussie" -ForegroundColor Green
    Write-Host "     Numero: $($newAccount.accountNumber)" -ForegroundColor Gray
    Write-Host "     Type: $($newAccount.accountType)" -ForegroundColor Gray
    Write-Host "     Solde: $($newAccount.balance) EUR" -ForegroundColor Gray
}
catch {
    Write-Host "   - ERREUR: Creation echouee" -ForegroundColor Red
    Write-Host "     Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Gray
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        if ($responseBody) {
            Write-Host "     Details: $responseBody" -ForegroundColor Gray
        }
    }
    
    $allGood = $false
}

# 7. Vérifier le frontend
Write-Host ""
Write-Host "7. FRONTEND" -ForegroundColor Yellow
Write-Host "   Verification du frontend Angular..." -ForegroundColor Gray

try {
    Invoke-WebRequest -Uri "http://localhost:4200" -Method Get -TimeoutSec 3 -ErrorAction Stop | Out-Null
    Write-Host "   - Frontend demarre" -ForegroundColor Green
}
catch {
    Write-Host "   - Frontend non demarre" -ForegroundColor Yellow
    Write-Host "     Action: cd Frontend && ng serve" -ForegroundColor Gray
}

# Résultat final
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

if ($allGood) {
    Write-Host "  TOUT FONCTIONNE CORRECTEMENT!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Vous pouvez maintenant:" -ForegroundColor Cyan
    Write-Host "  1. Ouvrir http://localhost:4200" -ForegroundColor White
    Write-Host "  2. Se connecter avec:" -ForegroundColor White
    Write-Host "     Email: jean.dupont@example.com" -ForegroundColor Gray
    Write-Host "     Password: password123" -ForegroundColor Gray
    Write-Host "  3. Creer des comptes et effectuer des transactions" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "  DES PROBLEMES ONT ETE DETECTES" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Consultez le guide de resolution:" -ForegroundColor Yellow
    Write-Host "  FIX_FINAL_SOLUTION.md" -ForegroundColor White
    Write-Host ""
    Write-Host "Ou executez:" -ForegroundColor Yellow
    Write-Host "  .\test-jwt-token.ps1" -ForegroundColor White
    Write-Host ""
}

Write-Host ""
