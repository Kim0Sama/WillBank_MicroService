# Test du comportement de déconnexion automatique
Write-Host "=== Test de la déconnexion automatique ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "Instructions de test:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Ouvrez le frontend: http://localhost:4200" -ForegroundColor White
Write-Host "   → Vous devez voir la page de login" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Connectez-vous avec:" -ForegroundColor White
Write-Host "   Email: admin@willbank.com" -ForegroundColor Gray
Write-Host "   Password: admin123" -ForegroundColor Gray
Write-Host "   → Vous devez être redirigé vers /admin" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Rechargez la page (F5)" -ForegroundColor White
Write-Host "   → Vous devez être déconnecté et redirigé vers /login" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Essayez d'accéder directement à: http://localhost:4200/dashboard" -ForegroundColor White
Write-Host "   → Vous devez être redirigé vers /login" -ForegroundColor Gray
Write-Host ""

Write-Host "Comportement attendu:" -ForegroundColor Green
Write-Host "✓ Déconnexion automatique à chaque rechargement" -ForegroundColor White
Write-Host "✓ Aucun accès aux pages protégées sans authentification" -ForegroundColor White
Write-Host "✓ Redirection vers /login pour toutes les routes protégées" -ForegroundColor White
Write-Host ""

Write-Host "Pour modifier ce comportement en production:" -ForegroundColor Yellow
Write-Host "Voir: Frontend/AUTHENTICATION_CONFIG.md" -ForegroundColor White
Write-Host ""

# Vérifier que le frontend est accessible
Write-Host "Vérification de l'accessibilité du frontend..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:4200" -Method GET -TimeoutSec 5 -UseBasicParsing
    Write-Host "✓ Frontend accessible sur http://localhost:4200" -ForegroundColor Green
} catch {
    Write-Host "✗ Frontend non accessible. Assurez-vous qu'il est démarré avec 'ng serve'" -ForegroundColor Red
    Write-Host "  Erreur: $($_.Exception.Message)" -ForegroundColor Gray
}
Write-Host ""

# Vérifier que le backend est accessible
Write-Host "Vérification de l'accessibilité du backend..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/login" -Method POST -Body '{"email":"test","password":"test"}' -ContentType "application/json" -TimeoutSec 5 -UseBasicParsing -ErrorAction SilentlyContinue
} catch {
    if ($_.Exception.Response.StatusCode -eq 401 -or $_.Exception.Response.StatusCode -eq 400) {
        Write-Host "✓ Backend accessible sur http://localhost:8080" -ForegroundColor Green
    } else {
        Write-Host "✗ Backend non accessible. Assurez-vous que les services sont démarrés" -ForegroundColor Red
        Write-Host "  Erreur: $($_.Exception.Message)" -ForegroundColor Gray
    }
}
Write-Host ""

Write-Host "=== Test terminé ===" -ForegroundColor Cyan
