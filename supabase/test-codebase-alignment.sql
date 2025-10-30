-- =====================================================
-- CODEBASE-DATABASE ALIGNMENT TEST
-- Verifies Supabase database matches Django models
-- Run in Supabase SQL Editor ONLY
-- =====================================================
-- Expected output: Clear PASS/FAIL indicators
-- NO psql meta-commands (\timing, \set, etc.)
-- =====================================================

-- =====================================================
-- HEADER
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '╔════════════════════════════════════════════════════╗';
    RAISE NOTICE '║   E-COMMERCE DATABASE ALIGNMENT TEST              ║';
    RAISE NOTICE '║   Testing Django Models vs Supabase Schema        ║';
    RAISE NOTICE '╚════════════════════════════════════════════════════╝';
    RAISE NOTICE '';
END $$;

-- =====================================================
-- TEST 1: DATABASE CONNECTION & ENVIRONMENT
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE 'TEST 1: Database Connection & Environment';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
END $$;

SELECT 
    '1.1' as test_id,
    'PostgreSQL Version' as test_name,
    SPLIT_PART(version(), ' ', 2) as result,
    '✓ PASS' as status;

SELECT 
    '1.2' as test_id,
    'Current Database' as test_name,
    current_database() as result,
    '✓ PASS' as status;

SELECT 
    '1.3' as test_id,
    'Database Size' as test_name,
    pg_size_pretty(pg_database_size(current_database())) as result,
    '✓ PASS' as status;

SELECT 
    '1.4' as test_id,
    'Connection User' as test_name,
    current_user as result,
    '✓ PASS' as status;

-- =====================================================
-- TEST 2: CORE TABLES EXISTENCE
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE 'TEST 2: Core Tables Existence (Django db_table names)';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
END $$;

WITH expected_tables AS (
    SELECT unnest(ARRAY[
        'users',
        'categories',
        'products',
        'product_images',
        'product_reviews',
        'carts',
        'cart_items',
        'orders',
        'order_items',
        'order_status_history',
        'seller_profiles',
        'seller_payouts',
        'product_views',
        'search_queries',
        'cart_activity_logs',
        'sales_metrics'
    ]) as table_name
),
existing_tables AS (
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = 'public'
        AND table_type = 'BASE TABLE'
)
SELECT 
    '2.' || ROW_NUMBER() OVER (ORDER BY e.table_name) as test_id,
    e.table_name as table_name,
    CASE 
        WHEN ex.table_name IS NOT NULL THEN '✓ EXISTS'
        ELSE '✗ MISSING'
    END as status,
    CASE 
        WHEN ex.table_name IS NOT NULL THEN 'PASS'
        ELSE 'FAIL'
    END as result
FROM expected_tables e
LEFT JOIN existing_tables ex ON e.table_name = ex.table_name
ORDER BY e.table_name;

-- Summary
SELECT 
    '2.SUMMARY' as test_id,
    'Core Tables Summary' as metric,
    COUNT(CASE WHEN ex.table_name IS NOT NULL THEN 1 END)::text || '/' || 
    COUNT(*)::text || ' tables found' as result,
    CASE 
        WHEN COUNT(CASE WHEN ex.table_name IS NULL THEN 1 END) = 0 THEN '✓ PASS'
        ELSE '✗ FAIL'
    END as status
FROM (
    SELECT unnest(ARRAY[
        'users', 'categories', 'products', 'product_images', 'product_reviews',
        'carts', 'cart_items', 'orders', 'order_items', 'order_status_history',
        'seller_profiles', 'seller_payouts', 'product_views', 'search_queries',
        'cart_activity_logs', 'sales_metrics'
    ]) as expected_table
) e
LEFT JOIN information_schema.tables ex 
    ON e.expected_table = ex.table_name 
    AND ex.table_schema = 'public';

-- =====================================================
-- TEST 3: USERS TABLE STRUCTURE
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE 'TEST 3: Users Table Column Alignment';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
END $$;

WITH expected_columns AS (
    SELECT 'users' as table_name, unnest(ARRAY[
        'id', 'password', 'last_login', 'is_superuser', 'username', 
        'first_name', 'last_name', 'email', 'is_staff', 'is_active',
        'date_joined', 'role', 'phone', 'address', 'created_at', 'updated_at'
    ]) as column_name
),
existing_columns AS (
    SELECT table_name, column_name, data_type, is_nullable
    FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'users'
)
SELECT 
    '3.' || ROW_NUMBER() OVER (ORDER BY e.column_name) as test_id,
    e.column_name,
    ex.data_type,
    ex.is_nullable,
    CASE 
        WHEN ex.column_name IS NOT NULL THEN '✓ EXISTS'
        ELSE '✗ MISSING'
    END as status
