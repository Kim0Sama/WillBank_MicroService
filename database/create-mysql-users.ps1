# Script PowerShell pour créer les utilisateurs MySQL pour WillBank
# Exécute le script SQL de création des utilisateurs

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Création des utilisateurs MySQL WillBank" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Fonction pour trouver MySQL
function Find-MySQL {
    # Emplacements courants de MySQL sur Windows
    $possiblePaths = @(
        "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe",
        "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe",
        "C:\Program Files\MySQL\MySQL Server 9.0\bin\mysql.exe",
        "C:\Program Files (x86)\MySQL\MySQL Server 8.0\bin\mysql.exe",
        "C:\xampp\mysql\bin\mysql.exe",
        "C:\wamp64\bin\mysql\mysql8.0.27\bin\mysql.exe",
        "C:\wamp\bin\mysql\mysql8.0.27\bin\mysql.exe"
    )
    
    # Vérifier si mysql est dans le PATH
    try {
        $null = Get-Command mysql -ErrorAction Stop
        return "mysql"
    } catch {
        # Chercher dans les emplacements courants
        foreach ($path in $possiblePaths) {
            if (Test-Path $path) {
                Write-Host "✓ MySQL trouvé: $path" -ForegroundColor Green
                return $path
            }
        }
        
        # Chercher dans Program Files
        $mysqlDirs = Get-ChildItem "C:\Program Files\MySQL" -Directory -ErrorAction SilentlyContinue
        foreach ($dir in $mysqlDirs) {
            $mysqlExe = Join-Path $dir.FullName "bin\mysql.exe"
            if (Test-Path $mysqlExe) {
                Write-Host "✓ MySQL trouvé: $mysqlExe" -ForegroundColor Green
                return $mysqlExe
            }
        }
    }
    
    return $null
}

# Trouver MySQL
Write-Host "Recherche de MySQL..." -ForegroundColor Yellow
$mysqlPath = Find-MySQL

if ($null -eq $mysqlPath) {
    Write-Host ""
    Write-Host "✗ MySQL introuvable!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Solutions:" -ForegroundColor Yellow
    Write-Host "  1. Installez MySQL depuis: https://dev.mysql.com/downloads/mysql/" -ForegroundColor White
    Write-Host "  2. Ajoutez MySQL au PATH système" -ForegroundColor White
    Write-Host "  3. Utilisez MySQL Workbench pour exécuter create-databases.sql" -ForegroundColor White
    Write-Host ""
    Write-Host "Appuyez sur une touche pour continuer..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host ""

# Demander le mot de passe root MySQL
$rootPassword = Read-Host "Entrez le mot de passe root MySQL" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($rootPassword)
$plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

Write-Host ""
Write-Host "Exécution du script SQL..." -ForegroundColor Yellow

# Exécuter le script SQL
$scriptPath = Join-Path $PSScriptRoot "create-databases.sql"

try {
    # Utiliser mysql.exe avec le mot de passe
    $env:MYSQL_PWD = $plainPassword
    
    # Exécuter le script
    & $mysqlPath -u root --execute="source $scriptPath" 2>&1 | Out-String | Write-Host
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✓ Bases de données et utilisateurs créés avec succès!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Utilisateurs créés:" -ForegroundColor Cyan
        Write-Host "  - client_service_user (mot de passe: ClientService2024!)" -ForegroundColor White
        Write-Host "  - account_service_user (mot de passe: AccountService2024!)" -ForegroundColor White
        Write-Host "  - transaction_service_user (mot de passe: TransactionService2024!)" -ForegroundColor White
        Write-Host ""
        Write-Host "Bases de données créées:" -ForegroundColor Cyan
        Write-Host "  - willbank_client_db" -ForegroundColor White
        Write-Host "  - willbank_account_db" -ForegroundColor White
        Write-Host "  - willbank_transaction_db" -ForegroundColor White
    } else {
        Write-Host ""
        Write-Host "✗ Erreur lors de la création" -ForegroundColor Red
        Write-Host "Vérifiez que MySQL est démarré et que le mot de passe root est correct" -ForegroundColor Yellow
    }
} catch {
    Write-Host ""
    Write-Host "✗ Erreur: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Assurez-vous que:" -ForegroundColor Yellow
    Write-Host "  1. MySQL est installé et démarré" -ForegroundColor White
    Write-Host "  2. Le mot de passe root est correct" -ForegroundColor White
    Write-Host "  3. Le service MySQL est en cours d'exécution" -ForegroundColor White
} finally {
    # Nettoyer la variable d'environnement
    Remove-Item Env:\MYSQL_PWD -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "Appuyez sur une touche pour continuer..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
