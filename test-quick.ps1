$login = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method Post -ContentType "application/json" -Body '{"email":"jean.dupont@example.com","password":"password123"}'
Write-Host "Login OK - User ID: $($login.userId)"

$headers = @{Authorization="Bearer $($login.token)"}
$accounts = Invoke-RestMethod -Uri "http://localhost:8080/api/accounts/customer/$($login.userId)" -Headers $headers
Write-Host "Accounts OK - Count: $($accounts.Count)"
