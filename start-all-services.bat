@echo off
REM Script batch pour démarrer tous les microservices WillBank
REM Version simple - Lance tous les services dans des fenêtres séparées

echo ========================================
echo  WillBank Microservices Launcher
echo ========================================
echo.

REM Vérifier Java
java -version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERREUR] Java n'est pas installe ou n'est pas dans le PATH
    pause
    exit /b 1
)

echo [OK] Java detecte
echo.

echo Demarrage des services...
echo.

REM Démarrer Eureka Server
echo [1/5] Demarrage Eureka Server (Port 8761)...
start "Eureka Server" cmd /k "cd Eureka-Service\Eureka-Service && mvnw.cmd spring-boot:run"
timeout /t 30 /nobreak

REM Démarrer Client Service
echo [2/5] Demarrage Client Service (Port 8084)...
start "Client Service" cmd /k "cd Client_service && mvnw.cmd spring-boot:run"
timeout /t 30 /nobreak

REM Démarrer Account Service
echo [3/5] Demarrage Account Service (Port 8081)...
start "Account Service" cmd /k "cd account_service && mvnw.cmd spring-boot:run"
timeout /t 30 /nobreak

REM Démarrer Transaction Service
echo [4/5] Demarrage Transaction Service (Port 8082)...
start "Transaction Service" cmd /k "cd transaction_service && mvnw.cmd spring-boot:run"
timeout /t 30 /nobreak

REM Démarrer Notification Service
echo [5/5] Demarrage Notification Service (Port 8083)...
start "Notification Service" cmd /k "cd Notification-service && mvnw.cmd spring-boot:run"

echo.
echo ========================================
echo  Tous les services sont en cours de demarrage
echo ========================================
echo.
echo URLs utiles:
echo   - Eureka Dashboard:    http://localhost:8761
echo   - Client Service:      http://localhost:8084/swagger-ui.html
echo   - Account Service:     http://localhost:8081/swagger-ui.html
echo   - Transaction Service: http://localhost:8082/swagger-ui.html
echo.
echo Attendez 2-3 minutes pour que tous les services soient prets
echo.
pause
