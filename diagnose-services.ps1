# Script de diagnostic des services WillBank

Write-Host "=== Diagnostic des Services WillBank ===" -ForegroundColor Cyan
Write-Host ""

# Fonction pour tester un endpoint
function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Url
    )
    
    Write-Host "Testing $Name..." -NoNewline
    try {
        $response = Invoke-WebRequest -Uri $Url -Method Get -TimeoutSec 5 -ErrorAction Stop
        Write-Host " OK (Status: $($response.StatusCode))" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host " FAILED" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
        return $false
    }
}

# Test Eureka Server
Write-Host "`n1. Eureka Server (Service Registry)" -ForegroundColor Yellow
Test-Endpoint "Eureka Dashboard" "http://localhost:8761"

# Test Gateway
Write-Host "`n2. API Gateway" -ForegroundColor Yellow
Test-Endpoint "Gateway Health" "http://localhost:8080/actuator/health"

# Test Client Service
Write-Host "`n3. Client Service" -ForegroundColor Yellow
Test-Endpoint "Client Service Direct" "http://localhost:8082/actuator/health"

# Test Account Service
Write-Host "`n4. Account Service" -ForegroundColor Yellow
Test-Endpoint "Account Service Direct" "http://localhost:8081/actuator/health"

# Test Transaction Service
Write-Host "`n5. Transaction Service" -ForegroundColor Yellow
Test-Endpoint "Transaction Service Direct" "http://localhost:8083/actuator/health"

# Test via Gateway
Write-Host "`n6. API Endpoints via Gateway" -ForegroundColor Yellow

# Test auth endpoint (should work without token)
Write-Host "Testing Auth endpoint..." -NoNewline
try {
    $body = @{
        email = "test@test.com"
        password = "test"
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/login" `
        -Method Post `
        -ContentType "application/json" `
        -Body $body `
        -TimeoutSec 5 `
        -ErrorAction Stop
    
    Write-Host " OK (Status: $($response.StatusCode))" -ForegroundColor Green
}
catch {
    Write-Host " FAILED" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Check Eureka registered services
Write-Host "`n7. Services enregistrés dans Eureka" -ForegroundColor Yellow
try {
    $eureka = Invoke-RestMethod -Uri "http://localhost:8761/eureka/apps" -Headers @{Accept="application/json"}
    
    if ($eureka.applications.application) {
        $services = $eureka.applications.application
        if ($services -is [Array]) {
            foreach ($service in $services) {
                $name = $service.name
                $instances = $service.instance.Count
                if ($instances -eq $null) { $instances = 1 }
                Write-Host "  - $name ($instances instance(s))" -ForegroundColor Green
            }
        } else {
            $name = $services.name
            Write-Host "  - $name (1 instance)" -ForegroundColor Green
        }
    } else {
        Write-Host "  Aucun service enregistré!" -ForegroundColor Red
    }
}
catch {
    Write-Host "  Impossible de récupérer les services d'Eureka" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "`n=== Fin du diagnostic ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Si des services sont en échec, vérifiez:" -ForegroundColor Yellow
Write-Host "  1. Que tous les services sont démarrés"
Write-Host "  2. Les logs des services pour voir les erreurs"
Write-Host "  3. Que MySQL est démarré et accessible"
Write-Host "  4. Que les bases de données existent"
Write-Host ""
