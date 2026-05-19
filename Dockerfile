# ==================== STAGE 1: BUILDER ====================
# Build stage with full JDK for compilation (Java 21 - LTS)
FROM eclipse-temurin:21-jdk AS builder

WORKDIR /build

# Copy gradle wrapper and build files
COPY gradle gradle
COPY build.gradle settings.gradle gradlew ./

# Copy source code
COPY src src

# Build the application (skip tests for Docker build)
RUN chmod +x gradlew && \
    ./gradlew clean bootJar -x test --no-daemon

# ==================== STAGE 2: RUNTIME ====================
# Optimized runtime stage with slim JRE (Java 21 - LTS)
FROM eclipse-temurin:21-jre

WORKDIR /app

# Create a non-root user for security best practices
RUN useradd -m -u 1001 appuser

# Copy built JAR from builder stage
COPY --from=builder --chown=appuser:appuser /build/build/libs/*.jar app.jar

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 8080

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]