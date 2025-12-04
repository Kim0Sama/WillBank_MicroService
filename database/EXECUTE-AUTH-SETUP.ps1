# Script PowerShell pour configurer l'authentification WillBank
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Configuration Authentification WillBank" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ce script va:" -ForegroundColor Yellow
Write-Host "  1. Ajouter les colonnes password et role" -ForegroundColor White
Write-Host "  2. Mettre à jour les données existantes" -ForegroundColor White
Write-Host "  3. Créer les utilisateurs de test" -ForegroundColor White
Write-Host ""
Write-Host "Utilisateurs qui seront créés:" -ForegroundColor Yellow
Write-Host "  - jean.dupont@example.com (CLIENT)" -ForegroundColor White
Write-Host "  - marie.martin@example.com (CLIENT)" -ForegroundColor White
Write-Host "  - admin@willbank.com (ADMIN)" -ForegroundColor White
Write-Host ""
Write-Host "Mot de passe pour tous: password123" -ForegroundColor Green
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$mysqlPassword = Read-Host "Entrez le mot de passe root MySQL" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($mysqlPassword)
$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

Write-Host ""
Write-Host "Exécution du script SQL..." -ForegroundColor Yellow
Write-Host ""

$mysqlPath = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"

if (Test-Path $mysqlPath) {
    $scriptPath = Join-Path $PSScriptRoot "setup-auth-complete.sql"
    
    # Exécuter le script SQL
    $process = Start-Process -FilePath $mysqlPath -ArgumentList "-u", "root", "-p$password", "-e", "source $scriptPath" -NoNewWindow -Wait -PassThru
    
    if ($process.ExitCode -eq 0) {
        Write-Host ""
        Write-Host "============================================" -ForegroundColor Green
        Write-Host "Configuration terminée avec succès!" -ForegroundColor Green
        Write-Host "============================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Vous pouvez maintenant:" -ForegroundColor White
        Write-Host "  1. Démarrer les services: ..\start-services-clean.ps1" -ForegroundColor Cyan
        Write-Host "  2. Vous connecter avec:" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "     CLIENT:" -ForegroundColor Yellow
        Write-Host "       Email: jean.dupont@example.com" -ForegroundColor White
        Write-Host "       Password: password123" -ForegroundColor White
        Write-Host ""
        Write-Host "     ADMIN:" -ForegroundColor Yellow
        Write-Host "       Email: admin@willbank.com" -ForegroundColor White
        Write-Host "       Password: password123" -ForegroundColor White
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "============================================" -ForegroundColor Red
        Write-Host "ERREUR lors de la configuration" -ForegroundColor Red
        Write-Host "============================================" -ForegroundColor Red
        Write-Host ""
        Write-Host "Vérifiez que:" -ForegroundColor Yellow
        Write-Host "  - MySQL est démarré" -ForegroundColor White
        Write-Host "  - Le mot de passe root est correct" -ForegroundColor White
        Write-Host "  - La base willbank_client_db existe" -ForegroundColor White
        Write-Host ""
    }
} else {
    Write-Host ""
    Write-Host "ERREUR: MySQL n'est pas installé à l'emplacement par défaut" -ForegroundColor Red
    Write-Host "Chemin attendu: $mysqlPath" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Vous pouvez exécuter le script manuellement:" -ForegroundColor Yellow
    Write-Host "  mysql -u root -p < setup-auth-complete.sql" -ForegroundColor White
    Write-Host ""
}

Write-Host "Appuyez sur une touche pour continuer..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
