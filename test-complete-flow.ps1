# Test du flux complet d'authentification et de récupération des comptes

Write-Host "=== Test du flux complet WillBank ===" -ForegroundColor Cyan
Write-Host ""

# 1. Test de connexion
Write-Host "1. Test de connexion..." -ForegroundColor Yellow
$loginBody = @{
    email = "jean.dupont@email.com"
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
    Write-Host "  Email: $($loginResponse.email)" -ForegroundColor Cyan
    Write-Host "  Name: $($loginResponse.firstName) $($loginResponse.lastName)" -ForegroundColor Cyan
    Write-Host "  Role: $($loginResponse.role)" -ForegroundColor Cyan
    Write-Host "  Token: $($loginResponse.token.Substring(0, 20))..." -ForegroundColor Cyan
    
    $token = $loginResponse.token
    $userId = $loginResponse.userId
    
    # 2. Test de recuperation des comptes via Gateway
    Write-Host "`n2. Test de recuperation des comptes via Gateway..." -ForegroundColor Yellow
    
    try {
        $headers = @{
            Authorization = "Bearer $token"
        }
        
        $accounts = Invoke-RestMethod -Uri "http://localhost:8080/api/accounts/customer/$userId" `
            -Method Get `
            -Headers $headers `
            -ErrorAction Stop
        
        Write-Host "  Comptes recuperes avec succes!" -ForegroundColor Green
        Write-Host "  Nombre de comptes: $($accounts.Count)" -ForegroundColor Cyan
        
        foreach ($account in $accounts) {
            Write-Host "`n  Compte:" -ForegroundColor White
            Write-Host "    - Numéro: $($account.accountNumber)" -ForegroundColor Cyan
            Write-Host "    - Type: $($account.accountType)" -ForegroundColor Cyan
            Write-Host "    - Solde: $($account.balance) EUR" -ForegroundColor Cyan
            Write-Host "    - Statut: $($account.status)" -ForegroundColor Cyan
        }
        
        # 3. Test de recuperation du client
        Write-Host "`n3. Test de recuperation des informations client..." -ForegroundColor Yellow
        
        try {
            $client = Invoke-RestMethod -Uri "http://localhost:8080/api/clients/$userId" `
                -Method Get `
                -Headers $headers `
                -ErrorAction Stop
            
            Write-Host "  Informations client recuperees!" -ForegroundColor Green
            Write-Host "  Nom: $($client.firstName) $($client.lastName)" -ForegroundColor Cyan
            Write-Host "  Email: $($client.email)" -ForegroundColor Cyan
            Write-Host "  Telephone: $($client.phoneNumber)" -ForegroundColor Cyan
        }
        catch {
            Write-Host "  Erreur lors de la recuperation du client" -ForegroundColor Red
            Write-Host "  $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        Write-Host "`n=== Test reussi! ===" -ForegroundColor Green
        Write-Host "Le backend fonctionne correctement." -ForegroundColor Green
        Write-Host ""
        Write-Host "Si le frontend ne fonctionne pas:" -ForegroundColor Yellow
        Write-Host "  1. Vérifiez que le frontend est démarré (ng serve)" -ForegroundColor White
        Write-Host "  2. Vérifiez la console du navigateur pour les erreurs" -ForegroundColor White
        Write-Host "  3. Vérifiez que le token est bien stocké dans localStorage" -ForegroundColor White
        Write-Host "  4. Vérifiez que l'intercepteur HTTP ajoute bien le token" -ForegroundColor White
        
    }
    catch {
        Write-Host "  Erreur lors de la recuperation des comptes" -ForegroundColor Red
        Write-Host "  Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
        Write-Host "  Message: $($_.Exception.Message)" -ForegroundColor Yellow
        
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "  Response: $responseBody" -ForegroundColor Yellow
        }
    }
    
}
catch {
    Write-Host "  Erreur de connexion" -ForegroundColor Red
    Write-Host "  $($_.Exception.Message)" -ForegroundColor Yellow
    
    Write-Host "`nVerifiez:" -ForegroundColor Yellow
    Write-Host "  1. Que l'utilisateur existe dans la base de donnees" -ForegroundColor White
    Write-Host "  2. Que le mot de passe est correct" -ForegroundColor White
    Write-Host "  3. Que le Client Service est demarre" -ForegroundColor White
    Write-Host "  4. Que le Gateway est demarre" -ForegroundColor White
}

Write-Host ""
