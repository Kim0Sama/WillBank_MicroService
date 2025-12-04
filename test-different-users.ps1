# Test de connexion avec differents utilisateurs

$users = @(
    @{ email = "jean.dupont@example.com"; password = "password123" },
    @{ email = "admin@willbank.com"; password = "password123" },
    @{ email = "marie.martin@example.com"; password = "password123" }
)

Write-Host "=== Test de connexion avec differents utilisateurs ===" -ForegroundColor Cyan
Write-Host ""

foreach ($user in $users) {
    Write-Host "Test avec: $($user.email)" -NoNewline
    
    $body = @{
        email = $user.email
        password = $user.password
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
            -Method Post `
            -ContentType "application/json" `
            -Body $body `
            -ErrorAction Stop
        
        Write-Host " OK" -ForegroundColor Green
        Write-Host "  User ID: $($response.userId)" -ForegroundColor Cyan
        Write-Host "  Name: $($response.firstName) $($response.lastName)" -ForegroundColor Cyan
        Write-Host "  Role: $($response.role)" -ForegroundColor Cyan
        Write-Host ""
        
        # Test de recuperation des comptes
        $headers = @{ Authorization = "Bearer $($response.token)" }
        $accounts = Invoke-RestMethod -Uri "http://localhost:8080/api/accounts/customer/$($response.userId)" `
            -Method Get `
            -Headers $headers `
            -ErrorAction Stop
        
        Write-Host "  Nombre de comptes: $($accounts.Count)" -ForegroundColor Green
        Write-Host ""
    }
    catch {
        Write-Host " FAILED" -ForegroundColor Red
        if ($_.Exception.Response.StatusCode.value__ -eq 401) {
            Write-Host "  Erreur: Identifiants incorrects" -ForegroundColor Yellow
        } else {
            Write-Host "  Erreur: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        Write-Host ""
    }
}
