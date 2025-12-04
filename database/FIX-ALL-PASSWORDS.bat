@echo off
echo ========================================
echo Fixing ALL client passwords
echo ========================================
echo.
echo This will set password123 for ALL users
echo.

mysql -u root -p -e "source database/fix-all-passwords.sql"

echo.
echo ========================================
echo Done! All users now have password: password123
echo ========================================
echo.
echo You can now login with:
echo - admin@willbank.com / password123
echo - marie.martin@example.com / password123
echo - pierre.bernard@example.com / password123
echo - sophie.dubois@example.com / password123
echo - luc.moreau@example.com / password123
echo.
pause
