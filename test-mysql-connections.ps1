# Script pour tester les connexions MySQL des services

$ErrorActionPreference = "Continue"

function Write-Success { param($msg) Write-Host $msg -ForegroundColor Green }
function Write-Info { param($msg) Write-Host $msg -ForegroundColor Cyan }
function Write-Error { param($msg) Write-Host $msg -ForegroundColor Red }

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         Test des connexions MySQL WillBank                   ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$mysqlPath = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"

if (-not (Test-Path $mysqlPath)) {
    Write-Error "MySQL non trouvé à: $mysqlPath"
    Write-Info "Veuillez ajuster le chemin dans le script"
    exit 1
}

# Test des connexions
$services = @(
    @{
        Name = "Client Service"
        Database = "willbank_client_db"
        User = "client_service_user"
        Password = "ClientService2024!"
    },
    @{
        Name = "Account Service"
        Database = "willbank_account_db"
        User = "account_service_user"
        Password = "AccountService2024!"
    },
    @{
        Name = "Transaction Service"
        Database = "willbank_transaction_db"
        User = "transaction_service_user"
        Password = "TransactionService2024!"
    }
)

$successCount = 0

foreach ($service in $services) {
    Write-Host "Test de $($service.Name)..." -NoNewline
    
    $env:MYSQL_PWD = $service.Password
    $query = "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA='$($service.Database)';"
    
    try {
        $result = & $mysqlPath -u $service.User -e $query 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success " ✓ OK"
            Write-Host "   Base: $($service.Database)" -ForegroundColor Gray
            Write-Host "   User: $($service.User)" -ForegroundColor Gray
            $successCount++
        } else {
            Write-Error " ✗ ÉCHEC"
            Write-Host "   Erreur: $result" -ForegroundColor Red
        }
    } catch {
        Write-Error " ✗ ERREUR"
        Write-Host "   $_" -ForegroundColor Red
    }
    
    Remove-Item Env:\MYSQL_PWD -ErrorAction SilentlyContinue
    Write-Host ""
}

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

if ($successCount -eq $services.Count) {
    Write-Success "✅ Toutes les connexions MySQL fonctionnent!"
} else {
    Write-Error "❌ $($services.Count - $successCount) connexion(s) en échec"
    Write-Host ""
    Write-Info "Solutions:"
    Write-Host "  1. Vérifiez que MySQL est démarré" -ForegroundColor White
    Write-Host "  2. Exécutez: cd database && .\EXECUTE_ME.bat" -ForegroundColor White
    Write-Host "  3. Vérifiez les mots de passe dans application.yaml" -ForegroundColor White
}

Write-Host ""
