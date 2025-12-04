# Test de création de compte

Write-Host "=== Test de creation de compte ===" -ForegroundColor Cyan
Write-Host ""

# 1. Connexion
Write-Host "1. Connexion..." -ForegroundColor Yellow

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
    
    Write-Host "  Connexion reussie - User ID: $($loginResponse.userId)" -ForegroundColor Green
    
    $token = $loginResponse.token
    $userId = $loginResponse.userId
    $headers = @{ Authorization = "Bearer $token" }
    
    # 2. Vérifier le statut du client
    Write-Host "`n2. Verification du client..." -ForegroundColor Yellow
    
    try {
        $client = Invoke-RestMethod -Uri "http://localhost:8080/api/clients/$userId" `
            -Method Get `
            -Headers $headers `
            -ErrorAction Stop
        
        Write-Host "  Nom: $($client.firstName) $($client.lastName)" -ForegroundColor Cyan
        Write-Host "  Status: $($client.status)" -ForegroundColor Cyan
        Write-Host "  KYC Status: $($client.kycStatus)" -ForegroundColor Cyan
        
        if ($client.status -ne "ACTIVE") {
            Write-Host "  ATTENTION: Le client n'est pas ACTIVE!" -ForegroundColor Red
        }
        if ($client.kycStatus -ne "VERIFIED") {
            Write-Host "  ATTENTION: Le KYC n'est pas VERIFIED!" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "  Erreur: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # 3. Créer un compte
    Write-Host "`n3. Creation d'un compte..." -ForegroundColor Yellow
    
    $accountBody = @{
        customerId = $userId
        accountType = "CHECKING"
        initialBalance = 1000.00
    } | ConvertTo-Json
    
    Write-Host "  Requete: $accountBody" -ForegroundColor Gray
    
    try {
        $newAccount = Invoke-RestMethod -Uri "http://localhost:8080/api/accounts" `
            -Method Post `
            -Headers $headers `
            -ContentType "application/json" `
            -Body $accountBody `
            -ErrorAction Stop
        
        Write-Host "  Compte cree avec succes!" -ForegroundColor Green
        Write-Host "  Numero: $($newAccount.accountNumber)" -ForegroundColor Cyan
        Write-Host "  Type: $($newAccount.accountType)" -ForegroundColor Cyan
        Write-Host "  Solde: $($newAccount.balance) EUR" -ForegroundColor Cyan
        Write-Host "  Status: $($newAccount.status)" -ForegroundColor Cyan
        
        # 4. Vérifier les comptes
        Write-Host "`n4. Verification des comptes..." -ForegroundColor Yellow
        
        $accounts = Invoke-RestMethod -Uri "http://localhost:8080/api/accounts/customer/$userId" `
            -Method Get `
            -Headers $headers `
            -ErrorAction Stop
        
        Write-Host "  Total: $($accounts.Count) compte(s)" -ForegroundColor Green
        foreach ($acc in $accounts) {
            Write-Host "    - $($acc.accountNumber): $($acc.accountType) - $($acc.balance) EUR" -ForegroundColor White
        }
        
        Write-Host "`n=== Test reussi! ===" -ForegroundColor Green
        Write-Host "La creation de compte fonctionne correctement." -ForegroundColor Green
        
    }
    catch {
        Write-Host "  Erreur lors de la creation: $($_.Exception.Message)" -ForegroundColor Red
        
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "  Details: $responseBody" -ForegroundColor Yellow
        }
        
        Write-Host "`nCauses possibles:" -ForegroundColor Yellow
        Write-Host "  1. Le client n'est pas ACTIVE" -ForegroundColor White
        Write-Host "  2. Le KYC n'est pas VERIFIED" -ForegroundColor White
        Write-Host "  3. Le Account Service ne peut pas contacter le Client Service" -ForegroundColor White
        Write-Host "  4. Probleme de validation des donnees" -ForegroundColor White
    }
}
catch {
    Write-Host "  Erreur de connexion: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