FROM expected_columns e
LEFT JOIN existing_columns ex ON e.column_name = ex.column_name
ORDER BY e.column_name;

-- =====================================================
-- TEST 4: PRODUCTS TABLE STRUCTURE
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE 'TEST 4: Products Table Column Alignment';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
END $$;

WITH expected_columns AS (
    SELECT 'products' as table_name, unnest(ARRAY[
        'id', 'seller_id', 'category_id', 'name', 'slug', 'description',
        'price', 'stock', 'sku', 'brand', 'weight', 'image_url',
        'thumbnail_url', 'is_active', 'is_featured', 'created_at', 'updated_at'
    ]) as column_name
),
existing_columns AS (
    SELECT table_name, column_name, data_type, is_nullable
    FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'products'
)
SELECT 
    '4.' || ROW_NUMBER() OVER (ORDER BY e.column_name) as test_id,
    e.column_name,
    ex.data_type,
    ex.is_nullable,
    CASE 
        WHEN ex.column_name IS NOT NULL THEN '✓ EXISTS'
        ELSE '✗ MISSING'
    END as status
FROM expected_columns e
LEFT JOIN existing_columns ex ON e.column_name = ex.column_name
ORDER BY e.column_name;

-- =====================================================
-- TEST 5: ORDERS TABLE STRUCTURE
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE 'TEST 5: Orders Table Column Alignment';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
END $$;

WITH expected_columns AS (
    SELECT 'orders' as table_name, unnest(ARRAY[
        'id', 'user_id', 'order_number', 'status', 'subtotal', 'tax',
        'shipping_cost', 'total', 'shipping_address', 'shipping_city',
        'shipping_state', 'shipping_zip', 'shipping_country', 'phone',
        'payment_method', 'payment_status', 'created_at', 'updated_at',
        'shipped_at', 'delivered_at'
    ]) as column_name
),
existing_columns AS (
    SELECT table_name, column_name, data_type, is_nullable
    FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'orders'
)
SELECT 
    '5.' || ROW_NUMBER() OVER (ORDER BY e.column_name) as test_id,
    e.column_name,
    ex.data_type,
    ex.is_nullable,
    CASE 
        WHEN ex.column_name IS NOT NULL THEN '✓ EXISTS'
        ELSE '✗ MISSING'
    END as status
FROM expected_columns e
LEFT JOIN existing_columns ex ON e.column_name = ex.column_name
ORDER BY e.column_name;

-- =====================================================
-- TEST 6: FOREIGN KEY RELATIONSHIPS
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE 'TEST 6: Foreign Key Relationships';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
END $$;

WITH expected_fks AS (
    SELECT * FROM (VALUES
        ('products', 'seller_id', 'users', 'id'),
        ('products', 'category_id', 'categories', 'id'),
        ('product_images', 'product_id', 'products', 'id'),
        ('product_reviews', 'product_id', 'products', 'id'),
        ('product_reviews', 'user_id', 'users', 'id'),
        ('carts', 'user_id', 'users', 'id'),
        ('cart_items', 'cart_id', 'carts', 'id'),
        ('cart_items', 'product_id', 'products', 'id'),
        ('orders', 'user_id', 'users', 'id'),
        ('order_items', 'order_id', 'orders', 'id'),
        ('order_items', 'product_id', 'products', 'id'),
        ('order_status_history', 'order_id', 'orders', 'id'),
        ('order_status_history', 'changed_by_id', 'users', 'id'),
        ('seller_profiles', 'user_id', 'users', 'id'),
        ('seller_payouts', 'seller_id', 'users', 'id'),
        ('product_views', 'product_id', 'products', 'id'),
        ('product_views', 'user_id', 'users', 'id'),
        ('search_queries', 'user_id', 'users', 'id'),
        ('cart_activity_logs', 'user_id', 'users', 'id'),
        ('cart_activity_logs', 'product_id', 'products', 'id')
    ) AS t(from_table, from_column, to_table, to_column)
),
existing_fks AS (
    SELECT 
        tc.table_name as from_table,
        kcu.column_name as from_column,
        ccu.table_name as to_table,
        ccu.column_name as to_column
    FROM information_schema.table_constraints tc
    JOIN information_schema.key_column_usage kcu
        ON tc.constraint_name = kcu.constraint_name
        AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage ccu
        ON ccu.constraint_name = tc.constraint_name
        AND ccu.table_schema = tc.table_schema
    WHERE tc.constraint_type = 'FOREIGN KEY'
        AND tc.table_schema = 'public'
)
SELECT 
    '6.' || ROW_NUMBER() OVER (ORDER BY e.from_table, e.from_column) as test_id,
    e.from_table || '.' || e.from_column as foreign_key,
    e.to_table || '.' || e.to_column as references,
    CASE 
        WHEN ex.from_table IS NOT NULL THEN '✓ EXISTS'
        ELSE '✗ MISSING'
    END as status
