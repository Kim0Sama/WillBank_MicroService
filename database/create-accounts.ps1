# Script PowerShell pour créer les comptes des utilisateurs de test

Write-Host "=== Creation des comptes pour les utilisateurs de test ===" -ForegroundColor Cyan
Write-Host ""

# Demander le mot de passe root MySQL
$mysqlPassword = Read-Host "Entrez le mot de passe root MySQL" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($mysqlPassword)
$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

$mysqlPath = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"

if (-not (Test-Path $mysqlPath)) {
    Write-Host "MySQL n'est pas trouve a l'emplacement par defaut." -ForegroundColor Red
    Write-Host "Veuillez specifier le chemin complet vers mysql.exe" -ForegroundColor Yellow
    exit 1
}

Write-Host "Execution du script SQL..." -ForegroundColor Yellow

try {
    Get-Content "create-accounts-for-test-users.sql" | & $mysqlPath -u root "-p$password" 2>&1 | Out-String | Write-Host
    
    Write-Host ""
    Write-Host "=== Comptes crees avec succes! ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "Vous pouvez maintenant vous connecter avec:" -ForegroundColor Cyan
    Write-Host "  - jean.dupont@example.com / password123" -ForegroundColor White
    Write-Host "  - admin@willbank.com / password123" -ForegroundColor White
    Write-Host ""
}
catch {
    Write-Host "Erreur lors de l'execution du script SQL" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}
