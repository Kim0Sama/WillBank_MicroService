@echo off
echo ========================================
echo Mise a jour de la devise vers XOF (Franc CFA)
echo ========================================
echo.

mysql -u root -p < update-currency-to-xof.sql

echo.
echo ========================================
echo Mise a jour terminee!
echo ========================================
pause
