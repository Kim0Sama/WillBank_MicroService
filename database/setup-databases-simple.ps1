# Script simplifié pour créer les bases de données MySQL
param(
    [Parameter(Mandatory=$true)]
    [string]$RootPassword
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Creation des bases de donnees MySQL" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Chemins possibles de MySQL
$mysqlPaths = @(
    "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe",
    "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe",
    "C:\Program Files\MySQL\MySQL Server 9.0\bin\mysql.exe",
    "C:\xampp\mysql\bin\mysql.exe"
)

$mysqlExe = $null
foreach ($path in $mysqlPaths) {
    if (Test-Path $path) {
        $mysqlExe = $path
        Write-Host "MySQL trouve: $path" -ForegroundColor Green
        break
    }
}

if (-not $mysqlExe) {
    try {
        $mysqlExe = (Get-Command mysql).Source
        Write-Host "MySQL trouve dans PATH" -ForegroundColor Green
    } catch {
        Write-Host "ERREUR: MySQL introuvable!" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "Execution du script SQL..." -ForegroundColor Yellow

$scriptPath = Join-Path $PSScriptRoot "create-databases.sql"
$env:MYSQL_PWD = $RootPassword

try {
    & $mysqlExe -u root -e "source $scriptPath"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "SUCCESS: Bases de donnees creees!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "ERREUR: Echec de creation" -ForegroundColor Red
    }
} finally {
    Remove-Item Env:\MYSQL_PWD -ErrorAction SilentlyContinue
}
