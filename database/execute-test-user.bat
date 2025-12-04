@echo off
echo ========================================
echo Creation des utilisateurs de test
echo ========================================
echo.
echo Utilisateurs qui seront crees:
echo 1. jean.dupont@example.com (CLIENT) - password: password123
echo 2. admin@willbank.com (ADMIN) - password: password123
echo.
echo ========================================
echo.

set /p MYSQL_ROOT_PASSWORD="Entrez le mot de passe root MySQL: "

echo.
echo Execution du script SQL...
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p%MYSQL_ROOT_PASSWORD% < create-test-user.sql

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Utilisateurs crees avec succes!
    echo ========================================
    echo.
    echo Vous pouvez maintenant vous connecter avec:
    echo   Email: jean.dupont@example.com
    echo   Password: password123
    echo.
    echo Ou en tant qu'admin:
    echo   Email: admin@willbank.com
    echo   Password: password123
    echo.
) else (
    echo.
    echo ERREUR: Echec de la creation des utilisateurs
    echo Verifiez que MySQL est demarre et que le mot de passe est correct
    echo.
)

pause
