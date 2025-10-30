-- =====================================================
-- SIMPLE DATABASE CONNECTION TEST
-- Compatible with Supabase SQL Editor
-- =====================================================

-- Test 1: Basic Connection
SELECT 
    '✅ TEST 1: Connection' as status,
    'PostgreSQL ' || version() as info;

-- Test 2: Database Info
SELECT 
    '✅ TEST 2: Database' as status,
    current_database() as database,
    current_user as user,
    pg_size_pretty(pg_database_size(current_database())) as size;

-- Test 3: Table Count
SELECT 
    '✅ TEST 3: Tables' as status,
    COUNT(*)::text || ' tables found' as info
FROM information_schema.tables
WHERE table_schema = 'public';

-- Test 4: List All Tables
SELECT 
    '📋 All Tables' as category,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- Test 5: Check Django Tables
WITH django_tables AS (
    SELECT unnest(ARRAY[
        'users_user',
        'products_category',
        'products_product',
        'orders_cart',
        'orders_order'
    ]) as expected_table
)
SELECT 
    '🔍 Django Tables' as category,
    dt.expected_table,
    CASE 
        WHEN t.table_name IS NOT NULL THEN '✅ EXISTS'
        ELSE '❌ MISSING - Run: python manage.py migrate'
    END as status
FROM django_tables dt
LEFT JOIN information_schema.tables t 
    ON dt.expected_table = t.table_name 
    AND t.table_schema = 'public'
ORDER BY dt.expected_table;

-- Test 6: Foreign Keys
SELECT 
    '🔗 Foreign Keys' as category,
    COUNT(*)::text || ' constraints' as info
FROM information_schema.table_constraints
WHERE constraint_type = 'FOREIGN KEY'
    AND table_schema = 'public';

-- Test 7: Indexes
SELECT 
    '⚡ Indexes' as category,
    COUNT(*)::text || ' indexes' as info
FROM pg_indexes
WHERE schemaname = 'public';

-- Test 8: Sample Column Check (products_product)
SELECT 
    '📊 products_product columns' as category,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
    AND table_name = 'products_product'
ORDER BY ordinal_position;

-- Test 9: Row Counts
SELECT 
    '📈 Data Summary' as category,
    t.table_name,
    (xpath('/row/cnt/text()', 
        query_to_xml(format('select count(*) as cnt from %I.%I', 
        t.table_schema, t.table_name), false, true, ''))
    )[1]::text::int as row_count
FROM information_schema.tables t
WHERE t.table_schema = 'public'
    AND t.table_type = 'BASE TABLE'
    AND t.table_name NOT LIKE 'pg_%'
ORDER BY t.table_name
LIMIT 20;

-- Final Status
SELECT 
    '✅ FINAL STATUS' as result,
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.tables 
              WHERE table_schema = 'public' AND table_name = 'users_user') > 0 
        THEN '✅ Django tables detected - Database is ready!'
        ELSE '⚠️  No Django tables - Run migrations first'
    END as message;

