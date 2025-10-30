# 🐳 Docker Setup Guide

This guide will help you run the E-Commerce platform using Docker. Perfect for sharing with friends or ensuring a consistent environment across different machines.

## Prerequisites

- **Docker Desktop** installed on your system
  - Download from: https://www.docker.com/products/docker-desktop/
- **No Python or Node.js required** - Docker handles everything!

## Quick Start

### 1. Navigate to Project Directory

```bash
cd "D:\Hany Project\RP---e-Commerce-FS"
```

### 2. Build and Start All Services

```bash
docker-compose up --build
```

That's it! 🎉 The first time will take a few minutes to build the Docker images and download dependencies.

## What Happens Automatically

When you run `docker-compose up --build`:

1. ✅ **Backend** builds and starts on port 8000
2. ✅ **Frontend** builds and starts on port 3000
3. ✅ **Database** migrations run automatically
4. ✅ **Test accounts** are created automatically
5. ✅ **All services** are ready to use

## Access Points

Once the containers are running, access the application at:

- **Frontend:** http://localhost:3000
- **Backend API:** http://localhost:8000
- **Admin Panel:** http://localhost:8000/admin/
- **API Documentation:** http://localhost:8000/api/schema/swagger-ui/

## Test Accounts (Auto-Created)

Use these accounts to test different user roles:

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@example.com | admin |
| Superuser | superuser@example.com | superuser |
| Seller | seller@example.com | seller123 |
| Buyer | buyer@example.com | buyer123 |

## Stopping the Application

### Stop Containers (Data Preserved)

```bash
docker-compose down
```

### Stop and Remove All Data

```bash
docker-compose down -v
```

⚠️ **Warning:** This will delete your database and uploaded files!

## Running in Background

To run containers in the background (detached mode):

```bash
docker-compose up -d --build
```

View logs:

```bash
# All services
docker-compose logs -f

# Backend only
docker-compose logs -f backend

# Frontend only
docker-compose logs -f frontend
```

## Data Persistence

Your data is stored in Docker volumes:

- **Database:** `backend_db` volume (SQLite file)
- **Media files:** `backend_media` volume (uploaded images)
- **Code changes:** Auto-synced from your local files (hot reload enabled)

## Development Workflow

### Making Changes

1. **Edit files locally** - Changes are automatically synced to containers
2. **Code reloads automatically** - No need to restart!
3. **For database changes:**
   ```bash
   docker-compose exec backend python manage.py makemigrations
   docker-compose exec backend python manage.py migrate
   ```

### Installing New Dependencies

**Backend:**
```bash
# Edit backend/requirements.txt
# Then rebuild
docker-compose up --build
```

**Frontend:**
```bash
# Edit frontend/package.json
# Then rebuild
docker-compose up --build
```

### Running Django Commands

```bash
# Create superuser
docker-compose exec backend python manage.py createsuperuser

# Run tests
docker-compose exec backend python manage.py test

# Access Django shell
docker-compose exec backend python manage.py shell
```

### Running Frontend Commands

```bash
# Install new package
docker-compose exec frontend npm install <package-name>

# Run linter
docker-compose exec frontend npm run lint
```

## Sharing with Friends

### What to Share

Simply zip the entire project folder and send it to your friend:

```
RP---e-Commerce-FS.zip
├── backend/
├── frontend/
├── docker-compose.yml
└── ... (all project files)
```

### What Your Friend Needs to Do

1. **Install Docker Desktop**
2. **Extract the project**
3. **Open terminal in project folder**
4. **Run:** `docker-compose up --build`
5. **Done!** 🎉

## Troubleshooting

### Containers Won't Start

```bash
# Check what went wrong
docker-compose logs

# Rebuild from scratch
docker-compose down -v
docker-compose up --build
```

### Port Already in Use

Edit `docker-compose.yml` and change the port mappings:

```yaml
backend:
  ports:
    - "8001:8000"  # Changed from 8000:8000

frontend:
  ports:
    - "3001:3000"  # Changed from 3000:3000
```

### Clear Everything and Start Fresh

```bash
# Stop and remove everything
docker-compose down -v

# Remove all images
docker system prune -a

# Start fresh
docker-compose up --build
```

### Database Reset

```bash
# Stop containers
docker-compose down

# Remove database volume
docker volume rm rp---e-commerce-fs_backend_db

# Start again (will recreate database)
docker-compose up --build
```

## Project Structure

```
RP---e-Commerce-FS/
├── docker-compose.yml      # Docker configuration
├── backend/
│   ├── Dockerfile          # Backend container definition
│   ├── .dockerignore       # Files to exclude from build
│   └── ...
├── frontend/
│   ├── Dockerfile          # Frontend container definition
│   ├── .dockerignore       # Files to exclude from build
│   └── ...
└── DOCKER-SETUP.md         # This file
```

## Environment Variables

All environment variables are configured in `docker-compose.yml`. You can customize them there.

## Production Deployment

For production deployment, consider:

1. **Using PostgreSQL** instead of SQLite
2. **Setting strong SECRET_KEY**
3. **Using environment files** for sensitive data
4. **Setting DEBUG=False**
5. **Using reverse proxy** (Nginx)
6. **Enabling HTTPS**

## Support

If you encounter any issues:

1. Check the logs: `docker-compose logs`
2. Verify Docker is running: `docker ps`
3. Try rebuilding: `docker-compose up --build`
4. Check this guide for common solutions

---

**Built with ❤️ using Docker and modern full-stack technologies**