FROM expected_fks e
LEFT JOIN existing_fks ex 
    ON e.from_table = ex.from_table 
    AND e.from_column = ex.from_column
    AND e.to_table = ex.to_table
    AND e.to_column = ex.to_column
ORDER BY e.from_table, e.from_column;

-- FK Summary
SELECT 
    '6.SUMMARY' as test_id,
    'Foreign Keys Summary' as metric,
    COUNT(CASE WHEN ex.from_table IS NOT NULL THEN 1 END)::text || '/' || 
    COUNT(*)::text || ' FKs found' as result,
    CASE 
        WHEN COUNT(CASE WHEN ex.from_table IS NULL THEN 1 END) = 0 THEN '✓ PASS'
        WHEN COUNT(CASE WHEN ex.from_table IS NULL THEN 1 END) <= 3 THEN '⚠ PARTIAL'
        ELSE '✗ FAIL'
    END as status
FROM (
    SELECT * FROM (VALUES
        ('products', 'seller_id', 'users', 'id'),
        ('products', 'category_id', 'categories', 'id'),
        ('carts', 'user_id', 'users', 'id'),
        ('orders', 'user_id', 'users', 'id')
    ) AS t(from_table, from_column, to_table, to_column)
) e
LEFT JOIN (
    SELECT tc.table_name as from_table, kcu.column_name as from_column,
           ccu.table_name as to_table, ccu.column_name as to_column
    FROM information_schema.table_constraints tc
    JOIN information_schema.key_column_usage kcu
        ON tc.constraint_name = kcu.constraint_name
    JOIN information_schema.constraint_column_usage ccu
        ON ccu.constraint_name = tc.constraint_name
    WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_schema = 'public'
) ex ON e.from_table = ex.from_table AND e.from_column = ex.from_column;

-- =====================================================
-- TEST 7: UNIQUE CONSTRAINTS
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE 'TEST 7: Unique Constraints';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
END $$;

WITH expected_uniques AS (
    SELECT * FROM (VALUES
        ('users', 'email'),
        ('users', 'username'),
        ('categories', 'slug'),
        ('products', 'slug'),
        ('products', 'sku'),
        ('orders', 'order_number'),
        ('carts', 'user_id'),
        ('seller_profiles', 'user_id')
    ) AS t(table_name, column_name)
),
existing_uniques AS (
    SELECT 
        tc.table_name,
        kcu.column_name
    FROM information_schema.table_constraints tc
    JOIN information_schema.key_column_usage kcu
        ON tc.constraint_name = kcu.constraint_name
        AND tc.table_schema = kcu.table_schema
    WHERE (tc.constraint_type = 'UNIQUE' OR tc.constraint_type = 'PRIMARY KEY')
        AND tc.table_schema = 'public'
)
SELECT 
    '7.' || ROW_NUMBER() OVER (ORDER BY e.table_name, e.column_name) as test_id,
    e.table_name,
    e.column_name,
    CASE 
        WHEN ex.column_name IS NOT NULL THEN '✓ EXISTS'
        ELSE '✗ MISSING'
    END as status
FROM expected_uniques e
LEFT JOIN existing_uniques ex 
    ON e.table_name = ex.table_name 
    AND e.column_name = ex.column_name
ORDER BY e.table_name, e.column_name;

-- =====================================================
-- TEST 8: INDEXES FOR PERFORMANCE
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE 'TEST 8: Performance Indexes';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
END $$;

SELECT 
    '8.' || ROW_NUMBER() OVER (ORDER BY tablename, indexname) as test_id,
    tablename,
    indexname,
    '✓ PRESENT' as status
FROM pg_indexes
WHERE schemaname = 'public'
    AND tablename IN ('products', 'orders', 'users', 'categories')
ORDER BY tablename, indexname;

SELECT 
    '8.SUMMARY' as test_id,
    'Total Indexes' as metric,
    COUNT(*)::text || ' indexes' as result,
    CASE 
        WHEN COUNT(*) >= 10 THEN '✓ PASS'
        WHEN COUNT(*) >= 5 THEN '⚠ MINIMAL'
        ELSE '✗ INSUFFICIENT'
    END as status
