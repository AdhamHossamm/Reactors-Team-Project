-- ============================================================================
-- FIX SUPABASE EXTENSIONS AND CLEAN DATA
-- Run this in Supabase SQL Editor
-- ============================================================================

-- Step 1: Install required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Step 2: Clear all existing data to start fresh
TRUNCATE TABLE cart_activity_logs CASCADE;
TRUNCATE TABLE product_views CASCADE;
TRUNCATE TABLE search_queries CASCADE;
TRUNCATE TABLE order_status_history CASCADE;
TRUNCATE TABLE order_items CASCADE;
TRUNCATE TABLE orders CASCADE;
TRUNCATE TABLE cart_items CASCADE;
TRUNCATE TABLE carts CASCADE;
TRUNCATE TABLE product_reviews CASCADE;
TRUNCATE TABLE product_images CASCADE;
TRUNCATE TABLE products CASCADE;
TRUNCATE TABLE seller_payouts CASCADE;
TRUNCATE TABLE seller_profiles CASCADE;
TRUNCATE TABLE categories CASCADE;
TRUNCATE TABLE user_profiles CASCADE;
-- Don't truncate auth.users - it's managed by Supabase Auth

-- Step 3: Delete from auth.users (test users only)
DELETE FROM auth.users WHERE email LIKE '%test%' OR email LIKE '%example%';

-- Step 4: Verify extensions are installed
SELECT 
    extname as extension_name,
    extversion as version,
    'Installed' as status
FROM pg_extension
WHERE extname IN ('uuid-ossp', 'pgcrypto', 'pg_trgm', 'vector')
ORDER BY extname;

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Extensions installed and data cleared!';
    RAISE NOTICE '📊 Database is ready for fresh data migration';
    RAISE NOTICE '🔐 Auth users preserved (except test accounts)';
END $$;


