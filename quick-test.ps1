# Test rapide après le fix

Write-Host "=== Test rapide ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT: Assurez-vous d'avoir redémarre le Client Service!" -ForegroundColor Yellow
Write-Host "Appuyez sur une touche pour continuer..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host "`nTest de connexion..." -ForegroundColor Cyan

$loginBody = @{
    email = "jean.dupont@example.com"
    password = "password123"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
        -Method Post `
        -ContentType "application/json" `
        -Body $loginBody
    
    Write-Host "Connexion OK - User ID: $($response.userId)" -ForegroundColor Green
    
    $headers = @{ Authorization = "Bearer $($response.token)" }
    
    Write-Host "Test recuperation comptes..." -ForegroundColor Cyan
    $accounts = Invoke-RestMethod -Uri "http://localhost:8080/api/accounts/customer/$($response.userId)" `
        -Method Get `
        -Headers $headers
    
    Write-Host "Comptes recuperes: $($accounts.Count)" -ForegroundColor Green
    
    if ($accounts.Count -eq 0) {
        Write-Host "`nAucun compte. Voulez-vous en creer? (O/N)" -ForegroundColor Yellow
        $create = Read-Host
        
        if ($create -eq "O" -or $create -eq "o") {
            $accountBody = @{
                customerId = $response.userId
                accountType = "CHECKING"
                initialDeposit = 5000.00
            } | ConvertTo-Json
            
            $newAccount = Invoke-RestMethod -Uri "http://localhost:8080/api/accounts" `
                -Method Post `
                -Headers $headers `
                -ContentType "application/json" `
                -Body $accountBody
            
            Write-Host "Compte cree: $($newAccount.accountNumber)" -ForegroundColor Green
        }
    } else {
        foreach ($acc in $accounts) {
            Write-Host "  - $($acc.accountNumber): $($acc.balance) EUR" -ForegroundColor Cyan
        }
    }
    
    Write-Host "`nTout fonctionne!" -ForegroundColor Green
}
catch {
    Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nAvez-vous redémarre le Client Service?" -ForegroundColor Yellow
}
