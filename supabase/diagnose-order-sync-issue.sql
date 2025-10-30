-- ============================================================================
-- ORDER SYNC DIAGNOSTIC SCRIPT
-- Run this in Supabase SQL Editor to find WHY orders aren't syncing
-- ============================================================================

-- DIAGNOSTIC 1: Check if orders table exists and has correct structure
-- ============================================================================

DO $$
DECLARE
    table_exists BOOLEAN;
    column_count INT;
    order_count INT;
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'ORDER SYNC DIAGNOSTIC';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    
    RAISE NOTICE '[STEP 1] Checking if orders table exists...';
    RAISE NOTICE '----------------------------------------';
    
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_name = 'orders'
    ) INTO table_exists;
    
    IF table_exists THEN
        RAISE NOTICE '  ✓ orders table EXISTS';
        
        -- Count columns
        SELECT COUNT(*) INTO column_count
        FROM information_schema.columns
        WHERE table_name = 'orders' AND table_schema = 'public';
        
        RAISE NOTICE '  ✓ orders table has % columns', column_count;
    ELSE
        RAISE NOTICE '  ✗ orders table DOES NOT EXIST!';
        RAISE NOTICE '  → ACTION: Run supabase/django-schema-sync.sql';
        RETURN;
    END IF;
    
    RAISE NOTICE '';
    RAISE NOTICE '[STEP 2] Checking orders table structure...';
    RAISE NOTICE '----------------------------------------';
END $$;

-- Show actual table structure
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'orders'
ORDER BY ordinal_position;

-- DIAGNOSTIC 2: Check for existing orders
-- ============================================================================

DO $$
DECLARE
    order_count INT;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '[STEP 3] Counting orders in Supabase...';
    RAISE NOTICE '----------------------------------------';
    
    SELECT COUNT(*) INTO order_count FROM public.orders;
    
    IF order_count = 0 THEN
        RAISE NOTICE '  ✗ NO ORDERS FOUND IN SUPABASE';
        RAISE NOTICE '';
        RAISE NOTICE '  This means:';
        RAISE NOTICE '    1. Backend is NOT connected to Supabase';
        RAISE NOTICE '    2. Backend is using SQLite (local database)';
        RAISE NOTICE '    3. Orders exist in SQLite, not in Supabase';
        RAISE NOTICE '';
        RAISE NOTICE '  → ROOT CAUSE: backend/.env has EMPTY database credentials';
    ELSE
        RAISE NOTICE '  ✓ Found % orders in Supabase', order_count;
    END IF;
    
    RAISE NOTICE '';
END $$;

-- Show orders if any exist
SELECT 
    id,
    order_number,
    status,
    total,
    payment_method,
    created_at
FROM public.orders
ORDER BY created_at DESC
LIMIT 10;

-- DIAGNOSTIC 3: Check RLS policies (might be blocking inserts)
-- ============================================================================

DO $$
DECLARE
    policy_count INT;
BEGIN
    RAISE NOTICE '[STEP 4] Checking Row Level Security policies...';
    RAISE NOTICE '----------------------------------------';
    
    SELECT COUNT(*) INTO policy_count
    FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'orders';
    
    IF policy_count = 0 THEN
        RAISE NOTICE '  ⚠ NO RLS policies found';
        RAISE NOTICE '  → This might block inserts from backend';
    ELSE
        RAISE NOTICE '  ✓ Found % RLS policies', policy_count;
    END IF;
    
    RAISE NOTICE '';
END $$;

-- Show RLS policies
SELECT 
    policyname,
    permissive,
    roles,
    cmd AS operation,
    qual AS using_expression,
    with_check AS with_check_expression
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'orders';

-- DIAGNOSTIC 4: Test if we can insert an order manually
-- ============================================================================

DO $$
DECLARE
    test_user_id BIGINT;
    test_order_id BIGINT;
