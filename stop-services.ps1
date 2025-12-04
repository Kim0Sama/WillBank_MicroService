# Script pour arrêter tous les services WillBank

Write-Host "=== Stopping WillBank Services ===" -ForegroundColor Red
Write-Host ""

# Fonction pour tuer les processus sur un port
function Kill-ProcessOnPort {
    param([int]$Port)
    
    $connections = netstat -ano | Select-String ":$Port\s" | Select-String "LISTENING"
    if ($connections) {
        foreach ($conn in $connections) {
            $pid = ($conn -split '\s+')[-1]
            if ($pid -and $pid -match '^\d+$') {
                Write-Host "Stopping process on port $Port (PID: $pid)..." -ForegroundColor Yellow
                taskkill /F /PID $pid 2>$null
            }
        }
    } else {
        Write-Host "No process found on port $Port" -ForegroundColor Gray
    }
}

# Arrêter tous les services
$ports = @(8761, 8080, 8081, 8082, 8084)
foreach ($port in $ports) {
    Kill-ProcessOnPort -Port $port
}

Write-Host ""
Write-Host "All services stopped!" -ForegroundColor Green
