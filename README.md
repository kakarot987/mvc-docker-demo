# MVC Docker Demo - Professional Portfolio Project

> A comprehensive Spring Boot + MySQL application demonstrating enterprise-level Docker knowledge including multi-stage builds, environment-specific configurations, and production-ready practices.

![Java](https://img.shields.io/badge/Java-21-orange?style=flat-square)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.4.2-green?style=flat-square)
![Docker](https://img.shields.io/badge/Docker-Multi--Stage%20Build-blue?style=flat-square)
![MySQL](https://img.shields.io/badge/MySQL-8-blue?style=flat-square)

## 🎯 Project Overview

This project showcases professional Docker skills and best practices suitable for portfolio presentations. It demonstrates:

- **Multi-stage Docker builds** for optimized image sizes
- **Environment-specific configurations** (dev, prod)
- **Spring Boot profiles** for different deployment scenarios
- **Docker Compose orchestration** with health checks and logging
- **Security best practices** (non-root user, secret management)
- **Production-ready optimizations** (JVM tuning, database pooling)

---

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose installed
- Git
- Make (optional, for using Makefile commands on Linux/Mac)

### One-Command Setup

**Linux/Mac:**
```bash
chmod +x setup.sh && ./setup.sh
```

**Windows (PowerShell):**
```powershell
.\setup.ps1
```

**Windows (CMD or using Make):**
```bash
make setup
```

These commands will:
1. ✅ Build the Docker image with multi-stage compilation
2. ✅ Start MySQL database container
3. ✅ Start Spring Boot application container
4. ✅ Initialize database with sample data

After setup, access the application at: **http://localhost:8080**

---

## 📋 Architecture

### Multi-Stage Docker Build Strategy

```
┌─────────────────────────────────────────┐
│         STAGE 1: BUILDER (JDK)          │
├─────────────────────────────────────────┤
│ • Full eclipse-temurin:21-jdk     │
│ • Compile Java code                     │
│ • Run Gradle build                      │
│ • Generates JAR artifact                │
│ • Size: ~700MB (discarded after build)  │
└─────────────────────────────────────────┘
                    ↓
         ┌──────────────────────┐
         │ Copy JAR artifact    │
         └──────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│         STAGE 2: RUNTIME (JRE)          │
├─────────────────────────────────────────┤
│ • Slim eclipse-temurin:21-jre     │
│ • Minimum attack surface                │
│ • Non-root user (appuser:1001)          │
│ • Health check configured               │
│ • Final Image Size: ~350MB              │
│ • 50%+ smaller than single-stage build  │
└─────────────────────────────────────────┘
```

**Benefits:**
- 📉 **50% Smaller Image**: Only runtime JRE in final image
- 🔒 **Better Security**: Minimal dependencies, no build tools
- ⚡ **Faster Deployments**: Smaller image = faster transfers
- 👤 **Non-Root User**: Follows security best practices

### Environment Configurations

```
Development (docker-compose.yml)
├── Debug logging enabled
├── SQL query logging
├── Eager database initialization (update)
├── Full error stack traces
└── Health metrics exposed

Production (docker-compose.prod.yml)
├── Minimal logging (WARN level)
├── No SQL query logging
├── Strict database validation
├── Error details hidden
├── Limited health metrics
└── JVM memory optimization
```

---

## 📂 Project Structure

```
mvc-docker-demo/
├── Dockerfile                      # Multi-stage build configuration
├── docker-compose.yml              # Development environment
├── docker-compose.prod.yml         # Production environment
├── .dockerignore                   # Docker build exclusions
├── .env.example                    # Environment variables template
├── Makefile                        # Easy command shortcuts
├── setup.sh                        # Linux/Mac automated setup
├── setup.ps1                       # Windows automated setup
├── README.md                       # This file
│
├── src/main/
│   ├── java/com/mvc_docker/
│   │   ├── MvcDockerApplication.java
│   │   ├── controller/
│   │   │   └── UserController.java
│   │   ├── entity/
│   │   │   ├── User.java
│   │   │   └── UserDto.java
│   │   ├── repository/
│   │   │   └── UserRepository.java
│   │   └── service/
│   │       ├── UserService.java
│   │       └── UserServiceImpl.java
│   │
│   └── resources/
│       ├── application.properties          # Default config
│       ├── application-dev.properties      # Development profile
│       ├── application-prod.properties     # Production profile
│       └── data.sql                        # Sample data
│
└── gradle/
    └── wrapper/
```

---

## 🛠️ Available Commands

### Development Environment

Start the development environment with debug logging:
```bash
make dev              # Start dev environment
make dev-build       # Build and start dev environment
make dev-logs        # View app logs
make dev-down        # Stop dev environment
```

Or directly with Docker:
```bash
docker-compose up -d                    # Start (background)
docker-compose up                       # Start (foreground with logs)
docker-compose logs -f user-service     # View logs
docker-compose down                     # Stop
```

### Production Environment

**Setup Production First:**
```bash
# Copy and edit environment variables
cp .env.example .env
# Edit .env with production credentials
```

**Run Production:**
```bash
make prod              # Start prod environment
make prod-build       # Build and start prod
make prod-logs        # View logs
make prod-down        # Stop prod
```

Or directly with Docker:
```bash
docker-compose -f docker-compose.prod.yml --env-file .env up -d
docker-compose -f docker-compose.prod.yml --env-file .env logs -f
docker-compose -f docker-compose.prod.yml down
```

### Build Commands

```bash
make build            # Build Docker image
make build-nc         # Build without cache (fresh build)
```

### Monitoring & Troubleshooting

```bash
make logs             # View all container logs
make db-logs          # View database logs only
make healthcheck      # Check container status
make shell-app        # Open shell in app container
make shell-db         # Open MySQL shell
```

### Cleanup

```bash
make clean            # Stop containers (keep volumes)
make clean-all        # Remove everything (including data)
make clean-images     # Remove Docker images
```

---

## 🔧 Configuration Details

### Development Configuration (application-dev.properties)

```properties
# Database (local docker service)
spring.datasource.url=jdbc:mysql://mysql-db:3306/userdb
spring.datasource.username=user
spring.datasource.password=userpassword

# Database schema management
spring.jpa.hibernate.ddl-auto=update    # Auto-create/update schema

# Logging
logging.level.com.mvc_docker=DEBUG      # App debug logs
logging.level.org.hibernate.SQL=DEBUG   # SQL queries

# Server
server.error.include-stacktrace=always  # Full error details
```

### Production Configuration (application-prod.properties)

```properties
# Database (from environment variables)
spring.datasource.url=${SPRING_DATASOURCE_URL}
spring.datasource.username=${SPRING_DATASOURCE_USERNAME}
spring.datasource.password=${SPRING_DATASOURCE_PASSWORD}

# Strict database validation
spring.jpa.hibernate.ddl-auto=validate  # No auto-updates

# Minimal logging
logging.level.root=WARN                 # Reduce noise
logging.level.com.mvc_docker=INFO       # App info only

# Security
server.error.include-stacktrace=never   # Hide internals
```

### Environment Variables (.env)

```env
# Required for production deployment
DB_ROOT_PASSWORD=your_secure_root_password
DB_NAME=userdb_production
DB_USER=produser
DB_PASSWORD=your_secure_user_password
```

---

## 🐳 Docker Features Demonstrated

### 1. Multi-Stage Build (Dockerfile)

```dockerfile
# Stage 1: Compile with full JDK (Java 21 - LTS)
FROM eclipse-temurin:21-jdk AS builder
...build application...

# Stage 2: Continue with slim JRE (Java 21 - LTS)
FROM eclipse-temurin:21-jre
COPY --from=builder /build/build/libs/*.jar app.jar
```

**Why it matters for portfolio:**
- Shows understanding of Docker optimization
- Demonstrates knowledge of image layer caching
- Proves understanding of production vs. build requirements

### 2. Health Checks

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1
```

**Service Dependencies:**
```yaml
depends_on:
  mysql-db:
    condition: service_healthy  # Wait for database readiness
```

### 3. Non-Root User

```dockerfile
RUN useradd -m -u 1001 appuser
USER appuser
```

Security best practice to prevent container escape vulnerabilities.

### 4. .dockerignore

Excludes unnecessary files from build context:
- Version control (.git)
- Build artifacts (gradle, target)
- IDE files (.idea, .vscode)
- Environment-specific files (.env.local)

### 5. Networking & Service Discovery

```yaml
networks:
  app-network:
    driver: bridge

# Service connects via hostname
spring.datasource.url=jdbc:mysql://mysql-db:3306/userdb
```

Demonstrates Docker networking knowledge.

---

## 📊 Performance Metrics

### Image Sizes

| Build Type | Size | Time |
|-----------|------|------|
| Traditional Single-Stage | ~700MB | ~1.5min |
| Multi-Stage Build | ~350MB | ~2min |
| Savings | **50% smaller** | 33% more time (one-time) |

### Database Performance

```yaml
# Connection pooling (Hikari)
spring.datasource.hikari.maximum-pool-size=20
spring.datasource.hikari.minimum-idle=5

# Batch operations
hibernate.jdbc.batch_size=20
```

---

## 🔐 Security Practices Implemented

| Practice | Implementation |
|----------|-----------------|
| **Non-Root User** | `USER appuser` in Dockerfile |
| **Secret Management** | Environment variables (.env) |
| **Minimal Image** | Multi-stage build with JRE only |
| **No Credentials in Code** | Properties from environment |
| **Strict Validation** | Production: `ddl-auto=validate` |
| **Logging Sensitive Data** | Production: Hidden error details |
| **.gitignore** | Excludes .env and sensitive files |
| **Read-Only Filesystem** | Recommended for production |

---

## 📝 API Endpoints

Once running (http://localhost:8080):

**Health Check:**
```bash
curl http://localhost:8080/actuator/health
```

**Application Endpoints** (depends on your UserController):
- `GET /users` - List all users
- `POST /users` - Create user
- `GET /users/{id}` - Get user by ID
- `PUT /users/{id}` - Update user
- `DELETE /users/{id}` - Delete user

---

## 🐛 Troubleshooting

### Application won't start
```bash
# Check logs
docker-compose logs user-service

# Common issues:
# 1. Port 8080 already in use: lsof -i :8080
# 2. Database not ready: docker-compose logs mysql-db
# 3. Wrong SPRING_PROFILES_ACTIVE: should be 'dev' or 'prod'
```

### Database connection failed
```bash
# Verify DB is running
docker-compose ps

# Check network
docker network ls
docker network inspect app-network

# Test from app container
docker-compose exec user-service curl http://mysql-db:3306
```

### Build failures
```bash
# Clean rebuild
make clean-all
make build

# Or rebuild without cache
docker-compose build --no-cache
```

---

## 📚 Learning Resources - Docker Concepts Demonstrated

1. **Multi-Stage Builds**
   - Separates build environment from runtime
   - Reduces final image size
   - [Docker Docs](https://docs.docker.com/build/building/multi-stage/)

2. **Docker Compose Networking**
   - Service discovery via hostname
   - Custom bridge networks
   - Service dependencies

3. **Environment Variables & Secret Management**
   - `.env` files for configuration
   - Environment-specific profiles
   - Password management best practices

4. **Health Checks**
   - Container orchestration readiness
   - Service dependencies with health conditions
   - Liveness and readiness probes

5. **Security Best Practices**
   - Non-root user execution
   - Minimal base images
   - `.dockerignore` for clean builds

---

## 🎓 Portfolio Talking Points

When discussing this project in interviews:

1. **Multi-Stage Build Optimization**
   > "I implemented a multi-stage Docker build that reduces image size by 50%. The builder stage uses the full JDK for compilation, while the final runtime stage uses only the slim JRE, resulting in a much smaller, faster-deploying image."

2. **Environment Flexibility**
   > "The project uses environment-specific Docker Compose files and Spring profiles. Development has verbose logging for debugging, while production uses minimal logging and strict database validation for stability."

3. **Production-Ready Practices**
   > "I implemented security best practices including non-root user execution, health checks for service readiness, and environment-based configuration management."

4. **Container Orchestration Knowledge**
   > "I demonstrated Docker networking, service discovery, and dependency management using Docker Compose, with health checks ensuring services are ready before dependents start."

---

## 🔄 CI/CD Integration Example

This project is ready for integration with:
- **GitHub Actions**: Build and push to Docker Registry
- **GitLab CI**: Multi-stage pipeline
- **Jenkins**: Docker agent with image push
- **Kubernetes**: Ready for deployment

Example `.env` production setup:
```bash
# For Kubernetes/CloudRun
REGISTRY=gcr.io/my-project
IMAGE_TAG=v1.0.0
```

---

## 📄 License

This project is provided as a portfolio demonstration project.

---

## ✨ Future Enhancements (Optional)

- [ ] Add integration tests in separate Docker Compose file
- [ ] Implement Docker secrets for sensitive data
- [ ] Add reverse proxy (Nginx) with SSL/TLS
- [ ] Implement log aggregation (ELK Stack)
- [ ] Add monitoring (Prometheus + Grafana)
- [ ] Kubernetes deployment manifests
- [ ] Multi-architecture builds (ARM64 support)

---

## 📞 Support

For questions or issues, review:
- Docker documentation: https://docs.docker.com
- Spring Boot docs: https://spring.io/projects/spring-boot
- This README's troubleshooting section

---

**Last Updated:** May 2026  
**Docker Version:** 20.10+  
**Docker Compose Version:** 2.0+