BEGIN
    RAISE NOTICE '[STEP 5] Testing manual order insertion...';
    RAISE NOTICE '----------------------------------------';
    
    -- Get a user ID (or use a test value)
    SELECT id INTO test_user_id FROM public.users LIMIT 1;
    
    IF test_user_id IS NULL THEN
        RAISE NOTICE '  ⚠ No users in Supabase - cannot test order creation';
        RAISE NOTICE '  → ACTION: Sync users first';
        RETURN;
    END IF;
    
    -- Try to insert a test order
    BEGIN
        INSERT INTO public.orders (
            user_id,
            order_number,
            status,
            subtotal,
            tax,
            shipping_cost,
            total,
            shipping_address,
            shipping_city,
            shipping_state,
            shipping_zip,
            shipping_country,
            phone,
            payment_method,
            payment_status,
            created_at,
            updated_at
        ) VALUES (
            test_user_id,
            'TEST-DIAGNOSTIC-001',
            'pending',
            100.00,
            10.00,
            0.00,
            110.00,
            'Test Address',
            'Test City',
            'Test State',
            '12345',
            'United States',
            '+1234567890',
            'cash_on_delivery',
            'pending',
            NOW(),
            NOW()
        ) RETURNING id INTO test_order_id;
        
        RAISE NOTICE '  ✓ SUCCESS! Test order created with ID: %', test_order_id;
        RAISE NOTICE '  → This means Supabase CAN accept orders';
        RAISE NOTICE '  → Problem is: Backend not sending to Supabase';
        
        -- Clean up test order
        DELETE FROM public.orders WHERE id = test_order_id;
        RAISE NOTICE '  ✓ Test order cleaned up';
        
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '  ✗ FAILED to insert test order';
        RAISE NOTICE '  → Error: %', SQLERRM;
        RAISE NOTICE '  → This might be an RLS policy issue';
    END;
    
    RAISE NOTICE '';
END $$;

-- DIAGNOSTIC 5: Check backend connection evidence
-- ============================================================================

DO $$
DECLARE
    product_count INT;
    user_count INT;
    recent_update TIMESTAMP;
BEGIN
    RAISE NOTICE '[STEP 6] Checking for backend connection evidence...';
    RAISE NOTICE '----------------------------------------';
    
    SELECT COUNT(*) INTO product_count FROM public.products;
    SELECT COUNT(*) INTO user_count FROM public.users;
    
    IF product_count > 0 OR user_count > 0 THEN
        RAISE NOTICE '  ✓ Found % products and % users', product_count, user_count;
        
        -- Check for recent activity
        SELECT MAX(updated_at) INTO recent_update FROM public.products;
        RAISE NOTICE '  → Most recent product update: %', recent_update;
        
        IF recent_update > NOW() - INTERVAL '1 hour' THEN
            RAISE NOTICE '  ✓ Recent activity detected - Backend WAS connected';
        ELSE
            RAISE NOTICE '  ⚠ No recent activity - Backend might be using SQLite now';
        END IF;
    ELSE
        RAISE NOTICE '  ✗ NO products or users found';
        RAISE NOTICE '  → Backend has NEVER connected to this Supabase';
    END IF;
    
    RAISE NOTICE '';
END $$;

-- DIAGNOSTIC 6: Check order_items table
-- ============================================================================

DO $$
DECLARE
    table_exists BOOLEAN;
    item_count INT;
BEGIN
    RAISE NOTICE '[STEP 7] Checking order_items table...';
    RAISE NOTICE '----------------------------------------';
    
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_name = 'order_items'
    ) INTO table_exists;
    
    IF table_exists THEN
        SELECT COUNT(*) INTO item_count FROM public.order_items;
        RAISE NOTICE '  ✓ order_items table exists';
        RAISE NOTICE '  → Contains % items', item_count;
    ELSE
        RAISE NOTICE '  ✗ order_items table MISSING';
    END IF;
    
    RAISE NOTICE '';
END $$;

-- ============================================================================
-- FINAL DIAGNOSIS
-- ============================================================================

DO $$
DECLARE
    orders_in_supabase INT;
    products_in_supabase INT;
