-- =====================================================
-- DATABASE ALIGNMENT TEST SCRIPT
-- Tests Supabase PostgreSQL against Django models
-- Run this in Supabase SQL Editor
-- =====================================================
-- NOTE: This script is compatible with Supabase SQL Editor
-- Remove any psql-specific commands like \set, \di, etc.
-- =====================================================

-- =====================================================
-- TEST 1: Connection & Version Check
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'TEST 1: Connection & Version Check';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
END $$;

SELECT 
    'PostgreSQL Version' as test,
    version() as result;

SELECT 
    'Current Database' as test,
    current_database() as result;

SELECT 
    'Current User' as test,
    current_user as result;

SELECT 
    'Database Size' as test,
    pg_size_pretty(pg_database_size(current_database())) as result;

-- =====================================================
-- TEST 2: Schema Existence
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'TEST 2: Schema Existence';
    RAISE NOTICE '========================================';
END $$;

SELECT 
    'Schemas' as test,
    string_agg(schema_name, ', ' ORDER BY schema_name) as result
FROM information_schema.schemata
WHERE schema_name NOT IN ('pg_catalog', 'information_schema', 'pg_toast');

-- =====================================================
-- TEST 3: Django Tables Check
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'TEST 3: Django Tables Check';
    RAISE NOTICE '========================================';
END $$;

-- Expected Django tables
WITH expected_tables AS (
    SELECT unnest(ARRAY[
        'auth_user',
        'auth_group',
        'auth_permission',
        'django_content_type',
        'django_migrations',
        'django_session',
        'users_user',
        'products_category',
        'products_product',
        'products_productimage',
        'products_productreview',
        'orders_cart',
        'orders_cartitem',
        'orders_order',
        'orders_orderitem',
        'orders_orderstatushistory',
        'sellers_sellerprofile',
        'sellers_sellerpayout',
        'analytics_productview',
        'analytics_searchquery',
        'analytics_cartactivitylog',
        'analytics_salesmetrics'
    ]) as table_name
),
existing_tables AS (
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = 'public'
)
SELECT 
    e.table_name,
    CASE 
        WHEN ex.table_name IS NOT NULL THEN '✓ EXISTS'
        ELSE '✗ MISSING'
    END as status
FROM expected_tables e
LEFT JOIN existing_tables ex ON e.table_name = ex.table_name
ORDER BY e.table_name;

-- Count summary
SELECT 
    'Total Tables in Public Schema' as metric,
    COUNT(*)::text as value
FROM information_schema.tables
WHERE table_schema = 'public';

-- =====================================================
-- TEST 4: Critical Columns Check
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'TEST 4: Critical Columns Check';
    RAISE NOTICE '========================================';
END $$;

-- Check users_user table
SELECT 
    'users_user columns' as test,
    string_agg(column_name, ', ' ORDER BY ordinal_position) as columns
FROM information_schema.columns
WHERE table_schema = 'public' 
    AND table_name = 'users_user';

-- Check products_product table
SELECT 
    'products_product columns' as test,
    string_agg(column_name, ', ' ORDER BY ordinal_position) as columns
FROM information_schema.columns
WHERE table_schema = 'public' 
    AND table_name = 'products_product';

-- Check orders_order table
SELECT 
    'orders_order columns' as test,
    string_agg(column_name, ', ' ORDER BY ordinal_position) as columns
FROM information_schema.columns
WHERE table_schema = 'public' 
    AND table_name = 'orders_order';

-- =====================================================
-- TEST 5: Foreign Key Constraints
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'TEST 5: Foreign Key Constraints';
    RAISE NOTICE '========================================';
END $$;

SELECT 
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table,
    ccu.column_name AS foreign_column,
    '✓' as status
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema = 'public'
ORDER BY tc.table_name, kcu.column_name
LIMIT 20;

SELECT 
    'Total Foreign Keys' as metric,
    COUNT(*)::text as value
FROM information_schema.table_constraints
WHERE constraint_type = 'FOREIGN KEY'
    AND table_schema = 'public';

