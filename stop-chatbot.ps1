Write-Host "Stopping chatbot running on port 3000..."

# Find process using port 3000
$connection = Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue

if (-not $connection) {
    Write-Host "No process is currently using port 3000."
}
else {
    $pid = $connection.OwningProcess
    $process = Get-Process -Id $pid -ErrorAction SilentlyContinue

    if ($process) {
        Write-Host "Stopping process: $($process.ProcessName) (PID: $pid)"
        Stop-Process -Id $pid -Force
        Write-Host "Chatbot stopped successfully."
    }
    else {
        Write-Host "Port 3000 was in use, but process could not be resolved."
    }
}

Write-Host ""
Write-Host "PowerShell window remains open."
