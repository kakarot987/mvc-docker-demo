FROM eclipse-temurin:21-jdk AS builder
WORKDIR /build
COPY gradle/ gradle/
COPY gradlew settings.gradle build.gradle ./
COPY src/ src/
RUN chmod +x gradlew && ./gradlew --no-daemon clean bootJar -x test
COPY docker/HealthProbe.java /build/HealthProbe.java
RUN javac /build/HealthProbe.java -d /build/probe
FROM eclipse-temurin:21-jre
WORKDIR /app
RUN groupadd --system app && useradd --system --gid app --uid 1001 app
COPY --from=builder --chown=app:app /build/build/libs/*.jar app.jar
COPY --from=builder --chown=app:app /build/probe/HealthProbe.class /app/HealthProbe.class
USER app
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=5 CMD ["java", "-cp", "/app", "HealthProbe"]
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
