# 🚀 Render.com Deployment Guide

## 📋 **Render.com Configuration**

### **Basic Settings:**
- **Name**: `RP---e-Commerce-FS`
- **Language**: `Python 3`
- **Branch**: `main`
- **Region**: `Frankfurt (EU Central)`

### **Directory & Commands:**
- **Root Directory**: `backend`
- **Build Command**: `pip install -r requirements.txt && python manage.py collectstatic --noinput`
- **Start Command**: `gunicorn config.wsgi:application`
- **Health Check Path**: `/health/`
- **Pre-Deploy Command**: `python manage.py migrate`

### **Instance Type:**
- **Free** (for testing) or **Starter ($7/month)** for production

### **Build Filters:**
- **Included Paths**: `backend/**`
- **Ignored Paths**: `frontend/**`, `supabase/**`, `docs/**`, `*.md`

## 🔧 **Environment Variables**

Copy these environment variables to Render.com:

```bash
SECRET_KEY=xxx4&f-or93il29omuzn(u&kcmynva&+2fuu9@f84728j+u=7=
DEBUG=False
ALLOWED_HOSTS=your-app-name.onrender.com
DATABASE_URL=postgresql://username:password@host:port/database
CORS_ALLOWED_ORIGINS=https://your-frontend-domain.com,https://your-app-name.onrender.com
SUPABASE_URL=your-supabase-project-url
SUPABASE_SERVICE_KEY=your-supabase-service-role-key
```

## 📝 **Step-by-Step Instructions:**

1. **Create New Web Service** on Render.com
2. **Connect GitHub Repository**: `AdhamHossamm/RP---e-Commerce-FS`
3. **Fill in the configuration** using the values above
4. **Add Environment Variables** (copy from the section above)
5. **Deploy!**

## 🎯 **After Deployment:**

Your API will be available at:
- **API Root**: `https://your-app-name.onrender.com/`
- **Health Check**: `https://your-app-name.onrender.com/health/`
- **Admin**: `https://your-app-name.onrender.com/admin/`
- **API Docs**: `https://your-app-name.onrender.com/api/schema/swagger-ui/`

## ⚠️ **Important Notes:**

1. **Database**: You'll need a PostgreSQL database. Create one on Render.com
2. **CORS**: Update `CORS_ALLOWED_ORIGINS` with your actual frontend domain
3. **Supabase**: Get your Supabase URL and service key from your Supabase dashboard
4. **Domain**: Replace `your-app-name` with your actual Render app name

## 🔗 **Next Steps:**

1. Deploy the backend to Render.com
2. Update your frontend to use the new API URL
3. Deploy your frontend to Vercel/Netlify
4. Update CORS settings with your frontend domain
