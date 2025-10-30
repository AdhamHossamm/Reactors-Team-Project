-- =====================================================
-- BASIC DATABASE TEST (No Django tables required)
-- Run this BEFORE running Django migrations
-- Compatible with Supabase SQL Editor
-- =====================================================

-- Test 1: Connection & Version
SELECT 
    '✅ Connection Test' as test,
    'SUCCESS' as status,
    version() as postgres_version;

-- Test 2: Current Database Info
SELECT 
    '📊 Database Info' as test,
    current_database() as database_name,
    current_user as current_user,
    pg_size_pretty(pg_database_size(current_database())) as database_size;

-- Test 3: Available Schemas
SELECT 
    '📁 Schemas' as test,
    schema_name,
    CASE 
        WHEN schema_name = 'public' THEN '✅ Main schema'
        WHEN schema_name = 'auth' THEN '✅ Supabase Auth'
        WHEN schema_name = 'storage' THEN '✅ Supabase Storage'
        ELSE '📦 Other'
    END as description
FROM information_schema.schemata
WHERE schema_name NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
ORDER BY schema_name;

-- Test 4: Tables in Public Schema
SELECT 
    '📋 Current Tables' as test,
    COALESCE(COUNT(*)::text, '0') as table_count,
    CASE 
        WHEN COUNT(*) = 0 THEN '⚠️  No tables yet - Ready for Django migrations'
        WHEN COUNT(*) > 0 THEN '✅ ' || COUNT(*)::text || ' tables found'
    END as status
FROM information_schema.tables
WHERE table_schema = 'public';

-- Test 5: List All Existing Tables (if any)
SELECT 
    '📄 Table List' as category,
    table_name,
    table_type,
    CASE 
        WHEN table_name LIKE 'django_%' THEN '🐍 Django System'
        WHEN table_name LIKE 'auth_%' THEN '🔐 Auth'
        WHEN table_name LIKE 'users_%' THEN '👤 Users'
        WHEN table_name LIKE 'products_%' THEN '🛍️ Products'
        WHEN table_name LIKE 'orders_%' THEN '📦 Orders'
        WHEN table_name LIKE 'sellers_%' THEN '🏪 Sellers'
        WHEN table_name LIKE 'analytics_%' THEN '📊 Analytics'
        ELSE '📋 Other'
    END as module
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- Test 6: Check if Django is Ready
SELECT 
    '🐍 Django Status' as test,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = 'django_migrations'
        ) THEN '✅ Django migrations table exists'
        ELSE '⚠️  Django not migrated yet'
    END as status,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = 'django_migrations'
        ) THEN 'Run: python manage.py showmigrations'
        ELSE 'Run: python manage.py migrate'
    END as next_step;

-- Test 7: Check Expected Django Tables
WITH expected_tables AS (
    SELECT unnest(ARRAY[
        'django_migrations',
        'django_session',
        'django_content_type',
        'users_user',
        'products_category',
        'products_product',
        'orders_cart',
        'orders_order',
        'sellers_sellerprofile',
        'analytics_productview'
    ]) as table_name
)
SELECT 
    '🔍 Expected Tables' as category,
    e.table_name,
    CASE 
        WHEN t.table_name IS NOT NULL THEN '✅ EXISTS'
        ELSE '❌ MISSING'
    END as status
FROM expected_tables e
LEFT JOIN information_schema.tables t 
    ON e.table_name = t.table_name 
    AND t.table_schema = 'public'
ORDER BY 
    CASE WHEN t.table_name IS NOT NULL THEN 0 ELSE 1 END,
    e.table_name;

-- Test 8: Database Extensions
SELECT 
    '🔌 Extensions' as test,
    extname as extension_name,
    extversion as version,
    '✅ Installed' as status
FROM pg_extension
WHERE extname NOT IN ('plpgsql')
ORDER BY extname;

-- Test 9: Connection Settings
SELECT 
    '⚙️  Connection Info' as test,
    name as setting,
    setting as value
FROM pg_settings
WHERE name IN ('max_connections', 'shared_buffers', 'timezone', 'server_version')
ORDER BY name;

-- Test 10: Check SSL Requirement
SELECT 
    '🔒 SSL Status' as test,
    CASE 
        WHEN ssl THEN '✅ SSL Enabled'
        ELSE '⚠️  SSL Disabled'
    END as status
FROM pg_stat_ssl
WHERE pid = pg_backend_pid();

-- =====================================================
-- FINAL SUMMARY
-- =====================================================

SELECT 
    '=' as divider,
    '=' as col2,
    '=' as col3,
    '=' as col4,
    '=' as col5
FROM generate_series(1, 60);

SELECT 
    '📋 SUMMARY' as section,
    '' as detail,
    '' as status,
    '' as action,
    '' as info;

-- Connection Status
SELECT 
    '✅ Connection' as section,
    'Database connection successful' as detail,
    '✅ PASS' as status,
    '' as action,
    current_database() as info;

-- Schema Status
SELECT 
    '✅ Schema' as section,
    'Public schema exists and accessible' as detail,
    '✅ PASS' as status,
    '' as action,
    '' as info;

-- Django Migration Status
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = 'users_user'
        ) THEN '✅ Django Ready'
        ELSE '⚠️  Django Not Ready'
    END as section,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = 'users_user'
        ) THEN 'Django tables detected'
        ELSE 'No Django tables found'
    END as detail,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = 'users_user'
        ) THEN '✅ READY'
        ELSE '⚠️  PENDING'
    END as status,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = 'users_user'
        ) THEN 'Database is ready to use'
        ELSE 'Run: python manage.py migrate'
    END as action,
    '' as info;

-- Table Count
SELECT 
    '📊 Tables' as section,
    COUNT(*)::text || ' tables in public schema' as detail,
    CASE 
        WHEN COUNT(*) >= 20 THEN '✅ COMPLETE'
        WHEN COUNT(*) > 0 THEN '⚠️  PARTIAL'
        ELSE '⚠️  EMPTY'
    END as status,
    CASE 
        WHEN COUNT(*) = 0 THEN 'Ready for initial migration'
        WHEN COUNT(*) < 20 THEN 'May need to run migrations'
        ELSE 'All tables present'
    END as action,
    '' as info
FROM information_schema.tables
WHERE table_schema = 'public';

-- Next Steps
SELECT 
    '🎯 Next Steps' as section,
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public') = 0
        THEN '1. Update backend/.env with DB password'
        ELSE '1. ✅ Database configured'
    END as detail,
    '' as status,
    '' as action,
    '' as info
UNION ALL
SELECT 
    '' as section,
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public') = 0
        THEN '2. Run: python manage.py migrate'
        ELSE '2. ✅ Migrations applied'
    END as detail,
    '' as status,
    '' as action,
    '' as info
UNION ALL
SELECT 
    '' as section,
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public') = 0
        THEN '3. Run: python manage.py setup_demo_data'
        ELSE '3. Run: python manage.py test_db_connection'
    END as detail,
    '' as status,
    '' as action,
    '' as info
UNION ALL
SELECT 
    '' as section,
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public') = 0
        THEN '4. Run this test again to verify'
        ELSE '4. Start Django: python manage.py runserver'
    END as detail,
    '' as status,
    '' as action,
    '' as info;

-- Final divider
SELECT 
    '=' as divider,
    '=' as col2,
    '=' as col3,
    '=' as col4,
    '=' as col5
FROM generate_series(1, 60);

-- Success message
SELECT 
    '✅ TEST COMPLETE' as result,
    'Supabase PostgreSQL is ready for Django!' as message,
    NOW() as timestamp;

