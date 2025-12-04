# Script pour exécuter le setup MySQL
# Usage: .\run-setup.ps1 -Password "votre_mot_de_passe_root"

param([string]$Password)

$mysqlExe = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
$scriptPath = "D:\ARCHIDESSI\WillBank\WillBank_MicroService\database\create-databases.sql"

if (-not $Password) {
    Write-Host "Entrez le mot de passe root MySQL:"
    $securePassword = Read-Host -AsSecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
    $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
}

Write-Host "Execution du script SQL..." -ForegroundColor Yellow

$env:MYSQL_PWD = $Password
& $mysqlExe -u root -e "source $scriptPath"
Remove-Item Env:\MYSQL_PWD -ErrorAction SilentlyContinue

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "SUCCESS!" -ForegroundColor Green
    Write-Host "Bases de donnees creees:" -ForegroundColor Cyan
    Write-Host "  - willbank_client_db" -ForegroundColor White
    Write-Host "  - willbank_account_db" -ForegroundColor White
    Write-Host "  - willbank_transaction_db" -ForegroundColor White
} else {
    Write-Host "ERREUR!" -ForegroundColor Red
}
