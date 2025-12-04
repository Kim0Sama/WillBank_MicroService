@echo off
echo ========================================
echo Copying admin password to all users
echo ========================================
echo.
echo This will copy the working admin password
echo to all CLIENT users (password123)
echo.

mysql -u root -p < database\copy-admin-password.sql

echo.
echo ========================================
echo Done! All users now have password: password123
echo ========================================
pause
