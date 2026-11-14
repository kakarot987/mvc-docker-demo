# MVC Docker Demo
Three-service full-stack CRUD demo: React + Nginx, Spring Boot 3.4.2 / Java 21, and MySQL 8. Portfolio learning sample, not a hardened internet-facing production service.

## Clean clone
Requirements: Docker + Compose v2 (no host JDK/Node required).

```sh
git clone https://github.com/kakarot987/mvc-docker-demo.git
cd mvc-docker-demo
docker compose up --build -d
docker compose ps
curl -f http://localhost:8080/actuator/health
curl -f http://localhost:3000/users
```

UI: http://localhost:3000. The React bundle uses relative `/users` routed by Nginx to Docker's `user-service:8080`. The browser never resolves a container hostname. The frontend package's local development proxy uses `localhost:8080`.

Development exposes frontend on host 3000, API on loopback 8080, and MySQL on loopback 3306. Production-like Compose exposes only frontend 3000; API and DB are internal.

## CRUD API
`GET /users`, `GET /users/{id}`, `POST /users`, `PUT /users/{id}`, `DELETE /users/{id}`.
Users have `id`, `name`, `email`, `phone`, and `address`. The last four fields are required. POST returns 201, DELETE 204, missing IDs 404, invalid inputs 400.

```sh
curl -i -X POST http://localhost:3000/users -H 'Content-Type: application/json' \
  -d '{"name":"Demo","email":"demo@example.com","phone":"555-1234","address":"Demo Street"}'
```

## Database
Flyway runs `db/migration/V1__create_users.sql` for both profiles. Development additionally runs `db/dev/V2__seed_development_users.sql` to insert demo records. Production does not seed demo data. Hibernate uses `ddl-auto=validate`.

Existing databases initialized by the old `ddl-auto=update` are not automatically baselined by Flyway. Migrate or baseline valuable databases intentionally. To reset **disposable development data only**, `docker compose down -v` is destructive; then rerun `docker compose up --build -d`.

## Production-like demo
```sh
cp .env.example .env
# Replace placeholder passwords!
docker compose --env-file .env -f docker-compose.prod.yml up --build -d
curl -f http://localhost:3000/users
```

This is not ready for the public internet without HTTPS, authentication, restricted access, backups, and secure secret storage. JVM options use `JAVA_TOOL_OPTIONS` so the direct Java entrypoint consumes them. The health probe is compiled Java and needs no curl utility.

## Validation
```sh
./gradlew test
docker compose build
docker compose logs user-service
docker compose down
```

Controller tests check CRUD responses, validation and field mapping. Service tests check that phone and address persist on create and update. GitHub Actions runs tests and a clean-clone Compose CRUD smoke check. Do not claim that tests, Docker build, or image-size measurements succeeded until the CI runs prove it.
