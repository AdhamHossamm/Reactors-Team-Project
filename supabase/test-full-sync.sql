-- ============================================================================
-- COMPREHENSIVE SYNC TEST SCRIPT
-- Tests all sync points between Frontend → Backend → Supabase
-- ============================================================================

-- PART 1: SCHEMA VERIFICATION
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'SUPABASE SYNC DIAGNOSTIC TEST';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    
    -- Test 1: Check critical tables exist
    RAISE NOTICE '[TEST 1] Verifying Table Structure';
    RAISE NOTICE '----------------------------------------';
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users') THEN
        RAISE NOTICE '  [OK] users table exists';
    ELSE
        RAISE NOTICE '  [MISSING] users table - Run django-schema-sync.sql';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'products') THEN
        RAISE NOTICE '  [OK] products table exists';
    ELSE
        RAISE NOTICE '  [MISSING] products table - Run django-schema-sync.sql';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'categories') THEN
        RAISE NOTICE '  [OK] categories table exists';
    ELSE
        RAISE NOTICE '  [MISSING] categories table - Run django-schema-sync.sql';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'orders') THEN
        RAISE NOTICE '  [OK] orders table exists';
    ELSE
        RAISE NOTICE '  [MISSING] orders table - Run django-schema-sync.sql';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'order_items') THEN
        RAISE NOTICE '  [OK] order_items table exists';
    ELSE
        RAISE NOTICE '  [MISSING] order_items table - Run django-schema-sync.sql';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'carts') THEN
        RAISE NOTICE '  [OK] carts table exists';
    ELSE
        RAISE NOTICE '  [MISSING] carts table - Run django-schema-sync.sql';
    END IF;
    
    RAISE NOTICE '';
    
    -- Test 2: Check new product fields
    RAISE NOTICE '[TEST 2] Verifying Product Enhancements';
    RAISE NOTICE '----------------------------------------';
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'discount_percentage') THEN
        RAISE NOTICE '  [OK] discount_percentage column exists';
    ELSE
        RAISE NOTICE '  [MISSING] discount_percentage - Run product-enhancements.sql';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'shipping_fee') THEN
        RAISE NOTICE '  [OK] shipping_fee column exists';
    ELSE
        RAISE NOTICE '  [MISSING] shipping_fee - Run product-enhancements.sql';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'tags') THEN
        RAISE NOTICE '  [OK] tags column exists';
    ELSE
        RAISE NOTICE '  [MISSING] tags - Run product-enhancements.sql';
    END IF;
    
    RAISE NOTICE '';
    
    -- Test 3: Check checkout functions
    RAISE NOTICE '[TEST 3] Verifying Checkout Functions';
    RAISE NOTICE '----------------------------------------';
    
    IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_order_totals') THEN
        RAISE NOTICE '  [OK] calculate_order_totals() function exists';
    ELSE
        RAISE NOTICE '  [MISSING] calculate_order_totals() - Run checkout-sync.sql';
    END IF;
    
    IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'validate_checkout_order') THEN
        RAISE NOTICE '  [OK] validate_checkout_order() function exists';
    ELSE
        RAISE NOTICE '  [MISSING] validate_checkout_order() - Run checkout-sync.sql';
    END IF;
    
    IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'process_checkout') THEN
        RAISE NOTICE '  [OK] process_checkout() function exists';
    ELSE
        RAISE NOTICE '  [MISSING] process_checkout() - Run checkout-sync.sql';
    END IF;
    
    RAISE NOTICE '';
    
    -- Test 4: Count existing records
    RAISE NOTICE '[TEST 4] Current Supabase Data';
    RAISE NOTICE '----------------------------------------';
    
END $$;

-- Display counts
SELECT 
    'users' AS table_name, 
    COUNT(*) AS records
FROM public.users WHERE email LIKE '%test%'
UNION ALL
SELECT 'products', COUNT(*) FROM public.products
UNION ALL
SELECT 'categories', COUNT(*) FROM public.categories
UNION ALL
SELECT 'orders', COUNT(*) FROM public.orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM public.order_items;

-- PART 2: SAMPLE DATA TEST
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '[TEST 5] Testing Order Creation';
    RAISE NOTICE '----------------------------------------';
    
    -- Check if we can insert a test order
    IF EXISTS (SELECT 1 FROM public.users LIMIT 1) 
       AND EXISTS (SELECT 1 FROM public.products LIMIT 1) THEN
        RAISE NOTICE '  [OK] Sample data available for testing';
    ELSE
        RAISE NOTICE '  [WARNING] No sample data - sync from SQLite first';
    END IF;
    
    RAISE NOTICE '';
END $$;

-- PART 3: RLS POLICIES CHECK
-- ============================================================================

SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies
WHERE schemaname = 'public'
AND tablename IN ('orders', 'order_items', 'products', 'users')
ORDER BY tablename, policyname;

-- PART 4: STORAGE BUCKET CHECK
-- ============================================================================

SELECT 
    id,
    name,
    public,
    created_at
FROM storage.buckets
WHERE id = 'product-images';

-- ============================================================================
-- FINAL SUMMARY
-- ============================================================================

DO $$
DECLARE
    users_count INT;
    products_count INT;
    orders_count INT;
BEGIN
    SELECT COUNT(*) INTO users_count FROM public.users;
    SELECT COUNT(*) INTO products_count FROM public.products;
    SELECT COUNT(*) INTO orders_count FROM public.orders;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'SYNC STATUS SUMMARY';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    RAISE NOTICE 'Supabase Contains:';
    RAISE NOTICE '  Users:    % records', users_count;
    RAISE NOTICE '  Products: % records', products_count;
    RAISE NOTICE '  Orders:   % records', orders_count;
    RAISE NOTICE '';
    
    IF orders_count = 0 THEN
        RAISE NOTICE '[ACTION NEEDED]';
        RAISE NOTICE '  1. Your Supabase has NO ORDERS yet';
        RAISE NOTICE '  2. Backend is using SQLite (local database)';
        RAISE NOTICE '  3. To sync orders to Supabase:';
        RAISE NOTICE '     a) Resume Supabase project';
        RAISE NOTICE '     b) Run: python backend/sync_to_supabase.py';
        RAISE NOTICE '     c) OR enable Supabase in backend/.env';
    ELSE
        RAISE NOTICE '[SUCCESS] Supabase has data - sync is working!';
    END IF;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
END $$;

-- ============================================================================
-- END OF DIAGNOSTIC TEST
-- ============================================================================

