# MVC Docker Demo — React frontend

React 18, Axios, Bootstrap 5, and Nginx provide a simple CRUD UI for the Spring Boot backend. The user form, DTO, database entity, and persistence layer all support `name`, `email`, `phone`, and `address`.

## Run the complete app

From the repository root:

```sh
docker compose up --build -d
docker compose ps
```

Visit **http://localhost:3000**. The browser calls `/users` on the same origin. Nginx forwards those requests to `user-service:8080` on the Docker network. No `REACT_APP_API_URL` variable is required and the browser never needs to resolve Docker-internal DNS.

For local hot-reload development, start the backend on port 8080, then run `cd frontend && npm install && npm start`. The React dev-server proxy in `package.json` forwards API calls to `http://localhost:8080`.

## Build

The Dockerfile builds with Node 22 Alpine and serves the resulting static assets with Nginx. When building the frontend image manually, run from the frontend folder (`docker build -t mvc-frontend ./frontend` from the project root) and connect the container to the same network as the backend service; standalone `docker run` without the backend service will not make API requests succeed.

This demo does not claim a measured final image size or production readiness. Security controls such as HTTPS, access management, authentication and CSP must be assessed before a real public deployment.