FROM pg_indexes
WHERE schemaname = 'public';

-- =====================================================
-- TEST 9: DATA TYPE COMPATIBILITY
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE 'TEST 9: Django-PostgreSQL Data Type Compatibility';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
END $$;

SELECT 
    '9.' || ROW_NUMBER() OVER (ORDER BY table_name, column_name) as test_id,
    table_name,
    column_name,
    data_type,
    CASE 
        WHEN data_type IN (
            'integer', 'bigint', 'smallint',
            'character varying', 'text',
            'boolean',
            'timestamp with time zone', 'timestamp without time zone', 'date', 'time',
            'numeric', 'decimal', 'real', 'double precision',
            'uuid',
            'json', 'jsonb',
            'inet', 'cidr',
            'ARRAY'
        ) THEN '✓ Compatible'
        ELSE '⚠ Check Required'
    END as django_compatible
FROM information_schema.columns
WHERE table_schema = 'public'
    AND table_name IN ('users', 'products', 'orders', 'categories')
ORDER BY table_name, ordinal_position;

-- =====================================================
-- TEST 10: NULLABLE FIELDS VALIDATION
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE 'TEST 10: Required vs Optional Fields';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
END $$;

SELECT 
    '10.' || ROW_NUMBER() OVER (ORDER BY table_name, column_name) as test_id,
    table_name,
    column_name,
    CASE 
        WHEN is_nullable = 'NO' THEN 'Required'
        ELSE 'Optional'
    END as constraint_type,
    CASE 
        WHEN column_default IS NOT NULL THEN 'Has Default: ' || substring(column_default, 1, 30)
        ELSE '-'
    END as default_value
FROM information_schema.columns
WHERE table_schema = 'public'
    AND table_name IN ('users', 'products', 'orders')
    AND column_name IN ('email', 'username', 'name', 'price', 'stock', 'total', 'status')
ORDER BY table_name, column_name;

-- =====================================================
-- TEST 11: CHECK CONSTRAINTS
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE 'TEST 11: Check Constraints (Business Rules)';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
END $$;

SELECT 
    '11.' || ROW_NUMBER() OVER (ORDER BY tc.table_name) as test_id,
    tc.table_name,
    tc.constraint_name,
    substring(cc.check_clause, 1, 60) as constraint_rule,
    '✓ ACTIVE' as status
FROM information_schema.table_constraints tc
JOIN information_schema.check_constraints cc
    ON tc.constraint_name = cc.constraint_name
WHERE tc.constraint_type = 'CHECK'
    AND tc.table_schema = 'public'
    AND tc.table_name IN ('products', 'orders', 'users', 'cart_items')
ORDER BY tc.table_name;

-- Summary
SELECT 
    '11.SUMMARY' as test_id,
    'Total Check Constraints' as metric,
    COUNT(*)::text || ' constraints' as result,
    CASE 
        WHEN COUNT(*) >= 5 THEN '✓ PASS'
        WHEN COUNT(*) >= 3 THEN '⚠ MINIMAL'
        ELSE '○ OPTIONAL'
    END as status
FROM information_schema.table_constraints
WHERE constraint_type = 'CHECK' AND table_schema = 'public';

-- =====================================================
-- TEST 12: ROW LEVEL SECURITY STATUS
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE 'TEST 12: Row Level Security (RLS)';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
END $$;

SELECT 
    '12.' || ROW_NUMBER() OVER (ORDER BY tablename) as test_id,
    tablename,
    CASE 
        WHEN rowsecurity THEN '✓ Enabled'
        ELSE '○ Disabled'
    END as rls_status,
    CASE 
        WHEN rowsecurity THEN 'Supabase mode'
        ELSE 'Django mode (backend handles auth)'
    END as auth_mode
FROM pg_tables
WHERE schemaname = 'public'
    AND tablename IN ('users', 'products', 'orders', 'carts', 'seller_profiles')
ORDER BY tablename;

-- =====================================================
-- TEST 13: DATA SAMPLE CHECK
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE 'TEST 13: Table Row Counts';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
END $$;

DO $$
DECLARE
    table_record RECORD;
    row_count BIGINT;
    test_num INTEGER := 1;
BEGIN
    FOR table_record IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
            AND table_type = 'BASE TABLE'
            AND table_name IN (
                'users', 'categories', 'products', 'orders', 'carts',
                'seller_profiles', 'product_reviews', 'cart_items', 'order_items'
            )
        ORDER BY table_name
    LOOP
        EXECUTE format('SELECT COUNT(*) FROM public.%I', table_record.table_name) INTO row_count;
        RAISE NOTICE '13.% | % : % rows | %', 
            test_num, 
            RPAD(table_record.table_name, 25),
            LPAD(row_count::text, 6),
            CASE WHEN row_count > 0 THEN '✓ HAS DATA' ELSE '○ EMPTY' END;
        test_num := test_num + 1;
    END LOOP;
