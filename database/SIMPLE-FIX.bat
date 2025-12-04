@echo off
chcp 65001 >nul
echo ============================================
echo Fix Authentification Simple
echo ============================================
echo.
echo Ce script va mettre à jour tous les clients
echo avec le mot de passe: password123
echo.
echo ============================================
echo.

set /p MYSQL_ROOT_PASSWORD="Entrez le mot de passe root MySQL: "

echo.
echo Mise à jour en cours...
echo.

"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p%MYSQL_ROOT_PASSWORD% < simple-auth-fix.sql

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================
    echo ✓ Mise à jour réussie!
    echo ============================================
    echo.
    echo Connectez-vous avec N'IMPORTE QUEL email
    echo de la base de données et le mot de passe:
    echo   password123
    echo.
) else (
    echo.
    echo ✗ Erreur lors de la mise à jour
    echo.
)

pause
