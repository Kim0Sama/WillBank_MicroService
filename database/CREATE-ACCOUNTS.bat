@echo off
echo Creating accounts for test users...
echo.

"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -pRoot2024! < create-accounts-for-test-users.sql

if %ERRORLEVEL% EQU 0 (
    echo.
    echo SUCCESS: Accounts created successfully!
    echo.
    echo You can now login with:
    echo   - jean.dupont@example.com / password123
    echo   - admin@willbank.com / password123
    echo.
) else (
    echo.
    echo ERROR: Failed to create accounts
    echo.
)

pause
