@echo off
echo ========================================
echo Inserting test data for accounts and transactions
echo ========================================
echo.

mysql -u root -p < database\insert-test-data.sql

echo.
echo ========================================
echo Done! Test data inserted successfully
echo ========================================
echo.
echo Test accounts created for:
echo - marie.martin@example.com (2 accounts)
echo - pierre.bernard@example.com (2 accounts)
echo - sophie.dubois@example.com (1 account)
echo - luc.moreau@example.com (1 account)
echo - admin@willbank.com (1 account)
echo.
echo Sample transactions also created
echo.
pause