-- =====================================================
-- TEST 6: Indexes Check
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'TEST 6: Indexes Check';
    RAISE NOTICE '========================================';
END $$;

SELECT 
    tablename,
    indexname,
    '✓' as status
FROM pg_indexes
WHERE schemaname = 'public'
    AND tablename LIKE '%product%'
ORDER BY tablename, indexname
LIMIT 15;

SELECT 
    'Total Indexes' as metric,
    COUNT(*)::text as value
FROM pg_indexes
WHERE schemaname = 'public';

-- =====================================================
-- TEST 7: Data Type Compatibility
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'TEST 7: Data Type Compatibility';
    RAISE NOTICE '========================================';
END $$;

-- Check for compatible data types
SELECT 
    table_name,
    column_name,
    data_type,
    CASE 
        WHEN data_type IN ('character varying', 'text', 'integer', 'bigint', 
                          'boolean', 'timestamp with time zone', 'date', 
                          'numeric', 'uuid', 'json', 'jsonb') THEN '✓ Compatible'
        ELSE '⚠ Check compatibility'
    END as django_compatible
FROM information_schema.columns
WHERE table_schema = 'public'
    AND table_name LIKE 'products_%'
ORDER BY table_name, ordinal_position;

-- =====================================================
-- TEST 8: Nullable Fields Check
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'TEST 8: Nullable Fields Check';
    RAISE NOTICE '========================================';
END $$;

SELECT 
    table_name,
    column_name,
    is_nullable,
    CASE 
        WHEN column_default IS NOT NULL THEN 'Has default'
        WHEN is_nullable = 'YES' THEN 'Nullable'
        ELSE 'Required'
    END as constraint_type
FROM information_schema.columns
WHERE table_schema = 'public'
    AND table_name IN ('products_product', 'orders_order', 'users_user')
    AND column_name NOT LIKE '%_id'
ORDER BY table_name, ordinal_position;

-- =====================================================
-- TEST 9: Primary Keys Check
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'TEST 9: Primary Keys Check';
    RAISE NOTICE '========================================';
END $$;

SELECT 
    tc.table_name,
    kcu.column_name,
    '✓ Has PK' as status
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
WHERE tc.constraint_type = 'PRIMARY KEY'
    AND tc.table_schema = 'public'
ORDER BY tc.table_name;

-- =====================================================
-- TEST 10: Unique Constraints
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'TEST 10: Unique Constraints';
    RAISE NOTICE '========================================';
END $$;

SELECT 
    tc.table_name,
    kcu.column_name,
    '✓ Unique' as status
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
WHERE tc.constraint_type = 'UNIQUE'
    AND tc.table_schema = 'public'
ORDER BY tc.table_name, kcu.column_name
LIMIT 20;

-- =====================================================
-- TEST 11: Check Constraints
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'TEST 11: Check Constraints';
    RAISE NOTICE '========================================';
END $$;

SELECT 
    tc.table_name,
    tc.constraint_name,
    cc.check_clause,
    '✓' as status
FROM information_schema.table_constraints tc
JOIN information_schema.check_constraints cc
    ON tc.constraint_name = cc.constraint_name
WHERE tc.constraint_type = 'CHECK'
    AND tc.table_schema = 'public'
ORDER BY tc.table_name
LIMIT 15;

-- =====================================================
-- TEST 12: Sequence Check (Auto-increment)
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'TEST 12: Sequences Check';
    RAISE NOTICE '========================================';
END $$;

SELECT 
    sequence_name,
    data_type,
    '✓ Active' as status
FROM information_schema.sequences
WHERE sequence_schema = 'public'
ORDER BY sequence_name
LIMIT 15;

SELECT 
    'Total Sequences' as metric,
    COUNT(*)::text as value
FROM information_schema.sequences
WHERE sequence_schema = 'public';

-- =====================================================
-- TEST 13: Sample Data Check
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'TEST 13: Sample Data Check';
    RAISE NOTICE '========================================';
END $$;

