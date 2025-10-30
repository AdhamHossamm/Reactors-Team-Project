# Supabase PostgreSQL Setup Guide

## 🎯 Objective

Connect Django backend to Supabase PostgreSQL and verify schema alignment.

## 📋 Prerequisites

1. Supabase project created: `mbwyjrfnbjeseslcveyb`
2. Database password (get from Supabase Dashboard)
3. Python packages installed: `psycopg2-binary`, `python-dotenv`

## 🚀 Step-by-Step Setup

### Step 1: Get Your Database Password

1. Go to: https://supabase.com/dashboard/project/mbwyjrfnbjeseslcveyb/settings/database
2. Scroll to **Connection String** section
3. Click **Reset Database Password** (if needed)
4. Copy the password (it will look like a long random string)
5. **Save it securely!**

### Step 2: Update Backend Environment Variables

Edit `backend/.env` and replace `YOUR_SUPABASE_DB_PASSWORD_HERE` with your actual password:

```env
# Database Configuration (Supabase PostgreSQL)
DB_NAME=postgres
DB_USER=postgres.mbwyjrfnbjeseslcveyb
DB_PASSWORD=your_actual_password_here
DB_HOST=aws-0-us-east-1.pooler.supabase.com
DB_PORT=6543
```

### Step 3: Test Database Connection

Run the Django management command:

```bash
cd backend
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
     Database: postgres
     User: postgres.mbwyjrfnbjeseslcveyb

[TEST 2] Checking database information...
[OK] Database size: 8192 kB
[OK] Schemas found: public, auth, storage
[OK] Tables in public schema: 0

[TEST 3] Verifying Django tables exist...
[FAIL] Missing tables: users_user, products_category, ...

Run: python manage.py migrate
```

### Step 4: Run Django Migrations

If tables are missing, run migrations:

```bash
python manage.py migrate
```

This will create all Django tables in your Supabase PostgreSQL database.

### Step 5: Re-test Connection

```bash
python manage.py test_db_connection --verbose
```

**Expected Output:**
```
============================================================
  ALL TESTS COMPLETED SUCCESSFULLY!
============================================================
```

### Step 6: Run SQL Alignment Test (Optional)

In Supabase SQL Editor:

1. Go to: https://supabase.com/dashboard/project/mbwyjrfnbjeseslcveyb/sql
2. Click **New Query**
3. Copy contents of `supabase/test-alignment.sql`
4. Paste and click **Run**

This will show:
- ✓ All tables present
- ✓ Foreign keys configured
- ✓ Indexes created
- ✓ Data types compatible

### Step 7: Create Demo Data

```bash
python manage.py setup_demo_data
```

This creates:
- 3 demo users (admin, seller, buyer)
- 4 categories
- 6 products with images

### Step 8: Verify in Supabase Dashboard

1. Go to **Table Editor**: https://supabase.com/dashboard/project/mbwyjrfnbjeseslcveyb/editor
2. You should see tables like:
   - `users_user`
   - `products_product`
   - `products_category`
   - `orders_order`
   - etc.

## 🔧 Troubleshooting

### Issue: Connection Refused

**Error:**
```
could not connect to server: Connection refused
```

**Solution:**
- Check if your IP is allowed in Supabase
- Go to: Settings → Database → Connection Pooling
- Ensure "Connection Pooling" is enabled
- Try using the direct connection (port 5432) instead of pooler (port 6543)

**Update `.env`:**
```env
DB_HOST=db.mbwyjrfnbjeseslcveyb.supabase.co
DB_PORT=5432
```

### Issue: Authentication Failed

**Error:**
```
FATAL: password authentication failed for user "postgres.mbwyjrfnbjeseslcveyb"
```

**Solution:**
- Reset your database password in Supabase Dashboard
- Update `DB_PASSWORD` in `backend/.env`
- Ensure no extra spaces in the password

### Issue: SSL Required

**Error:**
```
SSL connection is required
```

**Solution:**
Already configured in `settings.py`:
```python
'OPTIONS': {
    'sslmode': 'require',
}
```

### Issue: Tables Already Exist

**Error:**
```
relation "users_user" already exists
```

**Solution:**
This means tables are already created. You can:
1. Skip migrations
2. Or reset database (⚠️ deletes all data):

```sql
-- In Supabase SQL Editor
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
```

Then run migrations again.

### Issue: Fallback to SQLite

If Django uses SQLite instead of PostgreSQL, it means `DB_PASSWORD` is not set.

**Check:**
```bash
python manage.py shell
>>> from django.db import connection
>>> print(connection.settings_dict)
```

Should show PostgreSQL, not SQLite.

## 📊 Connection Strings Reference

### Pooler Connection (Recommended for Django)
```
Host: aws-0-us-east-1.pooler.supabase.com
Port: 6543
Database: postgres
User: postgres.mbwyjrfnbjeseslcveyb
```

### Direct Connection (Alternative)
```
Host: db.mbwyjrfnbjeseslcveyb.supabase.co
Port: 5432
Database: postgres
User: postgres.mbwyjrfnbjeseslcveyb
```

### Connection String Format
```
postgresql://postgres.mbwyjrfnbjeseslcveyb:[PASSWORD]@aws-0-us-east-1.pooler.supabase.com:6543/postgres
```

## ✅ Verification Checklist

- [ ] Database password obtained and saved
- [ ] `backend/.env` updated with correct credentials
- [ ] `python manage.py test_db_connection` passes all tests
- [ ] Django migrations applied successfully
- [ ] Demo data created
- [ ] Tables visible in Supabase Table Editor
- [ ] SQL alignment test passes (optional)
- [ ] Django admin accessible at http://localhost:8000/admin
- [ ] API endpoints working at http://localhost:8000/api/

## 🎯 Next Steps

Once connected:

1. **Enable Row Level Security (RLS)**
   - Run `supabase/schema.sql` to add RLS policies
   - Secure your data at the database level

2. **Set up Supabase Auth Integration**
   - Sync Django users with Supabase auth
   - Enable social logins

3. **Deploy Edge Functions**
   - Real-time notifications
   - Analytics tracking
   - Webhook handlers

4. **Configure Backups**
   - Supabase provides automatic daily backups
   - Set up point-in-time recovery

## 📚 Resources

- [Supabase Dashboard](https://supabase.com/dashboard/project/mbwyjrfnbjeseslcveyb)
- [Django Database Settings](https://docs.djangoproject.com/en/5.0/ref/settings/#databases)
- [psycopg2 Documentation](https://www.psycopg.org/docs/)
- [Supabase Python Client](https://supabase.com/docs/reference/python/introduction)

## 🆘 Support

If you encounter issues:

1. Check Django logs: `python manage.py runserver` output
2. Check Supabase logs: Dashboard → Logs
3. Test connection directly:
   ```bash
   psql "postgresql://postgres.mbwyjrfnbjeseslcveyb:[PASSWORD]@aws-0-us-east-1.pooler.supabase.com:6543/postgres"
   ```

---

**✨ Once setup is complete, your Django app will be using Supabase PostgreSQL as its database!**

