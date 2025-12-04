@echo off
echo Resetting test user password...
echo.

mysql -u root -p -e "source database/reset-test-password.sql"

echo.
echo Done! Try logging in with:
echo Email: pierre.bernard@example.com
echo Password: password123
pause
