@echo off
echo ========================================
echo Checking all data in databases
echo ========================================
echo.

mysql -u root -p < database\check-all-data.sql

echo.
pause
