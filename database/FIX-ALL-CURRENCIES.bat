@echo off
echo ========================================
echo Correction de TOUTES les devises vers XOF
echo ========================================
echo.
echo Ce script va changer TOUTES les devises
echo (USD, EUR, etc.) vers XOF (Franc CFA)
echo.
echo Appuyez sur une touche pour continuer...
pause > nul
echo.

mysql -u root -p < fix-all-currencies-to-xof.sql

echo.
echo ========================================
echo Mise a jour terminee!
echo ========================================
echo.
echo Verifiez les resultats ci-dessus.
echo Tous les comptes devraient maintenant etre en XOF.
echo.
pause
