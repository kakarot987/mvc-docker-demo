# ==================== MVC DOCKER DEMO - SETUP SCRIPT (PowerShell) ====================
# One-command setup for Windows
# Run: .\setup.ps1
#
# Note: You may need to enable script execution on Windows:
#   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "MVC Docker Demo - Automated Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check for Docker
try {
    $dockerVersion = docker --version
    Write-Host "Docker found: $dockerVersion" -ForegroundColor Green
}
catch {
    Write-Host "Docker is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Docker Desktop from https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Check for Docker Compose
try {
    $composeVersion = docker-compose --version
    Write-Host "Docker Compose found: $composeVersion" -ForegroundColor Green
}
catch {
    Write-Host "Docker Compose is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Create .env if it doesn't exist
if (-not (Test-Path ".env")) {
    Write-Host "Creating .env file from .env.example..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host ".env file created" -ForegroundColor Green
    Write-Host ""
    Write-Host "REMINDER: Edit .env with your production credentials before deploying" -ForegroundColor Yellow
    Write-Host ""
}
else {
    Write-Host " .env file already exists" -ForegroundColor Green
    Write-Host ""
}

# Create backups directory if it doesn't exist
if (-not (Test-Path "backups")) {
    Write-Host " Creating backups directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "backups" | Out-Null
    Write-Host " Backups directory created" -ForegroundColor Green
    Write-Host ""
}

# Stop any running containers
Write-Host "Stopping any running containers..." -ForegroundColor Yellow
docker-compose -f docker-compose.yml down --remove-orphans 2>$null
Write-Host "Cleaned up" -ForegroundColor Green
Write-Host ""

# Build the Docker image
Write-Host "Building Docker images..." -ForegroundColor Cyan
Write-Host "(This may take a few minutes on first run)" -ForegroundColor Gray
Write-Host ""

docker-compose -f docker-compose.yml build
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Build complete" -ForegroundColor Green
Write-Host ""

# Start the development environment
Write-Host "Starting development environment..." -ForegroundColor Cyan
Write-Host "(MySQL, Spring Boot API, React Frontend)" -ForegroundColor Gray
docker-compose -f docker-compose.yml up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to start containers" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Wait for services to be healthy
Write-Host "Waiting for services to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

Write-Host "Checking service health..." -ForegroundColor Yellow
docker-compose -f docker-compose.yml ps

# Wait a bit more for frontend to be ready
Write-Host ""
Write-Host "Waiting for frontend to be fully ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Frontend URL:    http://localhost:3000   (Opening in browser...)" -ForegroundColor Cyan
Write-Host "API URL:         http://localhost:8080" -ForegroundColor Cyan
Write-Host "Database:        localhost:3306 (user:userpassword)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "   Check logs:      docker-compose logs -f" -ForegroundColor Gray
Write-Host "   Stop services:   docker-compose down" -ForegroundColor Gray
Write-Host "   View help:       make help" -ForegroundColor Gray
Write-Host ""
Write-Host "For more info, see README.md" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Open browser
try {
    Start-Process "http://localhost:3000"
    Write-Host "Browser opened automatically" -ForegroundColor Green
}
catch {
    Write-Host "Could not open browser automatically. Visit http://localhost:3000 manually" -ForegroundColor Yellow
}

