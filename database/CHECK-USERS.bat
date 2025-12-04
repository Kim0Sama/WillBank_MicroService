@echo off
chcp 65001 >nul
echo ============================================
echo Vérification des Utilisateurs
echo ============================================
echo.

set /p MYSQL_ROOT_PASSWORD="Entrez le mot de passe root MySQL: "

echo.
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p%MYSQL_ROOT_PASSWORD% < check-users.sql

echo.
echo ============================================
echo.
echo Utilisez un des emails ci-dessus pour vous connecter
echo avec le mot de passe: password123
echo.
pause
