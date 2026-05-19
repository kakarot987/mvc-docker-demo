.PHONY: help dev prod build build-prod up down logs logs-db clean clean-all healthcheck

# Default target
.DEFAULT_GOAL := help

# ==================== HELP ====================
help:
	@echo "================================"
	@echo "MVC Docker Demo - Available Commands"
	@echo "================================"
	@echo ""
	@echo "DEVELOPMENT COMMANDS:"
	@echo "  make dev              - Start development environment"
	@echo "  make dev-build        - Build and start development environment"
	@echo "  make dev-logs         - View development application logs"
	@echo "  make dev-down         - Stop development environment"
	@echo ""
	@echo "PRODUCTION COMMANDS:"
	@echo "  make prod             - Start production environment (requires .env file)"
	@echo "  make prod-build       - Build and start production environment"
	@echo "  make prod-logs        - View production application logs"
	@echo "  make prod-down        - Stop production environment"
	@echo ""
	@echo "BUILD COMMANDS:"
	@echo "  make build            - Build Docker image (multi-stage)"
	@echo "  make build-nc         - Build without cache"
	@echo ""
	@echo "UTILITY COMMANDS:"
	@echo "  make logs             - View all container logs"
	@echo "  make db-logs          - View database logs"
	@echo "  make healthcheck      - Check container health"
	@echo "  make shell-app        - Open shell in app container"
	@echo "  make shell-db         - Open shell in database container"
	@echo ""
	@echo "CLEANUP COMMANDS:"
	@echo "  make clean            - Stop and remove containers (keeps volumes)"
	@echo "  make clean-all        - Stop and remove everything (including volumes)"
	@echo "  make clean-images     - Remove Docker images"
	@echo ""

# ==================== DEVELOPMENT ====================
dev:
	@echo "Starting development environment..."
	docker-compose -f docker-compose.yml up -d
	@echo "✓ Development environment started"
	@echo "App running at: http://localhost:8080"
	@echo "Database running at: localhost:3306"

dev-build:
	@echo "Building and starting development environment..."
	docker-compose -f docker-compose.yml build
	docker-compose -f docker-compose.yml up -d
	@echo "✓ Development environment ready"

dev-logs:
	docker-compose -f docker-compose.yml logs -f user-service

dev-down:
	@echo "Stopping development environment..."
	docker-compose -f docker-compose.yml down
	@echo "✓ Development environment stopped"

# ==================== PRODUCTION ====================
prod:
	@echo "Starting production environment..."
	@if [ ! -f .env ]; then \
		echo "ERROR: .env file not found!"; \
		echo "Please copy .env.example to .env and fill in production values"; \
		exit 1; \
	fi
	docker-compose -f docker-compose.prod.yml --env-file .env up -d
	@echo "✓ Production environment started"
	@echo "App running at: http://localhost:8080"
	@echo "Database running at: localhost:3306"

prod-build:
	@echo "Building and starting production environment..."
	@if [ ! -f .env ]; then \
		echo "ERROR: .env file not found!"; \
		echo "Please copy .env.example to .env and fill in production values"; \
		exit 1; \
	fi
	docker-compose -f docker-compose.prod.yml --env-file .env build
	docker-compose -f docker-compose.prod.yml --env-file .env up -d
	@echo "✓ Production environment ready"

prod-logs:
	@if [ ! -f .env ]; then \
		docker-compose -f docker-compose.prod.yml logs -f user-service; \
	else \
		docker-compose -f docker-compose.prod.yml --env-file .env logs -f user-service; \
	fi

prod-down:
	@echo "Stopping production environment..."
	docker-compose -f docker-compose.prod.yml down
	@echo "✓ Production environment stopped"

# ==================== BUILD ====================
build:
	@echo "Building Docker image (multi-stage)..."
	docker-compose -f docker-compose.yml build
	@echo "✓ Build complete"

build-nc:
	@echo "Building Docker image without cache..."
	docker-compose -f docker-compose.yml build --no-cache
	@echo "✓ Build complete"

# ==================== LOGS & MONITORING ====================
logs:
	docker-compose -f docker-compose.yml logs -f

db-logs:
	docker-compose -f docker-compose.yml logs -f mysql-db

healthcheck:
	@echo "Checking container health..."
	@docker-compose -f docker-compose.yml ps
	@echo ""
	@curl -s http://localhost:8080/actuator/health | python3 -m json.tool 2>/dev/null || echo "App health check endpoint not responding"

# ==================== SHELL ACCESS ====================
shell-app:
	docker-compose -f docker-compose.yml exec user-service sh

shell-db:
	docker-compose -f docker-compose.yml exec mysql-db mysql -h localhost -u user -puserpassword userdb

# ==================== CLEANUP ====================
clean:
	@echo "Stopping and removing containers..."
	docker-compose -f docker-compose.yml down
	@echo "✓ Containers removed (volumes preserved)"

clean-all:
	@echo "WARNING: This will remove ALL containers and volumes!"
	@read -p "Continue? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose -f docker-compose.yml down -v; \
		echo "✓ All containers and volumes removed"; \
	else \
		echo "✗ Cancelled"; \
	fi

clean-images:
	@echo "Removing Docker images..."
	docker-compose -f docker-compose.yml down --rmi all
	@echo "✓ Images removed"

# ==================== ONE-COMMAND SETUP ====================
setup:
	@echo "========================================"
	@echo "MVC Docker Demo - Initial Setup"
	@echo "========================================"
	@echo ""
	@if [ ! -f .env ]; then \
		echo "Creating .env from .env.example..."; \
		cp .env.example .env; \
		echo "✓ .env file created"; \
		echo "⚠️  Please edit .env with production credentials"; \
		echo ""
	fi
	@echo "Building application..."
	docker-compose -f docker-compose.yml build
	@echo "✓ Build complete"
	@echo ""
	@echo "Starting development environment..."
	docker-compose -f docker-compose.yml up -d
	@echo "✓ Environment ready!"
	@echo ""
	@echo "========================================"
	@echo "Application is running at: http://localhost:8080"
	@echo "Database is running at: localhost:3306"
	@echo "========================================"

