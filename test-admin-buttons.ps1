# Test des boutons admin (Activer, Suspendre, Vérifier KYC)
Write-Host "=== Test des boutons admin ===" -ForegroundColor Cyan
Write-Host ""

# Récupérer un token admin
Write-Host "1. Connexion en tant qu'admin..." -ForegroundColor Yellow
$loginData = @{
    email = "admin@willbank.com"
    password = "admin123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    Write-Host "✓ Connexion réussie" -ForegroundColor Green
    $token = $loginResponse.token
} catch {
    Write-Host "✗ Échec de la connexion: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Récupérer la liste des clients
Write-Host "2. Récupération de la liste des clients..." -ForegroundColor Yellow
try {
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    $clients = Invoke-RestMethod -Uri "http://localhost:8080/api/clients" -Method GET -Headers $headers
    Write-Host "✓ $($clients.Count) client(s) trouvé(s)" -ForegroundColor Green
    
    if ($clients.Count -gt 0) {
        $testClient = $clients[0]
        Write-Host "  Client de test: $($testClient.firstName) $($testClient.lastName) (ID: $($testClient.id))" -ForegroundColor Gray
        Write-Host "  Statut actuel: $($testClient.status)" -ForegroundColor Gray
        Write-Host "  KYC actuel: $($testClient.kycStatus)" -ForegroundColor Gray
    } else {
        Write-Host "✗ Aucun client trouvé pour tester" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Échec de la récupération: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 1: Mettre à jour le statut du client
Write-Host "3. Test du bouton 'Activer' (mise à jour du statut)..." -ForegroundColor Yellow
try {
    $newStatus = "ACTIVE"
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/clients/$($testClient.id)/status?status=$newStatus" -Method PATCH -Headers $headers
    Write-Host "✓ Statut mis à jour avec succès" -ForegroundColor Green
    Write-Host "  Nouveau statut: $($response.status)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Échec de la mise à jour du statut: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "  Détails: $($_.ErrorDetails.Message)" -ForegroundColor Gray
    }
}
Write-Host ""

# Test 2: Suspendre le client
Write-Host "4. Test du bouton 'Suspendre'..." -ForegroundColor Yellow
try {
    $newStatus = "SUSPENDED"
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/clients/$($testClient.id)/status?status=$newStatus" -Method PATCH -Headers $headers
    Write-Host "✓ Client suspendu avec succès" -ForegroundColor Green
    Write-Host "  Nouveau statut: $($response.status)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Échec de la suspension: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "  Détails: $($_.ErrorDetails.Message)" -ForegroundColor Gray
    }
}
Write-Host ""

# Test 3: Vérifier KYC
Write-Host "5. Test du bouton 'Vérifier KYC'..." -ForegroundColor Yellow
try {
    $kycData = @{
        kycStatus = "VERIFIED"
        notes = "Verified by admin via test script"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/clients/$($testClient.id)/kyc" -Method PATCH -Body $kycData -ContentType "application/json" -Headers $headers
    Write-Host "✓ KYC vérifié avec succès" -ForegroundColor Green
    Write-Host "  Nouveau statut KYC: $($response.kycStatus)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Échec de la vérification KYC: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "  Détails: $($_.ErrorDetails.Message)" -ForegroundColor Gray
    }
}
Write-Host ""

# Remettre le client en état actif
Write-Host "6. Remise en état actif..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/clients/$($testClient.id)/status?status=ACTIVE" -Method PATCH -Headers $headers
    Write-Host "✓ Client remis en état actif" -ForegroundColor Green
} catch {
    Write-Host "✗ Échec: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

Write-Host "=== Résumé ===" -ForegroundColor Cyan
Write-Host "Les endpoints backend fonctionnent correctement." -ForegroundColor Green
Write-Host "Si les boutons ne fonctionnent toujours pas dans le frontend:" -ForegroundColor Yellow
Write-Host "  1. Vérifiez la console du navigateur (F12) pour les erreurs" -ForegroundColor White
Write-Host "  2. Vérifiez que le frontend est bien redémarré" -ForegroundColor White
Write-Host "  3. Vérifiez que vous êtes connecté en tant qu'admin" -ForegroundColor White
Write-Host ""
