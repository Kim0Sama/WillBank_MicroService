@echo off
echo ========================================
echo Fixing all user passwords
echo ========================================
echo.
echo This will copy admin's working password to all users
echo All users will have password: password123
echo.

mysql -u root -p < database\fix-all-passwords-simple.sql

echo.
echo ========================================
echo Done! Try logging in now with any user
echo Email: marie.martin@example.com
echo Password: password123
echo ========================================
pause
