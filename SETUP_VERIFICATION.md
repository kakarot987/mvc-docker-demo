# ✅ Setup Verification Checklist

## Before Running Setup
- [ ] Docker Desktop is installed and running
- [ ] You're in the project directory: `C:\Users\YourUsername\Downloads\mvc-docker-demo`
- [ ] You have internet connection (to pull images)
- [ ] Ports 3000, 8080, 3306 are available (not in use)

## Running Setup

### Windows PowerShell
```powershell
# Run this command
.\setup.ps1

# Should see:
# ✓ Docker found
# ✓ Docker Compose found
# (building image - takes 2-3 minutes)
# ✓ Build complete
# ✓ Containers started
# Browser opens to http://localhost:3000
```

### Windows Command Prompt
```cmd
setup.bat
# Same flow as above
```

### Linux/Mac
```bash
chmod +x setup.sh
./setup.sh
# Same flow as above
```

## After Setup Completes

- [ ] Browser opened automatically to http://localhost:3000
- [ ] React UI visible with "MVC Docker Demo" header
- [ ] Users table showing sample users (John, Jane, etc.)

## Verify All Services

### Option 1: Docker Desktop
- [ ] Open Docker Desktop
- [ ] Go to "Containers"
- [ ] Should see 3 containers:
  - `mvc-mysql-dev` (running)
  - `mvc-app-dev` (running)
  - `mvc-ui-dev` (running)

### Option 2: Command Line
```bash
docker-compose ps
```
Should output:
```
NAME              STATUS
mvc-mysql-dev     running (healthy)
mvc-app-dev       running
mvc-ui-dev        running
```

## Verify Frontend Works

### Create a New User
1. Click "➕ Add New User" button
2. Fill in the form:
   - Name: "Test User"
   - Email: "test@example.com"
   - Phone: "1234567890"
   - Address: "123 Test Street"
3. Click "➕ Create User"
4. [ ] New user appears in the table

### Edit a User
1. Click "✏️ Edit" on any user
2. Change the name to something different
3. Click "💾 Update User"
4. [ ] Table updates with new name

### Delete a User
1. Click "🗑️ Delete" on any user
2. Confirm deletion
3. [ ] User disappears from table

## Verify Backend API

### Test with curl (Windows - PowerShell, Mac/Linux - Terminal)
```bash
# Get all users
curl http://localhost:8080/users

# Should return:
# [{"id":1,"name":"John",...}, {"id":2,"name":"Jane",...}, ...]
```

## Verify Database

### Check database data
```bash
# Open MySQL shell
docker-compose exec mysql-db mysql -u user -p userdb
# When prompted for password, type: userpassword

# View users
SELECT * FROM user;

# Should show same users as React UI
# Type "exit" to leave
```

## Verify Health Checks

```bash
# API Health
curl http://localhost:8080/actuator/health
# Should return: {"status":"UP"}

# Docker Compose Health
docker-compose ps
# All containers should show as "running" or "healthy"
```

## Verify Logs

```bash
# All logs
docker-compose logs

# Should show:
# - MySQL: "ready for connections"
# - Spring Boot: "Tomcat started on port 8080"
# - React: "nginx started" (approximately)
```

## Network Verification

```bash
# Check Docker network
docker network ls
# Should include "app-network"

# Inspect network
docker network inspect app-network
# Should show 3 containers connected
```

## Common Issues & Solutions

### ❌ "Port 3000 already in use"
```bash
lsof -i :3000  # Mac/Linux
netstat -ano | findstr :3000  # Windows
# Kill the process and restart
docker-compose restart
```

### ❌ "Cannot connect to Docker daemon"
- Ensure Docker Desktop is running
- Restart Docker Desktop

### ❌ Blank page on frontend
```bash
docker-compose logs frontend
# Look for errors, likely nginx or build issue
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

### ❌ API returns errors
```bash
docker-compose logs user-service
# Look for database connection issues
docker-compose logs mysql-db
# Check if database is healthy
```

### ❌ "User not found" errors
```bash
# Database might not be initialized
docker-compose down -v
docker-compose up -d
# Wait 30 seconds for DB to initialize
```

## Performance Verification

- [ ] Frontend loads in <3 seconds
- [ ] Creating user takes <2 seconds
- [ ] Editing user takes <2 seconds
- [ ] Deleting user takes <1 second
- [ ] No error messages in console
- [ ] No errors in Docker logs

## Size Verification

```bash
docker images | grep mvc
# Should show:
# mvc-docker-demo_frontend    ~50-100MB
# mvc-docker-demo_user-service ~350-400MB
# mysql:8                      ~500MB
```

## Full Project Structure Verification

```
mvc-docker-demo/
├── ✓ Dockerfile (backend multi-stage)
├── ✓ docker-compose.yml
├── ✓ docker-compose.prod.yml
├── ✓ setup.ps1
├── ✓ setup.bat
├── ✓ setup.sh
├── ✓ README.md (updated)
├── ✓ FRONTEND_IMPLEMENTATION.md
├── ✓ FULL_STACK_GUIDE.md
├── ✓ frontend/
│   ├── ✓ Dockerfile (frontend multi-stage)
│   ├── ✓ nginx.conf
│   ├── ✓ package.json
│   ├── ✓ .env
│   ├── ✓ .dockerignore
│   ├── ✓ .gitignore
│   ├── ✓ README.md
│   ├── ✓ public/
│   │   └── ✓ index.html
│   └── ✓ src/
│       ├── ✓ App.js
│       ├── ✓ App.css
│       ├── ✓ index.js
│       ├── ✓ index.css
│       ├── ✓ components/
│       │   ├── ✓ UserList.js
│       │   └── ✓ UserForm.js
│       └── ✓ services/
│           └── ✓ userService.js
└── ✓ src/main/ (backend - unchanged)
```

## ✅ Final Checklist

When all of the above are verified:

- [ ] Frontend loads (React UI visible)
- [ ] Can create users
- [ ] Can edit users
- [ ] Can delete users
- [ ] Backend API responds
- [ ] Database contains correct data
- [ ] All 3 containers running
- [ ] No errors in logs
- [ ] Appropriate image sizes

## 🎉 You're All Set!

If all checkboxes are checked, your full-stack Docker application is working perfectly!

### Next: Show Off Your Project

1. **Portfolio**: Push to GitHub
2. **Interviews**: Demo the app
3. **Resume**: Mention as "Full-stack Docker project"
4. **Learning**: Explore the code
5. **Improvements**: Extend with features

---

**Start Date**: Today  
**Status**: ✅ Complete  
**Ready for Portfolio**: ✅ YES  

Good luck! 🚀

