# 🔧 Render.com Environment Variables Template

## Copy these EXACT values to Render.com Environment Variables section:

### **Required Variables:**

```
SECRET_KEY=xxx4&f-or93il29omuzn(u&kcmynva&+2fuu9@f84728j+u=7=
```

```
DEBUG=False
```

```
ALLOWED_HOSTS=your-app-name.onrender.com
```
*Replace `your-app-name` with your actual Render app name*

```
DATABASE_URL=postgresql://username:password@host:port/database
```
*Get this from your Render PostgreSQL database*

```
CORS_ALLOWED_ORIGINS=https://your-frontend-domain.com,https://your-app-name.onrender.com
```
*Replace with your actual frontend domain*

```
SUPABASE_URL=https://your-project-id.supabase.co
```
*Get from your Supabase dashboard*

```
SUPABASE_SERVICE_KEY=your-service-role-key-here
```
*Get from your Supabase dashboard (service_role key)*

## 📋 **How to Add Environment Variables:**

1. In Render.com dashboard, go to your service
2. Click on "Environment" tab
3. Click "Add Environment Variable"
4. For each variable above:
   - **Name**: Copy the variable name (left side)
   - **Value**: Copy the value (right side)
   - Click "Save Changes"

## ⚠️ **Important:**

- Replace placeholder values with your actual values
- Keep the SECRET_KEY exactly as shown (it's already generated securely)
- Make sure DEBUG is set to False for production
- Update ALLOWED_HOSTS with your actual Render app URL