BEGIN
    SELECT COUNT(*) INTO orders_in_supabase FROM public.orders;
    SELECT COUNT(*) INTO products_in_supabase FROM public.products;
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'DIAGNOSIS COMPLETE';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    
    IF orders_in_supabase = 0 AND products_in_supabase = 0 THEN
        RAISE NOTICE '🔴 ISSUE FOUND:';
        RAISE NOTICE '  Backend has NEVER connected to this Supabase database';
        RAISE NOTICE '';
        RAISE NOTICE '📋 ROOT CAUSE:';
        RAISE NOTICE '  Your backend/.env file has EMPTY database credentials';
        RAISE NOTICE '  Backend is using SQLite (local file database)';
        RAISE NOTICE '  All orders are stored LOCALLY in:';
        RAISE NOTICE '    E:\RP - e-Commerce FS\backend\db.sqlite3';
        RAISE NOTICE '';
        RAISE NOTICE '✅ SOLUTION (Choose ONE):';
        RAISE NOTICE '';
        RAISE NOTICE '  OPTION A: Enable Supabase (Production Mode)';
        RAISE NOTICE '  ──────────────────────────────────────────';
        RAISE NOTICE '  1. Edit backend/.env and UNCOMMENT:';
        RAISE NOTICE '       DB_NAME=postgres';
        RAISE NOTICE '       DB_USER=postgres';
        RAISE NOTICE '       DB_PASSWORD=9_mb!U4yD3RXkJY';
        RAISE NOTICE '       DB_HOST=db.mbwyjrfnbjeseslcveyb.supabase.co';
        RAISE NOTICE '       DB_PORT=5432';
        RAISE NOTICE '';
        RAISE NOTICE '  2. Run migrations:';
        RAISE NOTICE '       cd backend';
        RAISE NOTICE '       python manage.py migrate';
        RAISE NOTICE '';
        RAISE NOTICE '  3. Restart backend - it will now use Supabase!';
        RAISE NOTICE '';
        RAISE NOTICE '  OPTION B: Sync SQLite to Supabase (Keep current data)';
        RAISE NOTICE '  ─────────────────────────────────────────────────────';
        RAISE NOTICE '  1. Keep backend/.env as is (SQLite)';
        RAISE NOTICE '  2. Run sync script:';
        RAISE NOTICE '       cd backend';
        RAISE NOTICE '       python sync_to_supabase.py';
        RAISE NOTICE '';
        RAISE NOTICE '  This copies all data from SQLite → Supabase';
        RAISE NOTICE '';
        
    ELSIF orders_in_supabase = 0 AND products_in_supabase > 0 THEN
        RAISE NOTICE '🟡 PARTIAL CONNECTION:';
        RAISE NOTICE '  Backend connected at some point (% products)', products_in_supabase;
        RAISE NOTICE '  But NO ORDERS have been created since connecting';
        RAISE NOTICE '';
        RAISE NOTICE '📋 POSSIBLE CAUSES:';
        RAISE NOTICE '  1. Backend switched to SQLite after initial setup';
        RAISE NOTICE '  2. Orders created before Supabase was enabled';
        RAISE NOTICE '  3. RLS policies blocking order inserts';
        RAISE NOTICE '';
        RAISE NOTICE '✅ SOLUTION:';
        RAISE NOTICE '  Check backend/.env - ensure Supabase credentials are active';
        RAISE NOTICE '  Or run: python sync_to_supabase.py';
        
    ELSE
        RAISE NOTICE '🟢 SYNC IS WORKING!';
        RAISE NOTICE '  Orders in Supabase: %', orders_in_supabase;
        RAISE NOTICE '  Products in Supabase: %', products_in_supabase;
        RAISE NOTICE '';
        RAISE NOTICE '  Everything is synchronized correctly!';
    END IF;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'END OF DIAGNOSTIC';
    RAISE NOTICE '========================================';
END $$;

-- Show what's actually in Supabase right now
SELECT 
    'TABLE' AS type,
    'orders' AS name,
    COUNT(*)::TEXT AS count
FROM public.orders
UNION ALL
SELECT 'TABLE', 'order_items', COUNT(*)::TEXT FROM public.order_items
UNION ALL
SELECT 'TABLE', 'products', COUNT(*)::TEXT FROM public.products
UNION ALL
SELECT 'TABLE', 'users', COUNT(*)::TEXT FROM public.users
UNION ALL
SELECT 'TABLE', 'categories', COUNT(*)::TEXT FROM public.categories
UNION ALL
SELECT 'BUCKET', 'product-images', 
    CASE WHEN EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'product-images') 
    THEN 'EXISTS' ELSE 'MISSING' END;

-- ============================================================================
-- TEST: Try to insert a sample order (will show exact error if fails)
-- ============================================================================

