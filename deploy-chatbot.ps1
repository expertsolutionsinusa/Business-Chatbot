Write-Host "Starting Local AI Chatbot Deployment (Windows)"

# ----------------------------
# Resolve current script directory
# ----------------------------
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $SCRIPT_DIR

Write-Host "Project directory: $SCRIPT_DIR"

# ----------------------------
# Helper: Check if command exists
# ----------------------------
function Command-Exists {
    param ($cmd)
    return Get-Command $cmd -ErrorAction SilentlyContinue
}

# ----------------------------
# Install Ollama (if missing)
# ----------------------------
if (-not (Command-Exists "ollama")) {
    Write-Host "Installing Ollama..."
    Invoke-WebRequest `
        -Uri "https://ollama.com/download/OllamaSetup.exe" `
        -OutFile "$env:TEMP\OllamaSetup.exe"

    Start-Process "$env:TEMP\OllamaSetup.exe" -Wait
} else {
    Write-Host "Ollama already installed"
}

# ----------------------------
# Ensure Ollama is running
# ----------------------------
Write-Host "Ensuring Ollama service is running..."
Start-Process "ollama" -ArgumentList "serve" -WindowStyle Hidden -ErrorAction SilentlyContinue
Start-Sleep -Seconds 5

# ----------------------------
# Pull Mistral model (if missing)
# ----------------------------
Write-Host "Checking for Mistral model..."
$models = ollama list | Select-String "mistral"

if (-not $models) {
    Write-Host "Pulling Mistral model..."
    ollama pull mistral
} else {
    Write-Host "Mistral model already available"
}

# ----------------------------
# Install Bun (if missing)
# ----------------------------
if (-not (Command-Exists "bun")) {
    Write-Host "Installing Bun..."
    powershell -Command "irm https://bun.sh/install.ps1 | iex"

    $bunPath = Join-Path $env:USERPROFILE ".bun\bin"
    if (-not ($env:PATH -like "*$bunPath*")) {
        $env:PATH = $env:PATH + ";" + $bunPath
    }
} else {
    Write-Host "Bun already installed"
}

# ----------------------------
# Verify server.ts exists
# ----------------------------
if (-not (Test-Path "$SCRIPT_DIR\server.ts")) {
    Write-Host "ERROR: server.ts not found in project directory"
    exit 1
}

# ----------------------------
# Start chatbot server
# ----------------------------
Write-Host "Starting chatbot server..."
Start-Process `
    -FilePath "bun" `
    -ArgumentList "run server.ts" `
    -WorkingDirectory $SCRIPT_DIR `
    -WindowStyle Minimized

Write-Host ""
Write-Host "Deployment complete"
Write-Host "Chatbot running at: http://localhost:3000"
