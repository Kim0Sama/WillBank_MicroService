# Script PowerShell pour démarrer tous les microservices WillBank
# Usage: .\start-all-services.ps1 [-Profile mysql]

param(
    [string]$Profile = "default"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  WillBank Microservices Launcher" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Fonction pour démarrer un service
function Start-Service {
    param(
        [string]$ServiceName,
        [string]$ServicePath,
        [int]$Port,
        [string]$Profile = ""
    )
    
    Write-Host "Démarrage de $ServiceName sur le port $Port..." -ForegroundColor Yellow
    
    $profileArg = ""
    if ($Profile -ne "" -and $Profile -ne "default") {
        $profileArg = "-Dspring-boot.run.profiles=$Profile"
    }
    
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$ServicePath'; Write-Host 'Démarrage de $ServiceName...' -ForegroundColor Green; .\mvnw.cmd spring-boot:run $profileArg"
    
    Start-Sleep -Seconds 2
}

# Vérifier Java
Write-Host "Vérification de Java..." -ForegroundColor Cyan
try {
    $javaVersion = java -version 2>&1 | Select-String "version"
    Write-Host "✓ Java détecté: $javaVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Java n'est pas installé ou n'est pas dans le PATH" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Vérifier Maven
Write-Host "Vérification de Maven..." -ForegroundColor Cyan
$currentPath = Get-Location
$mvnwPath = Join-Path $currentPath "Client_service\mvnw.cmd"
if (Test-Path $mvnwPath) {
    Write-Host "✓ Maven Wrapper détecté" -ForegroundColor Green
} else {
    Write-Host "✗ Maven Wrapper non trouvé" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Vérifier MySQL si profil mysql
if ($Profile -eq "mysql") {
    Write-Host "Vérification de MySQL..." -ForegroundColor Cyan
    try {
        $mysqlTest = mysql -u willbank_user -pWillBank2024! -e "USE willbank_db; SELECT 1;" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ MySQL connecté et base de données willbank_db accessible" -ForegroundColor Green
        } else {
            Write-Host "✗ Impossible de se connecter à MySQL" -ForegroundColor Red
            Write-Host "Assurez-vous que MySQL est démarré et que la base de données est créée" -ForegroundColor Yellow
            Write-Host "Voir: database/README.md" -ForegroundColor Yellow
            exit 1
        }
    } catch {
        Write-Host "⚠ MySQL non détecté dans le PATH" -ForegroundColor Yellow
        Write-Host "Assurez-vous que MySQL est installé et démarré" -ForegroundColor Yellow
    }
    Write-Host ""
}

Write-Host "Démarrage des services avec le profil: $Profile" -ForegroundColor Cyan
Write-Host ""

# Démarrer Eureka Server en premier
$eurekaPath = Join-Path $currentPath "Eureka-Service\Eureka-Service"
Start-Service -ServiceName "Eureka Server" -ServicePath $eurekaPath -Port 8761

Write-Host "Attente du démarrage d'Eureka Server (30 secondes)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Démarrer les autres services
$clientPath = Join-Path $currentPath "Client_service"
Start-Service -ServiceName "Client Service" -ServicePath $clientPath -Port 8081 -Profile $Profile

Start-Sleep -Seconds 5

$accountPath = Join-Path $currentPath "account_service"
Start-Service -ServiceName "Account Service" -ServicePath $accountPath -Port 8082 -Profile $Profile

Start-Sleep -Seconds 5

$transactionPath = Join-Path $currentPath "transaction_service"
Start-Service -ServiceName "Transaction Service" -ServicePath $transactionPath -Port 8083 -Profile $Profile

Start-Sleep -Seconds 5

$notificationPath = Join-Path $currentPath "Notification-service\Notification-service"
Start-Service -ServiceName "Notification Service" -ServicePath $notificationPath -Port 8084

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Tous les services sont en cours de démarrage!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "URLs des services:" -ForegroundColor Cyan
Write-Host "  - Eureka Dashboard:    http://localhost:8761" -ForegroundColor White
Write-Host "  - Client Service:      http://localhost:8081/swagger-ui.html" -ForegroundColor White
Write-Host "  - Account Service:     http://localhost:8082/swagger-ui.html" -ForegroundColor White
Write-Host "  - Transaction Service: http://localhost:8083/swagger-ui.html" -ForegroundColor White
Write-Host "  - Notification Service: http://localhost:8084/actuator/health" -ForegroundColor White
Write-Host ""
Write-Host "Attendez environ 1-2 minutes pour que tous les services soient complètement démarrés." -ForegroundColor Yellow
Write-Host ""
Write-Host "Pour arrêter les services, fermez toutes les fenêtres PowerShell ouvertes." -ForegroundColor Yellow
Write-Host ""
Write-Host "Appuyez sur une touche pour ouvrir Eureka Dashboard..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Start-Process "http://localhost:8761"
