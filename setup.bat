@echo off
REM ==================== MVC DOCKER DEMO - SETUP SCRIPT (Batch) ====================
REM One-command setup for Windows CMD
REM Run: setup.bat

setlocal enabledelayedexpansion

cls
echo ========================================
echo MVC Docker Demo - Automated Setup
echo ========================================
echo.

REM Check for Docker
docker --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not installed or not in PATH
    echo Please install Docker Desktop from https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('docker --version') do set DOCKER_VERSION=%%i
echo [OK] Docker found: %DOCKER_VERSION%

REM Check for Docker Compose
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker Compose is not installed or not in PATH
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('docker-compose --version') do set COMPOSE_VERSION=%%i
echo [OK] Docker Compose found: %COMPOSE_VERSION%

echo.

REM Create .env if it doesn't exist
if not exist ".env" (
    echo Creating .env file from .env.example...
    copy ".env.example" ".env" >nul
    echo [OK] .env file created
    echo.
    echo [WARNING] Edit .env with your production credentials before deploying
    echo.
) else (
    echo [OK] .env file already exists
    echo.
)

REM Create backups directory if it doesn't exist
if not exist "backups" (
    echo Creating backups directory...
    mkdir backups >nul
    echo [OK] Backups directory created
    echo.
)

REM Stop any running containers
echo Stopping any running containers...
docker-compose -f docker-compose.yml down --remove-orphans 2>nul
echo [OK] Cleaned up
echo.

REM Build the Docker image
echo Building Docker images...
echo (This may take a few minutes on first run)
echo Building: MySQL, Spring Boot API, React Frontend
echo.

docker-compose -f docker-compose.yml build

if errorlevel 1 (
    echo [ERROR] Build failed
    pause
    exit /b 1
)

echo.
echo [OK] Build complete
echo.

REM Start the development environment
echo Starting development environment...
docker-compose -f docker-compose.yml up -d

if errorlevel 1 (
    echo [ERROR] Failed to start containers
    pause
    exit /b 1
)

echo.

REM Wait for services to be healthy
echo Waiting for services to be ready...
timeout /t 5 /nobreak

echo Checking service health...
docker-compose -f docker-compose.yml ps

echo.
echo Waiting for frontend to be fully ready...
timeout /t 3 /nobreak

echo.
echo ========================================
echo [SUCCESS] Setup Complete!
echo ========================================
echo.
echo Frontend URL:   http://localhost:3000 (opening in browser...)
echo API URL:        http://localhost:8080
echo Database:       localhost:3306 (user:userpassword)
echo.
echo Next Steps:
echo   View all logs:     docker-compose logs -f
echo   View app logs:     docker-compose logs -f user-service
echo   View frontend logs: docker-compose logs -f frontend
echo   Stop services:     docker-compose down
echo.
echo For more info, see README.md
echo ========================================
echo.

REM Try to open the browser
start http://localhost:3000

pause

