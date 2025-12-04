# Script pour corriger et redémarrer automatiquement

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FIX ET REDEMARRAGE AUTOMATIQUE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Ce script va:" -ForegroundColor Yellow
Write-Host "  1. Verifier la configuration JWT" -ForegroundColor White
Write-Host "  2. Arreter le Client Service" -ForegroundColor White
Write-Host "  3. Redemarrer le Client Service" -ForegroundColor White
Write-Host "  4. Tester que tout fonctionne" -ForegroundColor White
Write-Host ""

$continue = Read-Host "Continuer? (O/N)"
if ($continue -ne "O" -and $continue -ne "o") {
    Write-Host "Operation annulee." -ForegroundColor Yellow
    exit 0
}

# 1. Vérifier la configuration JWT
Write-Host "`n1. Verification de la configuration JWT..." -ForegroundColor Yellow

$clientConfig = Get-Content "Client_service/src/main/resources/application.yaml" -Raw
$gatewayConfig = Get-Content "gateway_service/src/main/resources/application.yaml" -Raw

$expectedSecret = "WillBankSecretKey2024VeryLongSecretKeyForJWTTokenGeneration123456789"

if ($clientConfig -match "jwt:\s+secret:\s+(\S+)") {
    $clientSecret = $matches[1]
    if ($clientSecret -eq $expectedSecret) {
        Write-Host "   Client Service JWT: OK" -ForegroundColor Green
    } else {
        Write-Host "   Client Service JWT: INCORRECT" -ForegroundColor Red
        Write-Host "   Le secret sera corrige..." -ForegroundColor Yellow
        
        # Corriger le secret
        $clientConfig = $clientConfig -replace "jwt:\s+secret:\s+\S+", "jwt:`n  secret: $expectedSecret"
        Set-Content "Client_service/src/main/resources/application.yaml" -Value $clientConfig
        Write-Host "   Secret corrige!" -ForegroundColor Green
    }
}

if ($gatewayConfig -match "jwt:\s+secret:\s+(\S+)") {
    $gatewaySecret = $matches[1]
    if ($gatewaySecret -eq $expectedSecret) {
        Write-Host "   Gateway JWT: OK" -ForegroundColor Green
    } else {
        Write-Host "   Gateway JWT: INCORRECT" -ForegroundColor Red
    }
}

# 2. Arrêter le Client Service
Write-Host "`n2. Arret du Client Service..." -ForegroundColor Yellow

$javaProcesses = Get-Process -Name "java" -ErrorAction SilentlyContinue

if ($javaProcesses) {
    Write-Host "   Recherche du processus Client Service..." -ForegroundColor Gray
    
    foreach ($process in $javaProcesses) {
        try {
            $commandLine = (Get-WmiObject Win32_Process -Filter "ProcessId = $($process.Id)").CommandLine
            if ($commandLine -like "*client*service*" -or $commandLine -like "*ClientServiceApplication*") {
                Write-Host "   Arret du processus $($process.Id)..." -ForegroundColor Gray
                Stop-Process -Id $process.Id -Force
                Write-Host "   Client Service arrete" -ForegroundColor Green
                Start-Sleep -Seconds 3
                break
            }
        }
        catch {
            # Ignorer les erreurs
        }
    }
} else {
    Write-Host "   Aucun processus Java trouve" -ForegroundColor Yellow
}

# 3. Redémarrer le Client Service
Write-Host "`n3. Redemarrage du Client Service..." -ForegroundColor Yellow
Write-Host ""
Write-Host "   IMPORTANT: Vous devez demarrer le Client Service manuellement" -ForegroundColor Red
Write-Host ""
Write-Host "   Dans un nouveau terminal, executez:" -ForegroundColor Cyan
Write-Host "     cd Client_service" -ForegroundColor White
Write-Host "     mvnw spring-boot:run" -ForegroundColor White
Write-Host ""
Write-Host "   Attendez le message: 'Started ClientServiceApplication'" -ForegroundColor Cyan
Write-Host ""

$ready = Read-Host "Appuyez sur ENTREE une fois le Client Service demarre"

# 4. Tester
Write-Host "`n4. Test de l'application..." -ForegroundColor Yellow

Start-Sleep -Seconds 2

$loginBody = @{
    email = "jean.dupont@example.com"
    password = "password123"
} | ConvertTo-Json

Write-Host "   Test de connexion..." -ForegroundColor Gray

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
        -Method Post `
        -ContentType "application/json" `
        -Body $loginBody `
        -ErrorAction Stop
    
    Write-Host "   Connexion: OK" -ForegroundColor Green
    
    $token = $loginResponse.token
    $userId = $loginResponse.userId
    $headers = @{ Authorization = "Bearer $token" }
    
    Write-Host "   Test du token..." -ForegroundColor Gray
    
    try {
        $accounts = Invoke-RestMethod -Uri "http://localhost:8080/api/accounts/customer/$userId" `
            -Method Get `
            -Headers $headers `
            -ErrorAction Stop
        
        Write-Host "   Token: OK" -ForegroundColor Green
        Write-Host "   Comptes: $($accounts.Count)" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "  TOUT FONCTIONNE!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Vous pouvez maintenant:" -ForegroundColor Cyan
        Write-Host "  1. Ouvrir http://localhost:4200" -ForegroundColor White
        Write-Host "  2. Se connecter avec jean.dupont@example.com / password123" -ForegroundColor White
        Write-Host "  3. Creer des comptes et effectuer des transactions" -ForegroundColor White
        Write-Host ""
        
    }
    catch {
        Write-Host "   Token: INVALIDE" -ForegroundColor Red
        Write-Host ""
        Write-Host "   Le Client Service n'a peut-etre pas fini de demarrer." -ForegroundColor Yellow
        Write-Host "   Attendez 10 secondes et reessayez avec:" -ForegroundColor Yellow
        Write-Host "     .\verify-everything.ps1" -ForegroundColor White
        Write-Host ""
    }
}
catch {
    Write-Host "   Connexion: ECHEC" -ForegroundColor Red
    Write-Host ""
    Write-Host "   Le Client Service n'est peut-etre pas demarre." -ForegroundColor Yellow
    Write-Host "   Verifiez qu'il tourne et reessayez." -ForegroundColor Yellow
    Write-Host ""
}
