# Supabase Connection Troubleshooting

## 🔴 Current Issue

**Error**: `FATAL: Tenant or user not found` or `could not translate host name`

**Root Cause**: The connection string format or credentials may be incorrect.

## ✅ Solution: Get Correct Connection String

### Step 1: Get Connection String from Supabase

1. Go to: https://supabase.com/dashboard/project/mbwyjrfnbjeseslcveyb/settings/database
2. Look for **Connection string** section
3. Select **URI** tab
4. You'll see something like:

```
postgresql://postgres.mbwyjrfnbjeseslcveyb:[YOUR-PASSWORD]@aws-0-us-east-1.pooler.supabase.com:6543/postgres
```

### Step 2: Parse the Connection String

From the URI, extract:
- **User**: `postgres.mbwyjrfnbjeseslcveyb` (before the `:` and `@`)
- **Password**: Your password (between `:[` and `]@`)
- **Host**: The domain after `@` (e.g., `aws-0-us-east-1.pooler.supabase.com`)
- **Port**: The number after `:` (e.g., `6543` for pooler, `5432` for direct)
- **Database**: `postgres` (after the last `/`)

### Step 3: Update `.env` File

Edit `backend/.env`:

```env
DB_NAME=postgres
DB_USER=postgres.mbwyjrfnbjeseslcveyb
DB_PASSWORD=9_mb!U4yD3RXkJY
DB_HOST=aws-0-us-east-1.pooler.supabase.com
DB_PORT=6543
```

**Important**: Make sure there are NO spaces around the `=` sign!

## 🔧 Alternative: Use Session Mode

If Transaction mode (port 6543) doesn't work, try Session mode:

```env
DB_PORT=5432
```

Or use the direct connection string format in Supabase dashboard under **Session mode**.

## 🧪 Test Connection

### Option 1: Using psql (if installed)

```bash
psql "postgresql://postgres.mbwyjrfnbjeseslcveyb:9_mb!U4yD3RXkJY@aws-0-us-east-1.pooler.supabase.com:6543/postgres"
```

If this works, Django should work too.

### Option 2: Using Python

Create `test_connection.py`:

```python
import psycopg2

try:
    conn = psycopg2.connect(
        dbname="postgres",
        user="postgres.mbwyjrfnbjeseslcveyb",
        password="9_mb!U4yD3RXkJY",
        host="aws-0-us-east-1.pooler.supabase.com",
        port="6543",
        sslmode="require"
    )
    print("✅ Connection successful!")
    conn.close()
except Exception as e:
    print(f"❌ Connection failed: {e}")
```

Run: `python test_connection.py`

## 🚨 Common Issues

### Issue 1: Wrong Password Format

**Problem**: Password contains special characters that need escaping.

**Solution**: If your password has special chars like `!`, `@`, `#`, wrap it in quotes or URL-encode it.

### Issue 2: IPv6 vs IPv4

**Problem**: Your network might not support IPv6.

**Solution**: Use the IPv4 address directly:

```bash
# Get IP address
nslookup aws-0-us-east-1.pooler.supabase.com
```

Then use the IP in `DB_HOST`.

### Issue 3: Firewall/Network Blocking

**Problem**: Corporate firewall blocks port 6543 or 5432.

**Solution**: 
- Try from a different network
- Use VPN
- Contact IT to whitelist Supabase IPs

### Issue 4: Project Paused

**Problem**: Supabase free tier projects pause after inactivity.

**Solution**: 
1. Go to: https://supabase.com/dashboard/project/mbwyjrfnbjeseslcveyb
2. Check if project shows "Paused"
3. Click "Resume" if needed

## ✅ Recommended: Use SQLite for Local Development

For now, keep using SQLite locally and use Supabase PostgreSQL only in production:

```env
# backend/.env
DB_NAME=
DB_USER=
DB_PASSWORD=
DB_HOST=
DB_PORT=
```

This will automatically use SQLite (already configured in `settings.py`).

## 📊 Next Steps

1. **Verify Supabase project is active**
2. **Get exact connection string from dashboard**
3. **Test connection with psql or Python script**
4. **Update Django `.env` with correct values**
5. **Run migrations**: `python manage.py migrate`
6. **Test**: `python manage.py test_db_connection`

## 🎯 For Production

When deploying to production:
1. Use environment variables (not `.env` files)
2. Use Supabase connection pooler (port 6543)
3. Enable SSL/TLS (already configured)
4. Set up connection pooling in Django
5. Monitor connection pool usage

---

**Current Status**: Using SQLite locally ✅  
**Next Goal**: Connect to Supabase PostgreSQL for production deployment

