# Script PowerShell pour configurer MySQL pour WillBank
# Usage: .\setup-mysql.ps1

param(
    [string]$RootPassword = ""
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Configuration MySQL pour WillBank" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Demander le mot de passe root si non fourni
if ([string]::IsNullOrEmpty($RootPassword)) {
    $SecurePassword = Read-Host "Entrez le mot de passe root MySQL" -AsSecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
    $RootPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
}

# Vérifier que MySQL est installé
Write-Host "Vérification de MySQL..." -NoNewline
try {
    $mysqlVersion = mysql --version 2>&1
    Write-Host " ✅ MySQL détecté" -ForegroundColor Green
    Write-Host "   Version: $mysqlVersion" -ForegroundColor Yellow
} catch {
    Write-Host " ❌ MySQL n'est pas installé ou n'est pas dans le PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Veuillez installer MySQL depuis:" -ForegroundColor Yellow
    Write-Host "https://dev.mysql.com/downloads/installer/" -ForegroundColor Cyan
    exit 1
}

Write-Host ""

# Tester la connexion root
Write-Host "Test de connexion à MySQL..." -NoNewline
try {
    $testQuery = "SELECT 1;" | mysql -u root -p"$RootPassword" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅ Connexion réussie" -ForegroundColor Green
    } else {
        Write-Host " ❌ Échec de connexion" -ForegroundColor Red
        Write-Host "Erreur: Mot de passe root incorrect" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host " ❌ Erreur de connexion" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Exécuter le script de création
Write-Host "Création des bases de données..." -ForegroundColor Yellow
Write-Host ""

$scriptPath = Join-Path $PSScriptRoot "create-databases.sql"

if (-not (Test-Path $scriptPath)) {
    Write-Host "❌ Fichier create-databases.sql non trouvé" -ForegroundColor Red
    exit 1
}

try {
    Get-Content $scriptPath | mysql -u root -p"$RootPassword" 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Bases de données créées avec succès!" -ForegroundColor Green
    } else {
        Write-Host "❌ Erreur lors de la création des bases de données" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Erreur: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Vérification
Write-Host "Vérification des bases de données..." -ForegroundColor Yellow

$databases = "SHOW DATABASES LIKE 'willbank%';" | mysql -u root -p"$RootPassword" -N 2>&1

if ($databases -match "willbank_client_db" -and 
    $databases -match "willbank_account_db" -and 
    $databases -match "willbank_transaction_db") {
    Write-Host "✅ Toutes les bases de données sont créées:" -ForegroundColor Green
    Write-Host "   - willbank_client_db" -ForegroundColor Cyan
    Write-Host "   - willbank_account_db" -ForegroundColor Cyan
    Write-Host "   - willbank_transaction_db" -ForegroundColor Cyan
} else {
    Write-Host "⚠ Certaines bases de données sont manquantes" -ForegroundColor Yellow
}

Write-Host ""

# Vérification des utilisateurs
Write-Host "Vérification des utilisateurs..." -ForegroundColor Yellow

$users = "SELECT User FROM mysql.user WHERE User LIKE '%service%';" | mysql -u root -p"$RootPassword" -N 2>&1

if ($users -match "client_service_user" -and 
    $users -match "account_service_user" -and 
    $users -match "transaction_service_user") {
    Write-Host "✅ Tous les utilisateurs sont créés:" -ForegroundColor Green
    Write-Host "   - client_service_user" -ForegroundColor Cyan
    Write-Host "   - account_service_user" -ForegroundColor Cyan
    Write-Host "   - transaction_service_user" -ForegroundColor Cyan
} else {
    Write-Host "⚠ Certains utilisateurs sont manquants" -ForegroundColor Yellow
}

Write-Host ""

# Test des connexions
Write-Host "Test des connexions des services..." -ForegroundColor Yellow

# Test Client Service
Write-Host "  Client Service..." -NoNewline
try {
    $result = "SELECT COUNT(*) FROM clients;" | mysql -u client_service_user -pClientService2024! willbank_client_db -N 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅ $result client(s)" -ForegroundColor Green
    } else {
        Write-Host " ❌ Erreur" -ForegroundColor Red
    }
} catch {
    Write-Host " ❌ Erreur" -ForegroundColor Red
}

# Test Account Service
Write-Host "  Account Service..." -NoNewline
try {
    $result = "SELECT COUNT(*) FROM accounts;" | mysql -u account_service_user -pAccountService2024! willbank_account_db -N 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅ $result compte(s)" -ForegroundColor Green
    } else {
        Write-Host " ❌ Erreur" -ForegroundColor Red
    }
} catch {
    Write-Host " ❌ Erreur" -ForegroundColor Red
}

# Test Transaction Service
Write-Host "  Transaction Service..." -NoNewline
try {
    $result = "SELECT COUNT(*) FROM transactions;" | mysql -u transaction_service_user -pTransactionService2024! willbank_transaction_db -N 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅ $result transaction(s)" -ForegroundColor Green
    } else {
        Write-Host " ❌ Erreur" -ForegroundColor Red
    }
} catch {
    Write-Host " ❌ Erreur" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Configuration terminée!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Prochaines étapes:" -ForegroundColor Cyan
Write-Host "1. Compiler les services: .\mvnw.cmd clean compile" -ForegroundColor White
Write-Host "2. Démarrer Eureka Server" -ForegroundColor White
Write-Host "3. Démarrer les microservices" -ForegroundColor White
Write-Host ""
Write-Host "Documentation: database/SETUP_MYSQL.md" -ForegroundColor Yellow