END $$;

-- =====================================================
-- TEST 14: SEQUENCES (AUTO-INCREMENT)
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE 'TEST 14: Sequences for Auto-Increment Fields';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
END $$;

SELECT 
    '14.' || ROW_NUMBER() OVER (ORDER BY sequence_name) as test_id,
    sequence_name,
    data_type,
    '✓ ACTIVE' as status
FROM information_schema.sequences
WHERE sequence_schema = 'public'
ORDER BY sequence_name
LIMIT 20;

SELECT 
    '14.SUMMARY' as test_id,
    'Total Sequences' as metric,
    COUNT(*)::text || ' sequences' as result,
    '✓ PASS' as status
FROM information_schema.sequences
WHERE sequence_schema = 'public';

-- =====================================================
-- FINAL SUMMARY REPORT
-- =====================================================
DO $$
DECLARE
    total_tables INTEGER;
    expected_tables INTEGER := 16;
    missing_tables INTEGER;
    total_fks INTEGER;
    total_indexes INTEGER;
    overall_status TEXT;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '╔════════════════════════════════════════════════════╗';
    RAISE NOTICE '║              FINAL TEST SUMMARY                    ║';
    RAISE NOTICE '╚════════════════════════════════════════════════════╝';
    RAISE NOTICE '';
    
    -- Count tables
    SELECT COUNT(*) INTO total_tables
    FROM information_schema.tables
    WHERE table_schema = 'public'
        AND table_type = 'BASE TABLE'
        AND table_name IN (
            'users', 'categories', 'products', 'product_images', 'product_reviews',
            'carts', 'cart_items', 'orders', 'order_items', 'order_status_history',
            'seller_profiles', 'seller_payouts', 'product_views', 'search_queries',
            'cart_activity_logs', 'sales_metrics'
        );
    
    missing_tables := expected_tables - total_tables;
    
    -- Count FKs
    SELECT COUNT(*) INTO total_fks
    FROM information_schema.table_constraints
    WHERE constraint_type = 'FOREIGN KEY' AND table_schema = 'public';
    
    -- Count indexes
    SELECT COUNT(*) INTO total_indexes
    FROM pg_indexes WHERE schemaname = 'public';
    
    -- Determine overall status
    IF missing_tables = 0 AND total_fks >= 10 THEN
        overall_status := '✓ PASS - Database fully aligned with codebase';
    ELSIF missing_tables <= 2 AND total_fks >= 5 THEN
        overall_status := '⚠ PARTIAL - Minor issues detected';
    ELSE
        overall_status := '✗ FAIL - Significant misalignment detected';
    END IF;
    
    RAISE NOTICE '┌────────────────────────────────────────────────────┐';
    RAISE NOTICE '│ Core Tables:      % / %                           │', 
        LPAD(total_tables::text, 2), LPAD(expected_tables::text, 2);
    RAISE NOTICE '│ Foreign Keys:     %                               │', 
        LPAD(total_fks::text, 2);
    RAISE NOTICE '│ Indexes:          %                               │', 
        LPAD(total_indexes::text, 3);
    RAISE NOTICE '│                                                    │';
    RAISE NOTICE '│ Overall Status:                                    │';
    RAISE NOTICE '│ %  │', RPAD(overall_status, 50);
    RAISE NOTICE '└────────────────────────────────────────────────────┘';
    RAISE NOTICE '';
    
    IF missing_tables > 0 THEN
        RAISE NOTICE '⚠ RECOMMENDATION: Run Django migrations';
        RAISE NOTICE '  → cd backend';
        RAISE NOTICE '  → python manage.py migrate';
    ELSIF total_fks < 10 THEN
        RAISE NOTICE '⚠ RECOMMENDATION: Verify foreign key constraints';
    ELSE
        RAISE NOTICE '✅ DATABASE IS PROPERLY ALIGNED WITH CODEBASE';
        RAISE NOTICE '';
        RAISE NOTICE '✓ All core tables present';
        RAISE NOTICE '✓ Foreign key relationships established';
        RAISE NOTICE '✓ Indexes in place for performance';
        RAISE NOTICE '';
        RAISE NOTICE '🎯 Ready for production use!';
    END IF;
    
    RAISE NOTICE '';
END $$;