DO $$
DECLARE
    test_user_id BIGINT;
    test_product_id BIGINT;
    test_order_id BIGINT;
    test_item_id BIGINT;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '[INSERTION TEST] Attempting to create sample order...';
    RAISE NOTICE '----------------------------------------';
    
    -- Get a user
    SELECT id INTO test_user_id FROM public.users LIMIT 1;
    
    IF test_user_id IS NULL THEN
        RAISE NOTICE '  ✗ NO USERS in Supabase';
        RAISE NOTICE '  → Backend has never inserted any users';
        RAISE NOTICE '  → Confirms backend is NOT connected to Supabase';
        RETURN;
    END IF;
    
    -- Get a product
    SELECT id INTO test_product_id FROM public.products LIMIT 1;
    
    IF test_product_id IS NULL THEN
        RAISE NOTICE '  ✗ NO PRODUCTS in Supabase';
        RAISE NOTICE '  → Backend has never inserted any products';
        RAISE NOTICE '  → Confirms backend is NOT connected to Supabase';
        RETURN;
    END IF;
    
    -- Try to create order
    BEGIN
        INSERT INTO public.orders (
            user_id,
            order_number,
            status,
            subtotal,
            tax,
            shipping_cost,
            total,
            shipping_address,
            shipping_city,
            shipping_state,
            shipping_zip,
            shipping_country,
            phone,
            payment_method,
            payment_status,
            created_at,
            updated_at
        ) VALUES (
            test_user_id,
            'DIAGNOSTIC-TEST-' || FLOOR(RANDOM() * 1000)::TEXT,
            'pending',
            50.00,
            5.00,
            0.00,
            55.00,
            '123 Diagnostic St',
            'Test City',
            'TS',
            '12345',
            'United States',
            '+1234567890',
            'cash_on_delivery',
            'pending',
            NOW(),
            NOW()
        ) RETURNING id INTO test_order_id;
        
        RAISE NOTICE '  ✓ Order created successfully! ID: %', test_order_id;
        
        -- Try to add order item
        BEGIN
            INSERT INTO public.order_items (
                order_id,
                product_id,
                product_name,
                product_sku,
                price,
                quantity,
                created_at
            ) VALUES (
                test_order_id,
                test_product_id,
                'Test Product',
                'TEST-SKU-001',
                25.00,
                2,
                NOW()
            ) RETURNING id INTO test_item_id;
            
            RAISE NOTICE '  ✓ Order item created successfully! ID: %', test_item_id;
            RAISE NOTICE '';
            RAISE NOTICE '  ✓✓ SUPABASE CAN ACCEPT ORDERS!';
            RAISE NOTICE '  → The database structure is CORRECT';
            RAISE NOTICE '  → The problem is: Backend not sending to Supabase';
            
            -- Clean up
            DELETE FROM public.order_items WHERE id = test_item_id;
            DELETE FROM public.orders WHERE id = test_order_id;
            RAISE NOTICE '  ✓ Test data cleaned up';
            
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE '  ✗ Failed to create order item: %', SQLERRM;
            DELETE FROM public.orders WHERE id = test_order_id;
        END;
        
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '  ✗ Failed to create order: %', SQLERRM;
        RAISE NOTICE '  → This is the exact error blocking orders';
    END;
    
    RAISE NOTICE '';
END $$;

-- ============================================================================
-- CONNECTION STRING VERIFICATION
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '[STEP 6] Backend Connection Information';
    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE '';
    RAISE NOTICE 'The backend SHOULD connect using:';
    RAISE NOTICE '  Host: db.mbwyjrfnbjeseslcveyb.supabase.co';
    RAISE NOTICE '  Port: 5432';
    RAISE NOTICE '  Database: postgres';
    RAISE NOTICE '  User: postgres';
    RAISE NOTICE '  Password: 9_mb!U4yD3RXkJY';
    RAISE NOTICE '';
    RAISE NOTICE 'Current status in backend/.env:';
    RAISE NOTICE '  DB_NAME= (EMPTY)';
    RAISE NOTICE '  DB_HOST= (EMPTY)';
    RAISE NOTICE '  → Therefore using SQLite instead';
    RAISE NOTICE '';
END $$;

-- ============================================================================
-- FINAL RECOMMENDATION
-- ============================================================================

DO $$
DECLARE
    order_count INT;
BEGIN
    SELECT COUNT(*) INTO order_count FROM public.orders;
    
    RAISE NOTICE '========================================';
    RAISE NOTICE '📊 FINAL DIAGNOSIS';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    
    IF order_count = 0 THEN
        RAISE NOTICE '🔴 CONFIRMED ISSUE:';
        RAISE NOTICE '   Orders exist in BACKEND (SQLite)';
        RAISE NOTICE '   Orders DO NOT exist in SUPABASE';
        RAISE NOTICE '';
        RAISE NOTICE '🎯 EXACT PROBLEM:';
        RAISE NOTICE '   backend/.env has empty DB credentials';
        RAISE NOTICE '   Backend connects to SQLite, not Supabase';
        RAISE NOTICE '   Frontend → Backend → SQLite (✓ WORKING)';
        RAISE NOTICE '   Frontend → Backend → Supabase (✗ NOT HAPPENING)';
        RAISE NOTICE '';
        RAISE NOTICE '✅ FIX:';
        RAISE NOTICE '   1. Uncomment DB credentials in backend/.env';
        RAISE NOTICE '   2. Restart Django backend';
        RAISE NOTICE '   3. New orders will go to Supabase';
        RAISE NOTICE '   4. Run sync_to_supabase.py for existing orders';
    ELSE
        RAISE NOTICE '🟢 Orders found in Supabase: %', order_count;
        RAISE NOTICE '   Sync is working correctly!';
    END IF;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
END $$;





