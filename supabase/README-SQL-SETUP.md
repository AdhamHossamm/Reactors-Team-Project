# Supabase SQL Setup Guide

## 📋 Overview

This SQL script creates a complete PostgreSQL schema for the E-Commerce MVP, fully compatible with Supabase.

## 🚀 Quick Setup

### Step 1: Access Supabase SQL Editor

1. Go to your Supabase Dashboard: https://supabase.com/dashboard/project/mbwyjrfnbjeseslcveyb
2. Click on **SQL Editor** in the left sidebar
3. Click **New Query**

### Step 2: Run the Schema Script

1. Open the file: `supabase/schema.sql`
2. Copy the entire contents
3. Paste into the Supabase SQL Editor
4. Click **Run** (or press Ctrl/Cmd + Enter)

### Step 3: Verify Installation

After running the script, you should see:
- ✅ 17 tables created
- ✅ RLS policies enabled
- ✅ Indexes created
- ✅ Triggers configured
- ✅ Demo categories inserted

## 📊 Schema Overview

### Core Tables

**Users & Auth:**
- `user_profiles` - Extended user information (links to auth.users)

**Products:**
- `categories` - Product categories (hierarchical)
- `products` - Main product catalog
- `product_images` - Product image gallery
- `product_reviews` - Customer reviews and ratings

**Shopping:**
- `carts` - User shopping carts
- `cart_items` - Items in carts

**Orders:**
- `orders` - Order records
- `order_items` - Items in orders (snapshot)
- `order_status_history` - Order status audit trail

**Sellers:**
- `seller_profiles` - Business information
- `seller_payouts` - Payment records

**Analytics:**
- `product_views` - Page view tracking
- `search_queries` - Search analytics
- `cart_activity_logs` - Cart behavior tracking
- `sales_metrics` - Daily aggregated metrics

## 🔒 Security Features

### Row Level Security (RLS)

All tables have RLS enabled with policies:

- **Public Read**: Categories, Products (active), Reviews
- **User-Scoped**: Carts, Orders (users see only their own)
- **Seller-Scoped**: Products (sellers manage their own)
- **Admin-Only**: User management, System settings

### Example Policies

```sql
-- Users can only see their own cart
CREATE POLICY "Users can view own cart" ON public.carts
    FOR SELECT USING (user_id = auth.uid());

-- Anyone can view active products
CREATE POLICY "Anyone can view active products" ON public.products
    FOR SELECT USING (is_active = true OR seller_id = auth.uid());
```

## ⚡ Performance Optimizations

### Indexes Created

- Product lookups: `slug`, `sku`, `seller_id`, `category_id`
- Order queries: `user_id`, `order_number`, `status`
- Analytics: Time-based indexes on all log tables
- Search optimization: Text search indexes

### Triggers

- **Auto-update timestamps**: `updated_at` automatically set on UPDATE
- **Order number generation**: Unique order numbers auto-generated
- **Audit trails**: Status changes logged automatically

## 🎯 Integration with Django

### Sync Strategy

The Django backend uses SQLite locally, but this Supabase schema mirrors the Django models:

**Django Model → Supabase Table Mapping:**
- `User` → `user_profiles`
- `Product` → `products`
- `Category` → `categories`
- `Order` → `orders`
- `Cart` → `carts`
- etc.

### Using Both Systems

1. **Local Development**: Django + SQLite
2. **Production**: Django + PostgreSQL OR Supabase
3. **Real-time Features**: Supabase Edge Functions + Realtime
4. **Analytics**: Supabase for logging, Django for business logic

## 📈 Analytics Views

### Pre-built Views

**Product Statistics:**
```sql
SELECT * FROM public.product_stats;
-- Shows: review_count, average_rating, view_count per product
```

**Seller Statistics:**
```sql
SELECT * FROM public.seller_stats;
-- Shows: total_products, active_products, ratings per seller
```

## 🔧 Maintenance

### Add New User

```sql
-- After user signs up via Supabase Auth
INSERT INTO public.user_profiles (id, email, username, role)
VALUES (
    auth.uid(),
    'user@example.com',
    'username',
    'buyer'
);
```

### Query Products

```sql
-- Get all active products with category
SELECT 
    p.*,
    c.name as category_name
FROM public.products p
LEFT JOIN public.categories c ON p.category_id = c.id
WHERE p.is_active = true
ORDER BY p.created_at DESC;
```

### Check Order Status

```sql
-- Get order with items
SELECT 
    o.*,
    json_agg(oi.*) as items
FROM public.orders o
LEFT JOIN public.order_items oi ON o.id = oi.order_id
WHERE o.user_id = auth.uid()
GROUP BY o.id
ORDER BY o.created_at DESC;
```

## 🐛 Troubleshooting

### Issue: RLS Blocking Queries

**Solution**: Check if you're authenticated:
```sql
SELECT auth.uid(); -- Should return your user ID
```

### Issue: Foreign Key Violations

**Solution**: Ensure parent records exist:
```sql
-- Check if user exists before inserting product
SELECT id FROM public.user_profiles WHERE id = 'user-uuid';
```

### Issue: Permission Denied

**Solution**: Grant permissions:
```sql
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
```

## 📚 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)

## ✅ Checklist

After running the script, verify:

- [ ] All 17 tables created
- [ ] RLS policies active (check in Supabase Dashboard → Authentication → Policies)
- [ ] Demo categories inserted (4 categories)
- [ ] Indexes created (check with `\di` in SQL editor)
- [ ] Triggers working (try updating a record)
- [ ] Views accessible (query `product_stats`)

## 🎉 Success!

Your Supabase database is now ready for the E-Commerce MVP!

**Next Steps:**
1. Test the connection from your Next.js app
2. Create a test user via Supabase Auth
3. Insert test products
4. Build Edge Functions for real-time features

