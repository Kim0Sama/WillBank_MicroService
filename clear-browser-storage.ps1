# Script pour nettoyer le localStorage du navigateur
Write-Host "=== Nettoyage du localStorage ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pour nettoyer le localStorage et forcer une nouvelle connexion:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Option 1 - Via la console du navigateur (F12):" -ForegroundColor Green
Write-Host "  localStorage.clear();" -ForegroundColor White
Write-Host "  location.reload();" -ForegroundColor White
Write-Host ""
Write-Host "Option 2 - Via les DevTools:" -ForegroundColor Green
Write-Host "  1. Ouvrir DevTools (F12)" -ForegroundColor White
Write-Host "  2. Aller dans l'onglet 'Application' ou 'Storage'" -ForegroundColor White
Write-Host "  3. Cliquer sur 'Local Storage' > 'http://localhost:4200'" -ForegroundColor White
Write-Host "  4. Supprimer les clés 'token' et 'currentUser'" -ForegroundColor White
Write-Host "  5. Recharger la page (F5)" -ForegroundColor White
Write-Host ""
Write-Host "Option 3 - Mode navigation privée:" -ForegroundColor Green
Write-Host "  Ouvrir le frontend en mode navigation privée (Ctrl+Shift+N)" -ForegroundColor White
Write-Host ""
Write-Host "L'application a été modifiée pour forcer la déconnexion au démarrage." -ForegroundColor Cyan
Write-Host "Rechargez simplement la page pour être redirigé vers le login." -ForegroundColor Cyan
