# Script de diagnostic complet de l'authentification
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Diagnostic Authentification WillBank" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Vérifier les services
Write-Host "1. Vérification des services..." -ForegroundColor Yellow
$ports = @{
    "8761" = "Eureka Server"
    "8080" = "Gateway Service"
    "8084" = "Client Service"
}

foreach ($port in $ports.Keys) {
    $listening = netstat -ano | Select-String ":$port\s" | Select-String "LISTENING"
    if ($listening) {
        Write-Host "  ✓ $($ports[$port]) (port $port)" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $($ports[$port]) (port $port) - NON DÉMARRÉ" -ForegroundColor Red
    }
}

Write-Host ""

# Test 2: Vérifier la base de données
Write-Host "2. Vérification de la base de données..." -ForegroundColor Yellow
$mysqlPassword = Read-Host "Entrez le mot de passe root MySQL" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($mysqlPassword)
$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

$mysqlPath = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"

if (Test-Path $mysqlPath) {
    $query = "USE willbank_client_db; SELECT email, role, CASE WHEN password = '`$2a`$10`$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.rsS3/r/7HNtBJFgEy2' THEN 'password123' ELSE 'autre' END as pwd FROM clients LIMIT 5;"
    
    Write-Host ""
    Write-Host "Utilisateurs dans la base de données:" -ForegroundColor Cyan
    & $mysqlPath -u root "-p$password" -e $query 2>$null
    Write-Host ""
} else {
    Write-Host "  ✗ MySQL non trouvé" -ForegroundColor Red
}

# Test 3: Test API direct
Write-Host "3. Test de l'API d'authentification..." -ForegroundColor Yellow

$testUsers = @(
    @{email="jean.dupont@example.com"; password="password123"},
    @{email="admin@willbank.com"; password="password123"},
    @{email="marie.martin@example.com"; password="password123"}
)

foreach ($user in $testUsers) {
    $body = @{
        email = $user.email
        password = $user.password
    } | ConvertTo-Json

    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/login" `
            -Method POST `
            -ContentType "application/json" `
            -Body $body `
            -ErrorAction Stop
        
        Write-Host "  ✓ $($user.email) - CONNEXION RÉUSSIE" -ForegroundColor Green
        $result = $response.Content | ConvertFrom-Json
        Write-Host "    Role: $($result.role)" -ForegroundColor Gray
        return
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($statusCode -eq 401) {
            Write-Host "  ✗ $($user.email) - Mot de passe incorrect ou utilisateur inexistant" -ForegroundColor Red
        } else {
            Write-Host "  ✗ $($user.email) - Erreur $statusCode" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "Diagnostic terminé" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Si tous les tests échouent:" -ForegroundColor White
Write-Host "1. Vérifiez les logs du Client Service" -ForegroundColor Cyan
Write-Host "2. Vérifiez que les colonnes password et role existent" -ForegroundColor Cyan
Write-Host "3. Redémarrez le Client Service" -ForegroundColor Cyan
Write-Host ""
