# Frontend - React User Management UI

This is the React frontend for the MVC Docker Demo application. It provides a professional user interface for managing users with full CRUD operations.

## Features

- ✅ **User List**: View all users in a responsive table
- ✅ **Create User**: Add new users with form validation
- ✅ **Edit User**: Update existing user information
- ✅ **Delete User**: Remove users with confirmation
- ✅ **Error Handling**: User-friendly error messages
- ✅ **Responsive Design**: Works on desktop and mobile devices
- ✅ **Bootstrap Styling**: Professional, clean UI

## Architecture

```
Frontend (React)
    ↓
  Nginx (Reverse Proxy)
    ↓
 Docker Container
    ↓
 Spring Boot API (localhost:8080/users)
```

## Components

- **App.js** - Main application component with state management
- **UserList** - Displays users in a table with edit/delete actions
- **UserForm** - Form for creating/editing users with validation
- **userService.js** - API service for backend communication

## Development

### Build locally (without Docker)

```bash
cd frontend
npm install
npm start
```

Access at: http://localhost:3000

### Build with Docker

```bash
cd ..
docker build -f frontend/Dockerfile -t mvc-frontend .
docker run -p 3000:3000 mvc-frontend
```

## Technologies

- **React 18** - UI library
- **Axios** - HTTP client
- **Bootstrap 5** - CSS framework
- **Nginx** - Web server (production)

## API Integration

The frontend communicates with the Spring Boot API at `http://localhost:8080/users` (or whatever is set in `REACT_APP_API_URL`).

### Endpoints Used

- `GET /users` - Get all users
- `POST /users` - Create user
- `PUT /users/{id}` - Update user
- `DELETE /users/{id}` - Delete user

## Environment Variables

- `REACT_APP_API_URL` - Backend API URL (default: http://localhost:8080/users)

## Docker Build

The Dockerfile uses a **multi-stage build**:

1. **Builder stage**: Node.js 18 Alpine - compiles React app
2. **Runtime stage**: Nginx Alpine - serves compiled app

Final image size: ~50MB

## Nginx Configuration

- Serves React static files efficiently
- Proxies API requests to Spring Boot backend
- Handles SPA routing (all requests → index.html)
- Gzip compression enabled
- Cache control headers for static assets

## Production Readiness

- ✅ Non-root user execution (nginx user)
- ✅ Health check configured
- ✅ Gzip compression
- ✅ Static asset caching
- ✅ Security headers support
- ✅ Multi-stage build for optimization

## Troubleshooting

### API connection fails
- Ensure Spring Boot API is running on port 8080
- Check network connectivity: `docker-compose ps`
- Verify REACT_APP_API_URL is correct

### Blank screen or 404 errors
- Check Nginx logs: `docker logs mvc-ui-dev`
- Ensure build completed successfully
- Clear browser cache

### Port 3000 already in use
- Stop other services: `docker-compose down`
- Or change port in docker-compose.yml

## Contributing

This is a portfolio showcase project. For improvements, feel free to:
- Add more user fields
- Implement pagination
- Add search/filter
- Add user roles
- Implement authentication

---

**Status**: ✅ Production Ready  
**Version**: 1.0  
**Last Updated**: May 2026

