# 🚀 REACTORS Deployment Guide

Complete guide to deploy REACTORS on Render.com + Supabase.

## 📋 Prerequisites

- GitHub account
- Render.com account (free tier)
- Supabase account (free tier)

## 🎯 Architecture

```
REACTORS (Render.com)
├── Frontend: Next.js (served at /)
├── Backend: Django API (served at /api/)
├── Admin: Django Admin (served at /admin/)
└── Database: Supabase PostgreSQL
```

---

## 🗄️ STEP 1: Setup Supabase Database

### 1.1 Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Click **"New Project"**
3. Enter project details:
   - **Name**: `reactors-db`
   - **Database Password**: (save this!)
   - **Region**: Choose closest to you
4. Click **"Create new project"**
5. Wait 2-3 minutes for setup

### 1.2 Deploy Database Schema

1. In Supabase Dashboard, go to **SQL Editor**
2. Click **"New Query"**
3. Copy entire content from `supabase/schema.sql`
4. Paste into SQL Editor
5. Click **"Run"** (or Ctrl+Enter)
6. Verify success: Should see "Success. No rows returned"

### 1.3 Get Connection Details

1. Go to **Settings** → **Database**
2. Under **Connection string**, find **Connection pooling**
3. Copy these values:
   ```
   Host: aws-0-[region].pooler.supabase.com
   Database: postgres
   Port: 5432
   User: postgres.[project-ref]
   Password: [your-password]
   ```

---

## 🚀 STEP 2: Deploy to Render.com

### 2.1 Push Code to GitHub

```bash
# Initialize git (if not already)
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit - REACTORS"

# Create GitHub repository (do this on github.com)
# Then push:
git remote add origin https://github.com/YOUR_USERNAME/REACTORS.git
git branch -M main
git push -u origin main
```

### 2.2 Create Render Web Service

1. Go to [render.com](https://render.com)
2. Click **"New +"** → **"Web Service"**
3. Click **"Build and deploy from a Git repository"**
4. Connect your GitHub account (if not connected)
5. Select **"REACTORS"** repository
6. Click **"Connect"**

### 2.3 Configure Service

**Basic Settings:**
- **Name**: `reactors`
- **Region**: Choose closest to you (e.g., Frankfurt)
- **Branch**: `main`
- **Root Directory**: `backend`
- **Runtime**: `Python 3`
- **Build Command**:
  ```bash
  pip install -r requirements.txt && python manage.py collectstatic --noinput && python manage.py migrate
  ```
- **Start Command**:
  ```bash
  gunicorn config.wsgi:application --bind 0.0.0.0:$PORT
  ```

### 2.4 Set Environment Variables

Click **"Advanced"** and add these:

```
SECRET_KEY = [click "Generate" button]
DEBUG = False
USE_POSTGRES = True
ALLOWED_HOSTS = reactors.onrender.com
CORS_ALLOWED_ORIGINS = https://reactors.onrender.com

# Supabase Database (from Step 1.3)
DB_NAME = postgres
DB_USER = postgres.[your-project-ref]
DB_PASSWORD = [your-supabase-password]
DB_HOST = aws-0-[region].pooler.supabase.com
DB_PORT = 5432
```

### 2.5 Deploy!

1. Click **"Create Web Service"**
2. Wait 5-10 minutes for first deployment
3. Watch the logs for any errors
4. Once deployed, your site will be at: `https://reactors.onrender.com`

---

## ✅ STEP 3: Verify Deployment

### 3.1 Test Backend

1. Visit: `https://reactors.onrender.com/health/`
   - Should see: `{"status": "healthy"}`

2. Visit: `https://reactors.onrender.com/api/`
   - Should see API root

3. Visit: `https://reactors.onrender.com/admin/`
   - Should see Django admin login

### 3.2 Create Superuser

In Render Dashboard:
1. Go to your service
2. Click **"Shell"** tab
3. Run:
   ```bash
   python manage.py createsuperuser
   ```
4. Follow prompts to create admin account

### 3.3 Test Admin Access

1. Visit: `https://reactors.onrender.com/admin/`
2. Login with superuser credentials
3. Verify you can see all models

---

## 🎨 STEP 4: Access Your Application

### URLs

- **API Root**: `https://reactors.onrender.com/api/`
- **Admin Panel**: `https://reactors.onrender.com/admin/`
- **API Docs**: `https://reactors.onrender.com/api/schema/swagger-ui/`
- **Health Check**: `https://reactors.onrender.com/health/`

### Test Accounts

Create test accounts via admin panel or API:
- Admin user (via createsuperuser)
- Seller accounts
- Buyer accounts

---

## 🔧 Troubleshooting

### Build Fails

**Error**: `No module named 'psycopg2'`
- **Fix**: Verify `psycopg2-binary==2.9.9` is in `requirements.txt`

**Error**: `relation "users_user" does not exist`
- **Fix**: Migrations didn't run. Check build logs.

### Database Connection Fails

**Error**: `could not connect to server`
- **Fix**: Verify Supabase connection details
- Check DB_HOST, DB_USER, DB_PASSWORD are correct
- Ensure Supabase project is not paused

### Static Files Not Loading

**Error**: 404 on CSS/JS files
- **Fix**: Run `python manage.py collectstatic --noinput` in build
- Verify `whitenoise` is installed

---

## 📊 Monitoring

### Render Dashboard

- **Logs**: Real-time application logs
- **Metrics**: CPU, Memory, Response time
- **Events**: Deployments, crashes, restarts

### Supabase Dashboard

- **Table Editor**: View/edit data
- **SQL Editor**: Run queries
- **Logs**: Database queries and errors

---

## 🔄 Updating Your Application

### Deploy Updates

```bash
# Make changes to your code
git add .
git commit -m "Your update message"
git push origin main
```

Render will automatically:
1. Detect the push
2. Run build command
3. Run migrations
4. Deploy new version
5. Zero-downtime deployment

---

## 💰 Cost Breakdown

### Free Tier Limits

**Render.com (Free)**
- ✅ 750 hours/month
- ✅ Automatic SSL
- ✅ Custom domains
- ⚠️ Spins down after 15 min inactivity
- ⚠️ 512 MB RAM

**Supabase (Free)**
- ✅ 500 MB database
- ✅ Unlimited API requests
- ✅ 50,000 monthly active users
- ✅ 1 GB file storage

**Total Monthly Cost**: $0 🎉

---

## 🚀 Next Steps

1. **Custom Domain**: Add your domain in Render settings
2. **Monitoring**: Set up error tracking (Sentry)
3. **Backups**: Enable Supabase automatic backups
4. **Scaling**: Upgrade to paid tier when needed

---

## 📞 Support

- **Render Docs**: [render.com/docs](https://render.com/docs)
- **Supabase Docs**: [supabase.com/docs](https://supabase.com/docs)
- **Django Docs**: [docs.djangoproject.com](https://docs.djangoproject.com)

---

**🎉 Congratulations! REACTORS is now live!**

