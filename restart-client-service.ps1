# Script pour redémarrer uniquement le Client Service
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Redémarrage du Client Service" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Fonction pour tuer les processus sur un port
function Kill-ProcessOnPort {
    param([int]$Port)
    
    $connections = netstat -ano | Select-String ":$Port\s" | Select-String "LISTENING"
    if ($connections) {
        foreach ($conn in $connections) {
            $pid = ($conn -split '\s+')[-1]
            if ($pid -and $pid -match '^\d+$') {
                Write-Host "Arrêt du processus sur le port $Port (PID: $pid)..." -ForegroundColor Yellow
                taskkill /F /PID $pid 2>$null
            }
        }
    }
}

# Arrêter le Client Service
Write-Host "Arrêt du Client Service..." -ForegroundColor Yellow
Kill-ProcessOnPort -Port 8084
Start-Sleep -Seconds 2

# Redémarrer le Client Service
Write-Host "Démarrage du Client Service..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\Client_service'; mvn spring-boot:run" -WindowStyle Normal

Write-Host ""
Write-Host "Attente du démarrage (15 secondes)..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Client Service redémarré!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Vous pouvez maintenant tester la connexion" -ForegroundColor White
Write-Host ""
