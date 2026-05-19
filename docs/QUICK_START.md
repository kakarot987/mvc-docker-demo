# 🚀 Quick Start Guide

## 30-Second Setup

Choose your platform:

### Windows (PowerShell)
```powershell
.\setup.ps1
```

### Windows (Command Prompt)
```cmd
setup.bat
```

### Linux / Mac
```bash
chmod +x setup.sh && ./setup.sh
```

**That's it!** ✨ Your application will be running at **http://localhost:8080**

---

## What Just Happened?

The setup script:
1. ✅ Built Docker image with multi-stage compilation
2. ✅ Started MySQL database container
3. ✅ Started Spring Boot application container
4. ✅ Initialized database with sample data

---

## Common Commands

### View Logs
```bash
docker-compose logs -f user-service
```

### Stop Services
```bash
docker-compose down
```

### Restart Services
```bash
docker-compose up -d
```

### Full Cleanup
```bash
docker-compose down -v
```

---

## Alternative: Manual Setup

If the automated script doesn't work:

```bash
# Build the image
docker-compose build

# Start services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

---

## Development Setup (Multiple Environments)

### Use Make Commands (Linux/Mac)
```bash
make dev              # Start dev environment
make dev-logs        # View logs
make dev-down        # Stop

make prod            # Start production
make prod-logs       # View logs
make prod-down       # Stop
```

### Use Direct Docker Compose

**Development**:
```bash
docker-compose -f docker-compose.yml up -d
```

**Production**:
```bash
# First, create .env file with production credentials
cp .env.example .env
# Edit .env

# Then start production
docker-compose -f docker-compose.prod.yml --env-file .env up -d
```

---

## Accessing the Application

- **Application**: http://localhost:8080
- **Database**: localhost:3306
  - Username: `user`
  - Password: `userpassword`
  - Database: `userdb`

---

## Need Help?

1. **Check logs**: `docker-compose logs`
2. **Check containers**: `docker-compose ps`
3. **Read documentation**: Open `README.md` or `DOCKER_ARCHITECTURE.md`
4. **Rebuild from scratch**: `docker-compose down -v && docker-compose build`

---

## Portfolio Highlights

When showing this project:

✨ **Multi-stage Docker build** - Shows image optimization  
✨ **Environment configurations** - Dev vs Prod setup  
✨ **Container orchestration** - Docker Compose with health checks  
✨ **Security practices** - Non-root user, secret management  
✨ **Professional documentation** - Complete setup guides  

---

That's all you need to know to get started! 🎉

For deeper understanding, see:
- `README.md` - Full documentation
- `DOCKER_ARCHITECTURE.md` - Technical deep dive
- `Dockerfile` - Multi-stage build implementation

