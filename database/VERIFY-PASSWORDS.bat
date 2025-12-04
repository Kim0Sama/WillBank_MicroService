@echo off
echo Verifying passwords in database...
echo.

mysql -u root -p < database\verify-passwords.sql

echo.
pause
