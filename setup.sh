#!/bin/bash

# ==================== MVC DOCKER DEMO - SETUP SCRIPT ====================
# One-command setup for Linux/Mac
# Run: ./setup.sh
# Or: chmod +x setup.sh && ./setup.sh

set -e  # Exit on error

echo "========================================"
echo "MVC Docker Demo - Automated Setup"
echo "========================================"
echo ""

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check for Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✓ Docker and Docker Compose found"
echo ""

# Create .env if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from .env.example..."
    cp .env.example .env
    echo "✓ .env file created"
    echo ""
    echo "⚠️  REMINDER: Edit .env with your production credentials before deploying to production"
    echo ""
else
    echo "✓ .env file already exists"
    echo ""
fi

# Create data directory for backups if it doesn't exist
if [ ! -d backups ]; then
    echo "📂 Creating backups directory..."
    mkdir -p backups
    echo "✓ Backups directory created"
    echo ""
fi

# Stop any running containers
echo "🛑 Stopping any running containers..."
docker-compose -f docker-compose.yml down --remove-orphans 2>/dev/null || true
echo "✓ Cleaned up"
echo ""

# Build the Docker image
echo "🔨 Building Docker images..."
echo "   (This may take a few minutes on first run)"
echo "   Building: MySQL, Spring Boot API, React Frontend"
echo ""
docker-compose -f docker-compose.yml build
echo ""
echo "✓ Build complete"
echo ""

# Start the development environment
echo "🚀 Starting development environment..."
docker-compose -f docker-compose.yml up -d
echo ""

# Wait for services to be healthy
echo "⏳ Waiting for services to be ready..."
sleep 5

echo "🔍 Checking service health..."
docker-compose -f docker-compose.yml ps

echo ""
echo "⏳ Waiting for frontend to be fully ready..."
sleep 3

echo ""
echo "========================================"
echo "✅ Setup Complete!"
echo "========================================"
echo ""
echo "🌐 Frontend:  http://localhost:3000  (opening in browser...)"
echo "🔌 API:       http://localhost:8080"
echo "🗄️  Database:  localhost:3306 (user:userpassword)"
echo ""
echo "📝 Useful Commands:"
echo "   docker-compose logs -f        - View all logs"
echo "   docker-compose logs -f frontend - View frontend logs"
echo "   docker-compose down           - Stop containers"
echo ""
echo "📖 For more info, see README.md"
echo "========================================"
echo ""

# Open browser if possible
if command -v xdg-open &> /dev/null; then
    # Linux
    xdg-open "http://localhost:3000" &
elif command -v open &> /dev/null; then
    # macOS
    open "http://localhost:3000"
else
    echo "Please visit http://localhost:3000 in your browser"
fi

