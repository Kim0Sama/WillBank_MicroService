@echo off
chcp 65001 >nul
echo ============================================
echo Configuration Authentification WillBank
echo ============================================
echo.
echo Ce script va:
echo   1. Ajouter les colonnes password et role
echo   2. Mettre à jour les données existantes
echo   3. Créer les utilisateurs de test
echo.
echo Utilisateurs qui seront créés:
echo   - jean.dupont@example.com (CLIENT)
echo   - marie.martin@example.com (CLIENT)
echo   - admin@willbank.com (ADMIN)
echo.
echo Mot de passe pour tous: password123
echo.
echo ============================================
echo.

set /p MYSQL_ROOT_PASSWORD="Entrez le mot de passe root MySQL: "

echo.
echo Exécution du script SQL...
echo.

"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p%MYSQL_ROOT_PASSWORD% < setup-auth-complete.sql

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================
    echo Configuration terminée avec succès!
    echo ============================================
    echo.
    echo Vous pouvez maintenant:
    echo   1. Démarrer les services: ..\start-services-clean.ps1
    echo   2. Vous connecter avec les credentials ci-dessus
    echo.
) else (
    echo.
    echo ============================================
    echo ERREUR lors de la configuration
    echo ============================================
    echo.
    echo Vérifiez que:
    echo   - MySQL est démarré
    echo   - Le mot de passe root est correct
    echo   - La base willbank_client_db existe
    echo.
)

pause
