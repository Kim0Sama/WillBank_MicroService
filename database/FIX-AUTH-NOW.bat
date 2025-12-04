@echo off
chcp 65001 >nul
echo ============================================
echo Mise à Jour Authentification (Fix Rapide)
echo ============================================
echo.
echo Ce script va:
echo   1. Ajouter password/role si manquants
echo   2. Mettre à jour TOUS les clients existants
echo   3. Définir password123 pour tous
echo.
echo ============================================
echo.

set /p MYSQL_ROOT_PASSWORD="Entrez le mot de passe root MySQL: "

echo.
echo Exécution du script de mise à jour...
echo.

"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p%MYSQL_ROOT_PASSWORD% < update-existing-clients-auth.sql

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================
    echo Mise à jour terminée avec succès!
    echo ============================================
    echo.
    echo Tous les utilisateurs ont maintenant:
    echo   - Un mot de passe: password123
    echo   - Un rôle: CLIENT ou ADMIN
    echo.
    echo Vous pouvez vous connecter avec N'IMPORTE QUEL
    echo email existant dans la base de données!
    echo.
) else (
    echo.
    echo ============================================
    echo ERREUR lors de la mise à jour
    echo ============================================
    echo.
)

pause
