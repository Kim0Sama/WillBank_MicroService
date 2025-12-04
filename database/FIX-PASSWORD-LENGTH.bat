@echo off
chcp 65001 >nul
echo ============================================
echo Correction Longueur Colonne Password
echo ============================================
echo.
echo Le hash BCrypt fait 60 caractères.
echo Ce script va s'assurer que la colonne
echo password est assez longue (VARCHAR 255).
echo.
echo ============================================
echo.

set /p MYSQL_ROOT_PASSWORD="Entrez le mot de passe root MySQL: "

echo.
echo Correction en cours...
echo.

"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p%MYSQL_ROOT_PASSWORD% < fix-password-column-length.sql

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================
    echo ✓ Colonne password corrigée!
    echo ============================================
    echo.
    echo Le hash BCrypt complet est maintenant stocké.
    echo Mot de passe pour tous: password123
    echo.
    echo IMPORTANT: Redémarrez le Client Service!
    echo.
) else (
    echo.
    echo ✗ Erreur lors de la correction
    echo.
)

pause
