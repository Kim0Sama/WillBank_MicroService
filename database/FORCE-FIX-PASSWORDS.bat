@echo off
cls
echo ========================================
echo FORCE FIX ALL PASSWORDS
echo ========================================
echo.
echo This will set ALL users to password: password123
echo Using a known working BCrypt hash
echo.
pause

mysql -u root -p < database\force-fix-passwords.sql

echo.
echo ========================================
echo DONE! All users now have: password123
echo ========================================
echo.
echo Try logging in with:
echo - marie.martin@example.com / password123
echo - admin@willbank.com / password123
echo.
pause