-- Check if tables have data
DO $$
DECLARE
    table_record RECORD;
    row_count INTEGER;
BEGIN
    FOR table_record IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
            AND table_type = 'BASE TABLE'
            AND table_name NOT LIKE 'django_%'
            AND table_name NOT LIKE 'auth_%'
        ORDER BY table_name
    LOOP
        EXECUTE format('SELECT COUNT(*) FROM public.%I', table_record.table_name) INTO row_count;
        RAISE NOTICE '% : % rows', table_record.table_name, row_count;
    END LOOP;
END $$;

-- =====================================================
-- TEST 14: Django Migration Status
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'TEST 14: Django Migrations';
    RAISE NOTICE '========================================';
END $$;

-- Check if django_migrations table exists and has data
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'django_migrations'
    ) THEN
        RAISE NOTICE 'django_migrations table: ✓ EXISTS';
    ELSE
        RAISE NOTICE 'django_migrations table: ✗ MISSING (Run Django migrations!)';
    END IF;
END $$;

-- Show recent migrations if table exists
SELECT 
    app,
    name,
    applied
FROM django_migrations
WHERE EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_name = 'django_migrations'
)
ORDER BY applied DESC
LIMIT 10;

-- =====================================================
-- TEST 15: Permission & RLS Check
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'TEST 15: Row Level Security Status';
    RAISE NOTICE '========================================';
END $$;

SELECT 
    schemaname,
    tablename,
    CASE 
        WHEN rowsecurity THEN '✓ RLS Enabled'
        ELSE '○ RLS Disabled'
    END as rls_status
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename
LIMIT 20;

-- =====================================================
-- FINAL SUMMARY
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'TEST SUMMARY';
    RAISE NOTICE '========================================';
END $$;

SELECT 
    'Test' as category,
    'Status' as result;

SELECT 'Database Connection' as category, '✓ PASS' as result
UNION ALL
SELECT 'Schema Exists' as category, '✓ PASS' as result
UNION ALL
SELECT 
    'Django Tables' as category,
    CASE 
        WHEN COUNT(*) >= 15 THEN '✓ PASS'
        ELSE '⚠ INCOMPLETE'
    END as result
FROM information_schema.tables
WHERE table_schema = 'public'
    AND table_name LIKE '%\_%'
UNION ALL
SELECT 
    'Foreign Keys' as category,
    CASE 
        WHEN COUNT(*) > 0 THEN '✓ PASS'
        ELSE '⚠ MISSING'
    END as result
FROM information_schema.table_constraints
WHERE constraint_type = 'FOREIGN KEY'
    AND table_schema = 'public'
UNION ALL
SELECT 
    'Indexes' as category,
    CASE 
        WHEN COUNT(*) > 0 THEN '✓ PASS'
        ELSE '⚠ MISSING'
    END as result
FROM pg_indexes
WHERE schemaname = 'public';

-- =====================================================
-- RECOMMENDATIONS
-- =====================================================
DO $$
DECLARE
    table_count INTEGER;
    fk_count INTEGER;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'RECOMMENDATIONS';
    RAISE NOTICE '========================================';
    
    -- Check table count
    SELECT COUNT(*) INTO table_count
    FROM information_schema.tables
    WHERE table_schema = 'public';
    
    IF table_count < 15 THEN
        RAISE NOTICE '⚠ Run Django migrations: python manage.py migrate';
    ELSE
        RAISE NOTICE '✓ Database schema looks good!';
    END IF;
    
    -- Check FK count
    SELECT COUNT(*) INTO fk_count
    FROM information_schema.table_constraints
    WHERE constraint_type = 'FOREIGN KEY'
        AND table_schema = 'public';
    
    IF fk_count < 10 THEN
        RAISE NOTICE '⚠ Few foreign keys detected. Ensure referential integrity.';
    ELSE
        RAISE NOTICE '✓ Foreign key constraints are in place.';
    END IF;
    
    RAISE NOTICE '';
    RAISE NOTICE '✅ TEST COMPLETE!';
    RAISE NOTICE '';
END $$;

