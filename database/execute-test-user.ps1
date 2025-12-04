# Script PowerShell pour créer les utilisateurs de test
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Creation des utilisateurs de test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Utilisateurs qui seront crees:" -ForegroundColor Yellow
Write-Host "1. jean.dupont@example.com (CLIENT) - password: password123" -ForegroundColor White
Write-Host "2. admin@willbank.com (ADMIN) - password: password123" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$mysqlPassword = Read-Host "Entrez le mot de passe root MySQL" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($mysqlPassword)
$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

Write-Host ""
Write-Host "Execution du script SQL..." -ForegroundColor Yellow

$mysqlPath = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"

if (Test-Path $mysqlPath) {
    $scriptPath = Join-Path $PSScriptRoot "create-test-user.sql"
    & $mysqlPath -u root "-p$password" -e "source $scriptPath"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "Utilisateurs crees avec succes!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Vous pouvez maintenant vous connecter avec:" -ForegroundColor White
        Write-Host "  Email: jean.dupont@example.com" -ForegroundColor Cyan
        Write-Host "  Password: password123" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Ou en tant qu'admin:" -ForegroundColor White
        Write-Host "  Email: admin@willbank.com" -ForegroundColor Cyan
        Write-Host "  Password: password123" -ForegroundColor Cyan
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "ERREUR: Echec de la creation des utilisateurs" -ForegroundColor Red
        Write-Host "Verifiez que MySQL est demarre et que le mot de passe est correct" -ForegroundColor Yellow
        Write-Host ""
    }
} else {
    Write-Host "ERREUR: MySQL n'est pas installe a l'emplacement par defaut" -ForegroundColor Red
    Write-Host "Chemin attendu: $mysqlPath" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "Appuyez sur une touche pour continuer..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
