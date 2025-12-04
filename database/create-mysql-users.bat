@echo off
REM Script batch pour créer les utilisateurs MySQL pour WillBank

echo ========================================
echo Creation des utilisateurs MySQL WillBank
echo ========================================
echo.

set /p MYSQL_ROOT_PASSWORD="Entrez le mot de passe root MySQL: "

echo.
echo Execution du script SQL...
echo.

mysql -u root -p%MYSQL_ROOT_PASSWORD% < create-databases.sql

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [OK] Bases de donnees et utilisateurs crees avec succes!
    echo.
    echo Utilisateurs crees:
    echo   - client_service_user ^(mot de passe: ClientService2024!^)
    echo   - account_service_user ^(mot de passe: AccountService2024!^)
    echo   - transaction_service_user ^(mot de passe: TransactionService2024!^)
    echo.
    echo Bases de donnees creees:
    echo   - willbank_client_db
    echo   - willbank_account_db
    echo   - willbank_transaction_db
) else (
    echo.
    echo [ERREUR] Echec de la creation
    echo Verifiez que MySQL est demarre et que le mot de passe root est correct
)

echo.
pause
