# Database-Codebase Alignment Test Guide

## Overview
The `test-codebase-alignment.sql` script comprehensively tests whether your Supabase PostgreSQL database is properly aligned with your Django models.

## How to Run

### Option 1: Supabase Dashboard (Recommended)
1. Open your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Click **New Query**
4. Copy and paste the entire contents of `test-codebase-alignment.sql`
5. Click **Run** or press `Ctrl+Enter`

### Option 2: psql Command Line
```bash
psql -h db.your-project-ref.supabase.co -U postgres -d postgres -f test-codebase-alignment.sql
```

## What It Tests

### ✅ Test Categories

| Test # | Category | Description |
|--------|----------|-------------|
| 1 | **Database Connection** | Verifies connection, version, and database info |
| 2 | **Core Tables** | Checks all 16 expected Django tables exist |
| 3 | **Users Table** | Validates user table structure (16 columns) |
| 4 | **Products Table** | Validates product table structure (17 columns) |
| 5 | **Orders Table** | Validates order table structure (20 columns) |
| 6 | **Foreign Keys** | Verifies ~20 foreign key relationships |
| 7 | **Unique Constraints** | Checks email, username, slug, SKU uniqueness |
| 8 | **Indexes** | Validates performance indexes exist |
| 9 | **Data Types** | Ensures Django-PostgreSQL type compatibility |
| 10 | **Nullable Fields** | Validates required vs optional fields |
| 11 | **Check Constraints** | Verifies business rule constraints |
| 12 | **Row Level Security** | Shows RLS status (optional for Django) |
| 13 | **Data Samples** | Shows row counts for each table |
| 14 | **Sequences** | Verifies auto-increment sequences |

## Understanding Output

### Status Indicators

| Symbol | Meaning | Action Required |
|--------|---------|-----------------|
| ✓ PASS | Test passed | None |
| ✓ EXISTS | Item found | None |
| ○ EMPTY | Table exists but no data | Optional: add test data |
| ⚠ PARTIAL | Some items missing | Review and consider fixing |
| ⚠ MINIMAL | Below optimal but functional | Consider improvement |
| ✗ MISSING | Critical item not found | Fix required |
| ✗ FAIL | Test failed | Fix required |

### Expected Tables (16 Total)

**Users & Auth:**
- `users`

**Products:**
- `categories`
- `products`
- `product_images`
- `product_reviews`

**Orders & Cart:**
- `carts`
- `cart_items`
- `orders`
- `order_items`
- `order_status_history`

**Sellers:**
- `seller_profiles`
- `seller_payouts`

**Analytics:**
- `product_views`
- `search_queries`
- `cart_activity_logs`
- `sales_metrics`

## Sample Output

```
╔════════════════════════════════════════════════════╗
║   E-COMMERCE DATABASE ALIGNMENT TEST              ║
║   Testing Django Models vs Supabase Schema        ║
╚════════════════════════════════════════════════════╝

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TEST 2: Core Tables Existence
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

test_id | table_name            | status    | result
--------|----------------------|-----------|-------
2.1     | cart_activity_logs   | ✓ EXISTS  | PASS
2.2     | cart_items           | ✓ EXISTS  | PASS
2.3     | carts                | ✓ EXISTS  | PASS
...

╔════════════════════════════════════════════════════╗
║              FINAL TEST SUMMARY                    ║
╚════════════════════════════════════════════════════╝

┌────────────────────────────────────────────────────┐
│ Core Tables:      16 / 16                          │
│ Foreign Keys:     18                               │
│ Indexes:          45                               │
│                                                    │
│ Overall Status:                                    │
│ ✓ PASS - Database fully aligned with codebase     │
└────────────────────────────────────────────────────┘

✅ DATABASE IS PROPERLY ALIGNED WITH CODEBASE

✓ All core tables present
✓ Foreign key relationships established
✓ Indexes in place for performance

🎯 Ready for production use!
```

## Common Issues & Solutions

### Issue: Tables Missing (✗ MISSING)
**Cause:** Django migrations not run  
**Solution:**
```bash
cd backend
python manage.py makemigrations
python manage.py migrate
```

### Issue: Few Foreign Keys (⚠ PARTIAL)
**Cause:** Database created manually without Django  
**Solution:** Run Django migrations to create proper relationships

### Issue: Data Type Incompatible (⚠ Check Required)
**Cause:** Manual schema creation with wrong types  
**Solution:** Use Django migrations or alter table to match Django's expected types

### Issue: No Indexes (✗ INSUFFICIENT)
**Cause:** Indexes not created  
**Solution:** Run Django migrations which auto-create indexes defined in models

## Architecture Notes

### Django vs Supabase Tables

Your Django models use **custom `db_table` names** that differ from Django's default naming:

| Django Model | Default Django Table | Custom `db_table` |
|--------------|---------------------|-------------------|
| User | `users_user` | `users` |
| Product | `products_product` | `products` |
| Order | `orders_order` | `orders` |
| Category | `products_category` | `categories` |

This test checks for the **custom table names** that match your Django models.

### RLS (Row Level Security)

Your application uses **Django backend authentication**, not Supabase RLS. 
- ✓ RLS can be disabled (Django handles all auth)
- ○ RLS can be enabled (defense in depth)

Both approaches are valid for your architecture.

## Next Steps After Testing

1. **If All Tests Pass:**
   - Your database is properly aligned ✓
   - Safe to proceed with development
   - Consider adding test data if tables are empty

2. **If Tests Fail:**
   - Note which specific tests failed
   - Run Django migrations: `python manage.py migrate`
   - Re-run this test script
   - If issues persist, check `backend/config/settings.py` database config

3. **For Production:**
   - Ensure all tests pass before deploying
   - Add appropriate indexes if marked ⚠ MINIMAL
   - Consider enabling RLS for defense-in-depth security

## Maintenance

Re-run this test:
- After modifying Django models
- After running migrations
- Before production deployment
- When debugging database-related issues
- Monthly as part of health checks

## Support Files

- Main schema: `schema.sql`
- Basic tests: `test-basic.sql`
- Connection tests: `test-connection-simple.sql`
- This alignment test: `test-codebase-alignment.sql`

