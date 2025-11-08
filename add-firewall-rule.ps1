# Run this script as Administrator to allow Ganache through Windows Firewall

Write-Host "Adding Windows Firewall rule for Ganache..." -ForegroundColor Yellow

try {
    New-NetFirewallRule -DisplayName "Ganache Blockchain" `
                        -Direction Inbound `
                        -LocalPort 8545 `
                        -Protocol TCP `
                        -Action Allow `
                        -Profile Private,Domain,Public `
                        -ErrorAction Stop
    
    Write-Host "✅ Firewall rule added successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Now press 'R' in your Flutter terminal to hot restart the app." -ForegroundColor Cyan
} catch {
    if ($_.Exception.Message -like "*already exists*") {
        Write-Host "✅ Firewall rule already exists!" -ForegroundColor Green
    } else {
        Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "Make sure you're running PowerShell as Administrator!" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
