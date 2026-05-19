# Docker Architecture & Knowledge Demonstration

## 📋 Table of Contents
1. [Multi-Stage Build](#multi-stage-build)
2. [Environment Configuration](#environment-configuration)
3. [Docker Compose Orchestration](#docker-compose-orchestration)
4. [Security Best Practices](#security-best-practices)
5. [Performance Optimization](#performance-optimization)
6. [Networking & Service Discovery](#networking--service-discovery)
7. [Health Checks & Readiness](#health-checks--readiness)
8. [Production vs Development](#production-vs-development)

---

## 🏗️ Multi-Stage Build

### What it is:
A Docker build process that uses multiple `FROM` statements to create intermediate stages, with only the final stage producing the output image.

### Implementation in this project:

**Stage 1: Builder (Compile)**

```dockerfile
FROM eclipse-temurin:21-jdk AS builder

WORKDIR /build
COPY ../gradle gradle
COPY ../build.gradle settings.gradle gradlew ./
COPY ../src src

# This stage runs the full Gradle build
RUN chmod +x gradlew && ./gradlew clean bootJar -x test --no-daemon
```

**Stage 2: Runtime (Execute)**
```dockerfile
FROM eclipse-temurin:21-jre

WORKDIR /app
RUN useradd -m -u 1001 appuser
COPY --from=builder --chown=appuser:appuser /build/build/libs/*.jar app.jar
USER appuser

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Why it matters:

| Aspect | Single-Stage | Multi-Stage |
|--------|--------------|-------------|
| Build Tools in Image | ✓ (bloat) | ✗ (not included) |
| JDK in Final Image | ✓ (~700MB per line) | ✗ |
| JRE in Final Image | ✓ | ✓ (necessary) |
| Final Image Size | ~700MB | ~350MB |
| Security Surface | Large | Minimal |
| Build Time | ~1.5min | ~2min (first time) |
| Deploy Time | Slower | Faster |

### Technical Benefits:
1. **Layer Caching**: Each stage caches independently
2. **Smaller Images**: No build tools in production
3. **Faster Deployments**: Reduced transfer size
4. **Better Security**: Minimal attack surface
5. **Cleaner Separation**: Build env ≠ runtime env

---

## 🔧 Environment Configuration

### Profile-Based Configuration

This project uses **Spring Boot Profiles** to switch configurations:

#### application.properties (Default)
```properties
# Common across all environments
spring.application.name=mvc-docker-app
spring.jpa.database-platform=org.hibernate.dialect.MySQL8Dialect
spring.jpa.open-in-view=false
```

#### application-dev.properties (Development)
```properties
# Verbose for debugging
spring.datasource.url=jdbc:mysql://mysql-db:3306/userdb?...
spring.datasource.username=user
spring.datasource.password=userpassword

# Auto-create/update schema
spring.jpa.hibernate.ddl-auto=update

# Debug logging enabled
logging.level.com.mvc_docker=DEBUG
logging.level.org.hibernate.SQL=DEBUG

# Show errors fully
server.error.include-stacktrace=always
```

#### application-prod.properties (Production)
```properties
# Secrets from environment
spring.datasource.url=${SPRING_DATASOURCE_URL}
spring.datasource.username=${SPRING_DATASOURCE_USERNAME}
spring.datasource.password=${SPRING_DATASOURCE_PASSWORD}

# Strict validation only
spring.jpa.hibernate.ddl-auto=validate

# Minimal logging
logging.level.root=WARN

# Hide sensitive errors
server.error.include-stacktrace=never
```

### Activation Method:
```bash
# Development
SPRING_PROFILES_ACTIVE=dev

# Production
SPRING_PROFILES_ACTIVE=prod
```

---

## 🐳 Docker Compose Orchestration

### Development Stack (docker-compose.yml)

```yaml
version: "3.8"

services:
  mysql-db:
    image: mysql:8
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: userdb
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - app-network

  user-service:
    build:
      context: .
      dockerfile: Dockerfile
    depends_on:
      mysql-db:
        condition: service_healthy  # ← Wait for database readiness
    environment:
      SPRING_PROFILES_ACTIVE: dev
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql-db:3306/userdb...
```

### Key Concepts Demonstrated:

1. **Service Discovery**: Services communicate via hostname
   ```yaml
   # App connects to DB using service name
   spring.datasource.url=jdbc:mysql://mysql-db:3306/userdb
   ```

2. **Health Checks**: Ensures readiness
   ```yaml
   healthcheck:
     test: ["CMD", "mysqladmin", "ping"]
     interval: 10s
     timeout: 5s
     retries: 5
   ```

3. **Service Dependencies**: Ensures correct startup order
   ```yaml
   depends_on:
     mysql-db:
       condition: service_healthy  # Wait for health, not just start
   ```

4. **Named Volumes**: Persistent data storage
   ```yaml
   volumes:
     mysql_dev_data:
       driver: local
   ```

5. **Custom Networks**: Isolated communication
   ```yaml
   networks:
     app-network:
       driver: bridge
   ```

---

## 🔒 Security Best Practices

### 1. Non-Root User Execution

**Problem**: Running as root is a security risk. If container is compromised, attacker has root access.

**Implementation**:
```dockerfile
# Create a non-root user with specific UID
RUN useradd -m -u 1001 appuser

# Set ownership of files
COPY --chown=appuser:appuser /build/build/libs/*.jar app.jar

# Switch to non-root user before running
USER appuser

# Cannot run as root now - enforces principle of least privilege
```

**Why it matters**:
- Limits damage from container breakout
- Meets compliance requirements
- Best practice in all major deployment platforms

### 2. Secret Management

**Problem**: Hardcoding passwords is a security nightmare.

**Implementation**:
```yaml
# Docker Compose (dev - okay to hardcode for dev)
environment:
  MYSQL_PASSWORD: userpassword

# Production - use environment variables
environment:
  MYSQL_PASSWORD: ${DB_PASSWORD}  # Load from .env file
```

**.gitignore**:
```
.env
.env.local
.env.*.local
```

**.env file** (not committed):
```env
DB_PASSWORD=actual_secure_password
```

### 3. Minimal Base Image

**Single-stage problem**:
```dockerfile
FROM openjdk:21  # Includes full JDK + build tools (~700MB)
```

**Multi-stage solution**:
```dockerfile
# Builder stage
FROM eclipse-temurin:21-jdk AS builder

# Runtime stage (final image)
FROM eclipse-temurin:21-jre  # Only runtime (~350MB)
```

### 4. .dockerignore File

**Problem**: Unnecessary files increase build context size and build time.

**Implementation**:
```
.git
.gradle
build/
.env.local
*.log
```

**Benefits**:
- Faster builds (smaller context)
- Doesn't copy environment files to image
- Cleaner build output

---

## ⚡ Performance Optimization

### 1. Database Connection Pooling

```properties
spring.datasource.hikari.maximum-pool-size=20
spring.datasource.hikari.minimum-idle=5
```

**Why**: 
- Reuses connections instead of creating new ones
- Reduces latency
- Better resource usage

### 2. JVM Tuning

```yaml
environment:
  JAVA_OPTS: "-Xmx512m -Xms256m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"
```

**Breakdown**:
- `-Xmx512m`: Maximum heap size (prevent OOM)
- `-Xms256m`: Initial heap size (faster startup)
- `-XX:+UseG1GC`: Use G1 garbage collector (modern, low-pause)
- `-XX:MaxGCPauseMillis=200`: Max pause time for GC

### 3. Batch Operations

```properties
# Batch multiple INSERT/UPDATE statements
hibernate.jdbc.batch_size=20
hibernate.order_inserts=true
hibernate.order_updates=true
```

**Impact**: 
- Fewer database round trips
- 20x more efficient for bulk operations

### 4. Image Layer Caching

```dockerfile
# Order matters! Put changing files last
COPY gradle gradle           # Rarely changes
COPY build.gradle settings.gradle ./  # Rarely changes
COPY src src                 # Frequently changes

# Docker caches layers - only rebuild from changed layer onwards
```

---

## 🌐 Networking & Service Discovery

### Docker Network Model

```
┌─────────────────────────────────────────┐
│       Docker Engine (Host)              │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │   app-network (bridge)           │  │
│  │                                  │  │
│  │  ┌──────────────┐  ┌──────────┐  │  │
│  │  │  mysql-db    │  │user-app  │  │  │
│  │  │              │  │          │  │  │
│  │  │ IP: 172.x.x.2│  │ IP: 172  │  │  │
│  │  └──────────────┘  └──────────┘  │  │
│  │                                  │  │
│  │  Service Discovery (DNS):        │  │
│  │  mysql-db → 172.x.x.2           │  │
│  │  user-service → 172.x.x.3       │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
                    ↓
        Exposed to Host via Ports
        http://localhost:8080
        localhost:3306
```

### Implementation

```yaml
networks:
  app-network:
    driver: bridge  # Isolated network for this compose stack

services:
  mysql-db:
    networks:
      - app-network

  user-service:
    networks:
      - app-network
    # Can resolve mysql-db hostname automatically
    environment:
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql-db:3306/userdb
```

**How it works**:
1. Docker's embedded DNS resolves service names
2. Each service gets a virtual IP on the bridge network
3. Services can communicate by hostname
4. External connections use exposed ports

---

## 💓 Health Checks & Readiness

### Docker Health Check

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1
```

**Parameters**:
- `--interval=30s`: Check every 30 seconds
- `--timeout=3s`: Fail if takes longer than 3 seconds
- `--start-period=40s`: Wait 40s before first check (app startup time)
- `--retries=3`: Require 3 consecutive failures to mark unhealthy

**Check container health**:
```bash
docker ps
# HEALTHCHECK shows: (healthy), (starting), (unhealthy)
```

### Service Dependencies with Health

```yaml
depends_on:
  mysql-db:
    condition: service_healthy  # Wait for health, not just container start
```

**Why important**:
- Container starts ≠ service ready
- App might crash during startup
- Health check ensures true readiness

---

## 🚀 Production vs Development

### Comparison Table

| Feature | Development | Production |
|---------|-------------|-----------|
| **Database Schema** | `ddl-auto=update` (auto-evolve) | `ddl-auto=validate` (strict) |
| **Logging** | DEBUG (verbose) | WARN (minimal) |
| **SQL Logging** | Enabled (see queries) | Disabled (performance) |
| **Error Details** | Full stack traces | Generic messages |
| **Actuator Endpoints** | All exposed | health only |
| **Restart Policy** | `unless-stopped` | `always` |
| **Configuration Source** | Hardcoded | Environment variables |
| **JVM Memory** | 512m max heap | Tuned for workload |
| **Image Optimization** | Standard | Multi-stage optimized |

### Configuration Activation

**Development**:
```bash
docker-compose -f docker-compose.yml up -d
# Automatically sets SPRING_PROFILES_ACTIVE=dev
```

**Production**:
```bash
cp .env.example .env
# Edit .env with real production secrets
docker-compose -f docker-compose.prod.yml --env-file .env up -d
# Sets SPRING_PROFILES_ACTIVE=prod
```

---

## 📊 Build Process Flow

### How Multi-Stage Build Works

```
┌─────────────────────────────────────────────┐
│ Stage 1: BUILDER                            │
│ FROM eclipse-temurin:21-jdk          │
│                                             │
│ 1. Copy source code (COPY src src)         │
│ 2. Compile with Gradle                      │
│ 3. Generate JAR in /build/libs/             │
│                                             │
│ Image Size: ~700MB (will be discarded)     │
└─────────────────────────────────────────────┘
                    ↓
         Extract JAR artifact
                    ↓
┌─────────────────────────────────────────────┐
│ Stage 2: RUNTIME (Final Image)             │
│ FROM eclipse-temurin:21-jre          │
│                                             │
│ 1. Create non-root user                     │
│ 2. Copy JAR from builder                    │
│ 3. Configure runtime (EXPOSE, ENTRYPOINT)  │
│                                             │
│ Image Size: ~350MB (what gets pushed)      │
└─────────────────────────────────────────────┘
```

---

## 🎯 Key Takeaways for Interviews

### Knowledge Points to Mention

1. **Multi-Stage Builds**
   > "I use multi-stage builds to separate the build environment from the runtime environment. This reduces the final image size by 50%, improves security by excluding build tools, and speeds up deployments."

2. **Environment-Specific Configurations**
   > "I implement Spring Boot profiles to manage different configurations for development and production. Development has verbose logging for debugging, while production uses minimal logging and strict database validation."

3. **Service Orchestration**
   > "I use Docker Compose with health checks and service dependencies to ensure proper startup order and service readiness before dependents start."

4. **Security Best Practices**
   > "I follow security best practices like running containers as non-root users, managing secrets through environment variables, and minimizing the attack surface with slim base images."

5. **Performance Optimization**
   > "I optimize performance through database connection pooling, batch operations, and JVM tuning for garbage collection and memory management."

---

## 📚 Resource Commands

```bash
# View image size comparison
docker images | grep mvc-docker || docker images

# Check multi-stage build details
docker history mvc-docker-demo_user-service:latest

# Inspect container configuration
docker inspect mvc-app-dev

# View network setup
docker network inspect app-network

# Check health status
docker ps --format "table {{.Names}}\t{{.Status}}"
```

---

## 🔍 Debugging Commands

```bash
# Check logs
docker-compose logs user-service
docker-compose logs mysql-db

# Open shell in container
docker-compose exec user-service sh
docker-compose exec mysql-db mysql -u user -p userdb

# View environment variables
docker-compose exec user-service env

# Check network connectivity
docker-compose exec user-service ping mysql-db

# View resource usage
docker stats

# Inspect image layers
docker inspect --format='{{range .RootFS.Layers}}{{.}}{{println}}{{end}}' mvc-docker-demo_user-service:latest
```

---

**Document Version**: 1.0  
**Last Updated**: May 2026  
**Docker Knowledge Level**: Intermediate to Advanced

