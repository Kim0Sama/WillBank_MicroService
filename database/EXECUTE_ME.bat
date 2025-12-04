@echo off
echo ========================================
echo Creation des bases de donnees WillBank
echo ========================================
echo.
echo Ce script va creer:
echo   - 3 bases de donnees
echo   - 3 utilisateurs MySQL
echo   - Tables et donnees de test
echo.
set /p PASSWORD="Entrez le mot de passe root MySQL: "
echo.
echo Execution en cours...
echo.

"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p%PASSWORD% < create-databases.sql

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo          SUCCESS!
    echo ========================================
    echo.
    echo Bases de donnees creees:
    echo   [OK] willbank_client_db
    echo   [OK] willbank_account_db
    echo   [OK] willbank_transaction_db
    echo.
    echo Utilisateurs crees:
    echo   [OK] client_service_user
    echo   [OK] account_service_user
    echo   [OK] transaction_service_user
    echo.
    echo Vous pouvez maintenant demarrer les services!
) else (
    echo.
    echo ========================================
    echo          ERREUR!
    echo ========================================
    echo.
    echo Verifiez:
    echo   - MySQL est demarre
    echo   - Le mot de passe root est correct
    echo   - Vous avez les droits administrateur
)

echo.
pause
