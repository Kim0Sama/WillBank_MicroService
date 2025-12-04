# Script pour redémarrer le Client Service et tester

Write-Host "=== Redemarrage du Client Service ===" -ForegroundColor Cyan
Write-Host ""

# 1. Arrêter le Client Service
Write-Host "1. Arret du Client Service..." -ForegroundColor Yellow
$clientProcess = Get-Process -Name "java" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*client*" }
if ($clientProcess) {
    Stop-Process -Id $clientProcess.Id -Force
    Write-Host "  Client Service arrete" -ForegroundColor Green
    Start-Sleep -Seconds 3
} else {
    Write-Host "  Client Service n'est pas en cours d'execution" -ForegroundColor Yellow
}

# 2. Démarrer le Client Service
Write-Host "`n2. Demarrage du Client Service..." -ForegroundColor Yellow
Write-Host "  Veuillez demarrer le Client Service manuellement dans un autre terminal:" -ForegroundColor Cyan
Write-Host "  cd Client_service" -ForegroundColor White
Write-Host "  mvnw spring-boot:run" -ForegroundColor White
Write-Host ""
Write-Host "  Appuyez sur une touche une fois le service demarre..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# 3. Tester la connexion
Write-Host "`n3. Test de connexion..." -ForegroundColor Yellow

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
    
    Write-Host "  Connexion reussie!" -ForegroundColor Green
    Write-Host "  User ID: $($loginResponse.userId)" -ForegroundColor Cyan
    Write-Host "  Token: $($loginResponse.token.Substring(0, 30))..." -ForegroundColor Cyan
    
    $token = $loginResponse.token
    $userId = $loginResponse.userId
    $headers = @{ Authorization = "Bearer $token" }
    
    # 4. Tester la récupération des comptes
    Write-Host "`n4. Test de recuperation des comptes..." -ForegroundColor Yellow
    
    try {
        $accounts = Invoke-RestMethod -Uri "http://localhost:8080/api/accounts/customer/$userId" `
            -Method Get `
            -Headers $headers `
            -ErrorAction Stop
        
        Write-Host "  Comptes recuperes avec succes!" -ForegroundColor Green
        Write-Host "  Nombre de comptes: $($accounts.Count)" -ForegroundColor Cyan
        
        if ($accounts.Count -eq 0) {
            Write-Host "`n  Aucun compte trouve. Creation de comptes..." -ForegroundColor Yellow
            
            # Créer des comptes
            $newAccounts = @(
                @{ customerId = $userId; accountType = "CHECKING"; initialDeposit = 5000.00 },
                @{ customerId = $userId; accountType = "SAVINGS"; initialDeposit = 15000.00 }
            )
            
            foreach ($account in $newAccounts) {
                try {
                    $accountBody = $account | ConvertTo-Json
                    $result = Invoke-RestMethod -Uri "http://localhost:8080/api/accounts" `
                        -Method Post `
                        -Headers $headers `
                        -ContentType "application/json" `
                        -Body $accountBody `
                        -ErrorAction Stop
                    
                    Write-Host "    Compte cree: $($result.accountNumber) - $($result.accountType) - $($result.balance) EUR" -ForegroundColor Green
                }
                catch {
                    Write-Host "    Erreur: $($_.Exception.Message)" -ForegroundColor Red
                }
            }
            
            # Revérifier les comptes
            $accounts = Invoke-RestMethod -Uri "http://localhost:8080/api/accounts/customer/$userId" `
                -Method Get `
                -Headers $headers `
                -ErrorAction Stop
            
            Write-Host "`n  Comptes apres creation:" -ForegroundColor Cyan
        }
        
        foreach ($acc in $accounts) {
            Write-Host "    - $($acc.accountNumber): $($acc.accountType) - $($acc.balance) EUR" -ForegroundColor White
        }
        
        Write-Host "`n=== Test reussi! ===" -ForegroundColor Green
        Write-Host "Le probleme est resolu. Vous pouvez maintenant utiliser le frontend." -ForegroundColor Green
        
    }
    catch {
        Write-Host "  Erreur: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "  Le probleme persiste. Verifiez les logs des services." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "  Erreur de connexion: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
