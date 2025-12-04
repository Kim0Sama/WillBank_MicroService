# Script pour créer des comptes via l'API Account Service

Write-Host "=== Creation de comptes via l'API ===" -ForegroundColor Cyan
Write-Host ""

# 1. Se connecter pour obtenir un token admin
Write-Host "1. Connexion en tant qu'admin..." -ForegroundColor Yellow

$loginBody = @{
    email = "admin@willbank.com"
    password = "password123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
        -Method Post `
        -ContentType "application/json" `
        -Body $loginBody `
        -ErrorAction Stop
    
    Write-Host "  Connexion reussie!" -ForegroundColor Green
    $token = $loginResponse.token
    $headers = @{ Authorization = "Bearer $token" }
    
    # 2. Créer des comptes pour Jean Dupont (ID 6)
    Write-Host "`n2. Creation de comptes pour Jean Dupont (ID 6)..." -ForegroundColor Yellow
    
    $accounts = @(
        @{ customerId = 6; accountType = "CHECKING"; initialDeposit = 5000.00 },
        @{ customerId = 6; accountType = "SAVINGS"; initialDeposit = 15000.00 }
    )
    
    foreach ($account in $accounts) {
        try {
            $accountBody = $account | ConvertTo-Json
            $result = Invoke-RestMethod -Uri "http://localhost:8080/api/accounts" `
                -Method Post `
                -Headers $headers `
                -ContentType "application/json" `
                -Body $accountBody `
                -ErrorAction Stop
            
            Write-Host "  Compte cree: $($result.accountNumber) - $($result.accountType) - $($result.balance) EUR" -ForegroundColor Green
        }
        catch {
            Write-Host "  Erreur: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    
    # 3. Créer des comptes pour Admin (ID 7)
    Write-Host "`n3. Creation de comptes pour Admin (ID 7)..." -ForegroundColor Yellow
    
    $adminAccounts = @(
        @{ customerId = 7; accountType = "CHECKING"; initialDeposit = 100000.00 },
        @{ customerId = 7; accountType = "BUSINESS"; initialDeposit = 500000.00 }
    )
    
    foreach ($account in $adminAccounts) {
        try {
            $accountBody = $account | ConvertTo-Json
            $result = Invoke-RestMethod -Uri "http://localhost:8080/api/accounts" `
                -Method Post `
                -Headers $headers `
                -ContentType "application/json" `
                -Body $accountBody `
                -ErrorAction Stop
            
            Write-Host "  Compte cree: $($result.accountNumber) - $($result.accountType) - $($result.balance) EUR" -ForegroundColor Green
        }
        catch {
            Write-Host "  Erreur: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    
    # 4. Vérifier les comptes créés
    Write-Host "`n4. Verification des comptes de Jean Dupont..." -ForegroundColor Yellow
    
    try {
        $jeanAccounts = Invoke-RestMethod -Uri "http://localhost:8080/api/accounts/customer/6" `
            -Method Get `
            -Headers $headers `
            -ErrorAction Stop
        
        Write-Host "  Jean Dupont a $($jeanAccounts.Count) compte(s):" -ForegroundColor Green
        foreach ($acc in $jeanAccounts) {
            Write-Host "    - $($acc.accountNumber): $($acc.accountType) - $($acc.balance) EUR" -ForegroundColor Cyan
        }
    }
    catch {
        Write-Host "  Erreur lors de la verification: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    Write-Host "`n=== Comptes crees avec succes! ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "Vous pouvez maintenant:" -ForegroundColor Cyan
    Write-Host "  1. Vous connecter avec jean.dupont@example.com / password123" -ForegroundColor White
    Write-Host "  2. Voir vos comptes dans le dashboard" -ForegroundColor White
    Write-Host ""
}
catch {
    Write-Host "  Erreur de connexion: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Verifiez que:" -ForegroundColor Yellow
    Write-Host "  1. Tous les services sont demarres" -ForegroundColor White
    Write-Host "  2. L'utilisateur admin@willbank.com existe" -ForegroundColor White
    Write-Host "  3. Le mot de passe est correct" -ForegroundColor White
}
