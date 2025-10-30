# 🚀 Supabase Quick Start Guide

## 📋 Overview

This guide will connect your Django backend to Supabase PostgreSQL in 5 minutes.

## ⚡ Quick Setup (5 Steps)

### Step 1: Get Database Password

1. Go to: https://supabase.com/dashboard/project/mbwyjrfnbjeseslcveyb/settings/database
2. Scroll to **Connection String** → **URI**
3. Copy the password (or reset if needed)

### Step 2: Update `.env` File

Edit `backend/.env`:

```env
DB_PASSWORD=YOUR_ACTUAL_PASSWORD_HERE
```

Replace `YOUR_ACTUAL_PASSWORD_HERE` with the password from Step 1.

### Step 3: Test Connection (SQL)

In Supabase SQL Editor:
1. Go to: https://supabase.com/dashboard/project/mbwyjrfnbjeseslcveyb/sql
2. Click **New Query**
3. Copy & paste contents of `supabase/test-basic.sql`
4. Click **Run**

**Expected Result:**
```
✅ Connection Test: SUCCESS
⚠️  Django Not Ready: Run: python manage.py migrate
```

### Step 4: Run Django Migrations

```bash
cd backend
python manage.py migrate
```

**Expected Output:**
```
Running migrations:
  Applying contenttypes.0001_initial... OK
  Applying users.0001_initial... OK
  Applying products.0001_initial... OK
  ...
```

### Step 5: Verify Connection (Django)

```bash
python manage.py test_db_connection
```

**Expected Output:**
```
============================================================
  DATABASE CONNECTION & SCHEMA TEST
============================================================

[TEST 1] Testing database connection...
[OK] Connected to database
     Host: aws-0-us-east-1.pooler.supabase.com

[TEST 7] Testing CRUD operations...
[OK] CREATE operation successful
[OK] READ operation successful
[OK] UPDATE operation successful
[OK] DELETE operation successful

============================================================
  ALL TESTS COMPLETED SUCCESSFULLY!
============================================================
```

## ✅ You're Done!

Your Django app is now connected to Supabase PostgreSQL!

## 🎯 Next Steps

### Add Demo Data

```bash
python manage.py setup_demo_data
```

Creates:
- 3 users (admin, seller, buyer)
- 4 categories
- 6 products with images

### Start Development Server

```bash
# Backend
cd backend
python manage.py runserver

# Frontend (new terminal)
cd frontend
npm run dev
```

### Access Your App

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000/api/
- **Django Admin**: http://localhost:8000/admin
- **Swagger Docs**: http://localhost:8000/api/schema/swagger-ui/
- **Supabase Dashboard**: https://supabase.com/dashboard/project/mbwyjrfnbjeseslcveyb

## 📊 Connection Details

### Database Configuration

```
Host: aws-0-us-east-1.pooler.supabase.com
Port: 6543 (Connection Pooler)
Database: postgres
User: postgres.mbwyjrfnbjeseslcveyb
Password: [Your Password]
SSL: Required
```

### Connection String

```
postgresql://postgres.mbwyjrfnbjeseslcveyb:[PASSWORD]@aws-0-us-east-1.pooler.supabase.com:6543/postgres
```

## 🔧 Troubleshooting

### Problem: "Connection refused"

**Solution 1**: Check your password
```bash
# In backend/.env, ensure DB_PASSWORD is set correctly
DB_PASSWORD=your_actual_password_here
```

**Solution 2**: Try direct connection (not pooler)
```env
DB_HOST=db.mbwyjrfnbjeseslcveyb.supabase.co
DB_PORT=5432
```

### Problem: "SSL required"

Already configured in `settings.py`:
```python
'OPTIONS': {
    'sslmode': 'require',
}
```

### Problem: "Authentication failed"

1. Reset password in Supabase Dashboard
2. Update `backend/.env`
3. Restart Django server

### Problem: Django uses SQLite instead of PostgreSQL

This happens when `DB_PASSWORD` is not set.

**Check current database:**
```bash
python manage.py shell
>>> from django.db import connection
>>> print(connection.settings_dict['ENGINE'])
# Should show: django.db.backends.postgresql
```

**Fix:** Set `DB_PASSWORD` in `backend/.env`

## 📁 Test Scripts Reference

| File | Purpose | When to Use |
|------|---------|-------------|
| `test-basic.sql` | Basic connection test | Before Django migrations |
| `test-connection-simple.sql` | Simple table check | After Django migrations |
| `test-alignment.sql` | Full schema validation | For detailed debugging |

## 🎓 Learn More

### View Tables in Supabase

1. Go to **Table Editor**: https://supabase.com/dashboard/project/mbwyjrfnbjeseslcveyb/editor
2. You'll see all Django tables:
   - `users_user`
   - `products_product`
   - `products_category`
   - `orders_order`
   - etc.

### Query Data Directly

In Supabase SQL Editor:

```sql
-- View all products
SELECT * FROM products_product;

-- View all users
SELECT username, email, role FROM users_user;

-- View orders with user info
SELECT 
    o.order_number,
    u.username,
    o.total,
    o.status
FROM orders_order o
JOIN users_user u ON o.user_id = u.id
ORDER BY o.created_at DESC;
```

### Check Migration Status

```bash
python manage.py showmigrations
```

Shows which migrations have been applied.

## 🔐 Security Notes

1. **Never commit `.env` files** - Already in `.gitignore`
2. **Rotate passwords quarterly** - Set reminder in Supabase
3. **Use environment variables** - Never hardcode credentials
4. **Enable RLS** - Run `supabase/schema.sql` for Row Level Security

## 📞 Support

### Django Connection Issues
```bash
python manage.py test_db_connection --verbose
```

### Supabase Issues
- Check logs: https://supabase.com/dashboard/project/mbwyjrfnbjeseslcveyb/logs
- Check status: https://status.supabase.com/

### Test Direct Connection
```bash
# Install psql if needed
psql "postgresql://postgres.mbwyjrfnbjeseslcveyb:[PASSWORD]@aws-0-us-east-1.pooler.supabase.com:6543/postgres"
```

## ✨ Success Checklist

- [ ] Database password obtained
- [ ] `backend/.env` updated
- [ ] `test-basic.sql` runs successfully
- [ ] `python manage.py migrate` completed
- [ ] `python manage.py test_db_connection` passes
- [ ] Demo data created
- [ ] Tables visible in Supabase Table Editor
- [ ] Django server starts without errors
- [ ] API endpoints accessible

---

**🎉 Congratulations! Your Django app is now powered by Supabase PostgreSQL!**

