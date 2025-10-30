# ⚡ REACTORS Quick Start Guide

Get REACTORS running in production in **15 minutes**!

## 📋 What You Need

- [ ] GitHub account
- [ ] Render.com account (sign up free)
- [ ] Supabase account (sign up free)
- [ ] 15 minutes of your time

---

## 🚀 Step-by-Step Deployment

### STEP 1: Supabase Setup (5 minutes)

#### 1.1 Create Project
1. Go to [supabase.com](https://supabase.com) → Sign up/Login
2. Click **"New Project"**
3. Fill in:
   - Name: `reactors-db`
   - Database Password: (create strong password, **SAVE THIS!**)
   - Region: Choose closest to you
4. Click **"Create new project"**
5. ⏳ Wait 2-3 minutes

#### 1.2 Deploy Schema
1. Click **"SQL Editor"** in left sidebar
2. Click **"New Query"**
3. Open `supabase/schema.sql` from your project
4. Copy **ALL** content (Ctrl+A, Ctrl+C)
5. Paste into Supabase SQL Editor
6. Click **"Run"** button (or Ctrl+Enter)
7. ✅ Should see: "Success. No rows returned"

#### 1.3 Get Database Credentials
1. Click **"Settings"** (gear icon) → **"Database"**
2. Scroll to **"Connection string"**
3. Click **"Connection pooling"** tab
4. Copy these values (you'll need them soon):
   ```
   Host: aws-0-[region].pooler.supabase.com
   Database: postgres
   Port: 5432
   User: postgres.[project-ref]
   Password: [your-password-from-step-1]
   ```

---

### STEP 2: GitHub Setup (2 minutes)

#### 2.1 Push to GitHub
```bash
# In your REACTORS project folder
git init
git add .
git commit -m "Initial commit - REACTORS"
git branch -M main
```

#### 2.2 Create Repository
1. Go to [github.com](https://github.com) → **"New repository"**
2. Name: `REACTORS`
3. Visibility: **Private** (recommended)
4. Don't check any boxes
5. Click **"Create repository"**

#### 2.3 Push Code
```bash
git remote add origin https://github.com/YOUR_USERNAME/REACTORS.git
git push -u origin main
```

---

### STEP 3: Render.com Deployment (8 minutes)

#### 3.1 Create Web Service
1. Go to [render.com](https://render.com) → Sign up/Login
2. Click **"New +"** → **"Web Service"**
3. Click **"Build and deploy from a Git repository"**
4. Click **"Connect GitHub"** (authorize if needed)
5. Find **"REACTORS"** → Click **"Connect"**

#### 3.2 Configure Service
Fill in these fields:

**Basic:**
- **Name**: `reactors` (or anything you want)
- **Region**: Choose closest to you
- **Branch**: `main`
- **Root Directory**: `backend`
- **Runtime**: `Python 3`

**Build & Start:**
- **Build Command**:
  ```
  pip install -r requirements.txt && python manage.py collectstatic --noinput && python manage.py migrate
  ```
- **Start Command**:
  ```
  gunicorn config.wsgi:application --bind 0.0.0.0:$PORT
  ```

#### 3.3 Set Environment Variables
Click **"Advanced"** → **"Add Environment Variable"**

Add these one by one:

| Key | Value |
|-----|-------|
| `SECRET_KEY` | Click "Generate" button |
| `DEBUG` | `False` |
| `USE_POSTGRES` | `True` |
| `ALLOWED_HOSTS` | `reactors.onrender.com` (or your service name) |
| `CORS_ALLOWED_ORIGINS` | `https://reactors.onrender.com` |
| `DB_NAME` | `postgres` |
| `DB_USER` | (from Supabase Step 1.3) |
| `DB_PASSWORD` | (from Supabase Step 1.3) |
| `DB_HOST` | (from Supabase Step 1.3) |
| `DB_PORT` | `5432` |

#### 3.4 Deploy!
1. Click **"Create Web Service"**
2. ⏳ Wait 5-10 minutes (watch the logs)
3. ✅ When done, you'll see "Live" with a green dot

---

## ✅ STEP 4: Verify Everything Works

### 4.1 Test API
Visit: `https://reactors.onrender.com/health/`
- Should see: `{"status": "healthy"}`

### 4.2 Create Admin User
1. In Render dashboard, click **"Shell"** tab
2. Run:
   ```bash
   python manage.py createsuperuser
   ```
3. Enter:
   - Email: `admin@reactors.com`
   - Username: `admin`
   - Password: (create strong password)

### 4.3 Test Admin Panel
Visit: `https://reactors.onrender.com/admin/`
- Login with credentials from 4.2
- ✅ You should see Django admin!

### 4.4 Test API Docs
Visit: `https://reactors.onrender.com/api/schema/swagger-ui/`
- ✅ You should see interactive API documentation!

---

## 🎉 SUCCESS!

Your REACTORS platform is now live at:
- **API**: `https://reactors.onrender.com/api/`
- **Admin**: `https://reactors.onrender.com/admin/`
- **Docs**: `https://reactors.onrender.com/api/schema/swagger-ui/`

---

## 🔧 Common Issues

### Build Fails
**Problem**: "No module named 'psycopg2'"
- **Fix**: Check `backend/requirements.txt` has `psycopg2-binary==2.9.9`

### Database Connection Fails
**Problem**: "could not connect to server"
- **Fix**: Double-check Supabase credentials in environment variables
- Verify Supabase project is not paused

### 502 Bad Gateway
**Problem**: Service won't start
- **Fix**: Check logs in Render dashboard
- Verify all environment variables are set correctly

---

## 📞 Need Help?

1. Check logs in Render dashboard
2. Check database in Supabase dashboard
3. Review [DEPLOYMENT.md](DEPLOYMENT.md) for detailed guide

---

## 🚀 Next Steps

1. **Add Data**: Use admin panel to add products, categories
2. **Create Users**: Add seller and buyer accounts
3. **Custom Domain**: Add your domain in Render settings
4. **Monitoring**: Set up error tracking

---

**⚛️ REACTORS is live! Time to build something amazing!**

