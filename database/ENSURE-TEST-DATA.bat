@echo off
echo ========================================
echo Ensuring test data exists in all databases
echo ========================================
echo.

mysql -u root -p < database\ensure-test-data.sql

echo.
echo ========================================
echo Done! Check the output above
echo ========================================
pause
