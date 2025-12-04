# Script PowerShell pour changer toutes les devises vers XOF
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Correction des devises vers XOF (Franc CFA)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Ce script va changer TOUTES les devises (USD, EUR, etc.)" -ForegroundColor Yellow
Write-Host "vers XOF (Franc CFA) dans la base de données." -ForegroundColor Yellow
Write-Host ""

$confirmation = Read-Host "Voulez-vous continuer? (O/N)"
if ($confirmation -ne 'O' -and $confirmation -ne 'o') {
    Write-Host "Opération annulée." -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "Exécution du script SQL..." -ForegroundColor Green
Write-Host ""

# Demander le mot de passe MySQL
$mysqlPath = "mysql"

# Vérifier si MySQL est accessible
try {
    $null = & $mysqlPath --version 2>&1
} catch {
    Write-Host "ERREUR: MySQL n'est pas trouvé dans le PATH." -ForegroundColor Red
    Write-Host "Assurez-vous que MySQL est installé et accessible." -ForegroundColor Red
    Write-Host ""
    Write-Host "Vous pouvez aussi exécuter manuellement:" -ForegroundColor Yellow
    Write-Host "  mysql -u root -p < fix-all-currencies-to-xof.sql" -ForegroundColor White
    Write-Host ""
    pause
    exit 1
}

# Exécuter le script SQL
try {
    & $mysqlPath -u root -p < fix-all-currencies-to-xof.sql
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "✓ Mise à jour terminée avec succès!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Prochaines étapes:" -ForegroundColor Cyan
    Write-Host "1. Rechargez la page du frontend (F5)" -ForegroundColor White
    Write-Host "2. Vérifiez que tous les montants s'affichent en XOF" -ForegroundColor White
    Write-Host ""
} catch {
    Write-Host ""
    Write-Host "ERREUR lors de l'exécution du script:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Essayez d'exécuter manuellement:" -ForegroundColor Yellow
    Write-Host "  mysql -u root -p < fix-all-currencies-to-xof.sql" -ForegroundColor White
    Write-Host ""
}

pause
