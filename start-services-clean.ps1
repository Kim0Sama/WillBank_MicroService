# Script de démarrage propre de tous les services WillBank
# Tue les processus existants et démarre dans le bon ordre

Write-Host "=== WillBank Services Startup Script ===" -ForegroundColor Cyan
Write-Host ""

# Fonction pour tuer les processus sur un port
function Kill-ProcessOnPort {
    param([int]$Port)
    
    $connections = netstat -ano | Select-String ":$Port\s" | Select-String "LISTENING"
    if ($connections) {
        foreach ($conn in $connections) {
            $pid = ($conn -split '\s+')[-1]
            if ($pid -and $pid -match '^\d+$') {
                Write-Host "Killing process $pid on port $Port..." -ForegroundColor Yellow
                taskkill /F /PID $pid 2>$null
            }
        }
    }
}

# Nettoyer tous les ports utilisés
Write-Host "Step 1: Cleaning up existing processes..." -ForegroundColor Green
$ports = @(8761, 8080, 8081, 8082, 8084)
foreach ($port in $ports) {
    Kill-ProcessOnPort -Port $port
}

Start-Sleep -Seconds 2
Write-Host "Cleanup complete!" -ForegroundColor Green
Write-Host ""

# Démarrer Eureka Server
Write-Host "Step 2: Starting Eureka Server (port 8761)..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\Eureka-Service\Eureka-Service'; mvn spring-boot:run" -WindowStyle Normal
Write-Host "Waiting for Eureka to start (30 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Démarrer Client Service
Write-Host "Step 3: Starting Client Service (port 8084)..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\Client_service'; mvn spring-boot:run" -WindowStyle Normal
Start-Sleep -Seconds 15

# Démarrer Account Service
Write-Host "Step 4: Starting Account Service (port 8081)..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\account_service'; mvn spring-boot:run" -WindowStyle Normal
Start-Sleep -Seconds 15

# Démarrer Transaction Service
Write-Host "Step 5: Starting Transaction Service (port 8082)..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\transaction_service'; mvn spring-boot:run" -WindowStyle Normal
Start-Sleep -Seconds 15

# Démarrer Gateway Service
Write-Host "Step 6: Starting Gateway Service (port 8080)..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\gateway_service'; mvn spring-boot:run" -WindowStyle Normal
Start-Sleep -Seconds 15

Write-Host ""
Write-Host "=== All Services Started! ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Services running on:" -ForegroundColor White
Write-Host "  - Eureka Server:       http://localhost:8761" -ForegroundColor Gray
Write-Host "  - Gateway Service:     http://localhost:8080" -ForegroundColor Gray
Write-Host "  - Account Service:     http://localhost:8081" -ForegroundColor Gray
Write-Host "  - Transaction Service: http://localhost:8082" -ForegroundColor Gray
Write-Host "  - Client Service:      http://localhost:8084" -ForegroundColor Gray
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
