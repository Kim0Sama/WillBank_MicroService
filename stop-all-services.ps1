# Script PowerShell pour arrêter tous les microservices WillBank

$ErrorActionPreference = "Continue"

# Couleurs
function Write-Success { param($msg) Write-Host $msg -ForegroundColor Green }
function Write-Info { param($msg) Write-Host $msg -ForegroundColor Cyan }
function Write-Warning { param($msg) Write-Host $msg -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host $msg -ForegroundColor Red }

# Banner
Clear-Host
Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Red
Write-Host "║                                                               ║" -ForegroundColor Red
Write-Host "║           🛑 WillBank Services Shutdown Script 🛑            ║" -ForegroundColor Red
Write-Host "║                                                               ║" -ForegroundColor Red
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Red
Write-Host ""

# Trouver tous les processus Java
Write-Info "🔍 Recherche des processus Java en cours..."
$javaProcesses = Get-Process | Where-Object {$_.ProcessName -like "*java*"}

if ($javaProcesses.Count -eq 0) {
    Write-Warning "⚠ Aucun processus Java trouvé"
    Write-Host ""
    exit 0
}

Write-Host ""
Write-Info "📋 Processus Java trouvés: $($javaProcesses.Count)"
Write-Host ""

# Afficher les processus
foreach ($process in $javaProcesses) {
    $memory = [math]::Round($process.WorkingSet64 / 1MB, 2)
    Write-Host "   • PID: $($process.Id) | Mémoire: $memory MB | Démarré: $($process.StartTime)" -ForegroundColor White
}

Write-Host ""
$confirm = Read-Host "Voulez-vous arrêter tous ces processus? (o/N)"

if ($confirm -ne "o" -and $confirm -ne "O") {
    Write-Warning "Annulé par l'utilisateur"
    exit 0
}

Write-Host ""
Write-Info "🛑 Arrêt des services en cours..."
Write-Host ""

$stoppedCount = 0
$failedCount = 0

foreach ($process in $javaProcesses) {
    try {
        Write-Host "   Arrêt du processus PID $($process.Id)..." -NoNewline
        Stop-Process -Id $process.Id -Force -ErrorAction Stop
        Write-Success " ✓"
        $stoppedCount++
    } catch {
        Write-Error " ✗"
        $failedCount++
    }
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "                         📊 RÉSUMÉ                            " -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

Write-Success "✓ Processus arrêtés: $stoppedCount"
if ($failedCount -gt 0) {
    Write-Error "✗ Échecs: $failedCount"
}

Write-Host ""

# Vérifier qu'il ne reste plus de processus
Start-Sleep -Seconds 2
$remainingProcesses = Get-Process | Where-Object {$_.ProcessName -like "*java*"}

if ($remainingProcesses.Count -eq 0) {
    Write-Success "🎉 Tous les services ont été arrêtés avec succès!"
} else {
    Write-Warning "⚠ Il reste $($remainingProcesses.Count) processus Java en cours"
    Write-Info "Vous pouvez les arrêter manuellement avec le Gestionnaire des tâches"
}

Write-Host ""
