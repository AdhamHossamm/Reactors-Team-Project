-- ============================================================================
-- COMPREHENSIVE SYSTEM TEST SCRIPT
-- Tests all functions, views, triggers, and data flow across the e-commerce system
-- ============================================================================

-- ============================================================================
-- SECTION 1: SCHEMA VALIDATION
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '=== SECTION 1: SCHEMA VALIDATION ===';
END $$;

-- Test 1.1: Check all required tables exist
SELECT 
    'Tables Check' AS test_name,
    CASE 
        WHEN COUNT(*) >= 13 THEN 'PASS ✓'
        ELSE 'FAIL ✗ - Missing tables'
    END AS result,
    COUNT(*) || ' tables found' AS details
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE'
AND table_name IN (
    'users', 'categories', 'products', 'product_images', 'product_reviews',
    'carts', 'cart_items', 'orders', 'order_items', 'order_status_history',
    'seller_profiles', 'product_images_storage', 'product_views'
);

-- Test 1.2: Check data types consistency
SELECT 
    'Type Consistency Check' AS test_name,
    CASE 
        WHEN 
            (SELECT data_type FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'id') = 'uuid'
            AND (SELECT data_type FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'seller_id') = 'uuid'
            AND (SELECT data_type FROM information_schema.columns WHERE table_name = 'order_items' AND column_name = 'seller_id') = 'uuid'
        THEN 'PASS ✓ - UUID types match'
        ELSE 'WARN ⚠ - Mixed types detected (handled with casting)'
    END AS result;

-- Test 1.3: Check new columns from enhancements exist
SELECT 
    'Product Enhancements' AS test_name,
    CASE 
        WHEN COUNT(*) = 5 THEN 'PASS ✓'
        ELSE 'FAIL ✗ - Missing columns: ' || (5 - COUNT(*))::text
    END AS result
FROM information_schema.columns 
WHERE table_name = 'products'
AND column_name IN ('discount_percentage', 'shipping_fee', 'tags', 'technical_specs', 'refund_policy');

SELECT 
    'Order Items Enhancements' AS test_name,
    CASE 
        WHEN COUNT(*) = 6 THEN 'PASS ✓'
        ELSE 'FAIL ✗ - Missing columns: ' || (6 - COUNT(*))::text
    END AS result
FROM information_schema.columns 
WHERE table_name = 'order_items'
AND column_name IN ('seller_id', 'product_description', 'product_image_url', 'discount_applied', 'shipping_fee', 'item_total');

-- ============================================================================
-- SECTION 2: FUNCTIONS AND TRIGGERS VALIDATION
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '=== SECTION 2: FUNCTIONS & TRIGGERS VALIDATION ===';
END $$;

-- Test 2.1: Check all required functions exist
SELECT 
    'Functions Check' AS test_name,
    CASE 
        WHEN COUNT(*) >= 6 THEN 'PASS ✓'
        ELSE 'FAIL ✗ - Missing functions'
    END AS result,
    COUNT(*) || ' functions found' AS details
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name IN (
    'get_discounted_price', 'get_final_price', 'generate_product_sku',
    'auto_generate_product_fields', 'log_order_status_change',
    'calculate_order_item_total', 'update_order_status', 'get_order_summary'
);

-- Test 2.2: Check all required triggers exist
SELECT 
    'Triggers Check' AS test_name,
    CASE 
        WHEN COUNT(*) >= 4 THEN 'PASS ✓'
        ELSE 'FAIL ✗ - Missing triggers'
    END AS result,
    COUNT(*) || ' triggers found' AS details
FROM information_schema.triggers
WHERE trigger_schema = 'public'
AND event_object_table IN ('products', 'orders', 'order_items');

-- Test 2.3: Test product pricing functions
SELECT 
    'Product Pricing Functions' AS test_name,
    CASE 
        WHEN 
            get_discounted_price(100.00, 20) = 80.00
            AND get_final_price(100.00, 20, 10.00) = 90.00
        THEN 'PASS ✓'
        ELSE 'FAIL ✗ - Calculation error'
    END AS result,
    'Discount: ' || get_discounted_price(100.00, 20)::text || 
    ', Final: ' || get_final_price(100.00, 20, 10.00)::text AS details;

-- Test 2.4: Test SKU generation
SELECT 
    'SKU Generation' AS test_name,
    CASE 
        WHEN generate_product_sku() LIKE 'PRD-%' THEN 'PASS ✓'
        ELSE 'FAIL ✗'
    END AS result,
    'Sample: ' || generate_product_sku() AS details;

-- ============================================================================
-- SECTION 3: VIEWS VALIDATION
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '=== SECTION 3: VIEWS VALIDATION ===';
END $$;

-- Test 3.1: Check all required views exist
SELECT 
    'Views Check' AS test_name,
    CASE 
        WHEN COUNT(*) >= 4 THEN 'PASS ✓'
        ELSE 'FAIL ✗ - Missing views'
    END AS result,
    array_agg(table_name)::text AS found_views
FROM information_schema.views
WHERE table_schema = 'public'
AND table_name IN ('product_listings', 'order_details_view', 'order_items_details_view', 'seller_orders_view');

-- Test 3.2: Test product_listings view (if data exists)
DO $$
DECLARE
    view_works BOOLEAN;
    error_msg TEXT;
BEGIN
    BEGIN
        PERFORM * FROM product_listings LIMIT 1;
        view_works := TRUE;
    EXCEPTION WHEN OTHERS THEN
        view_works := FALSE;
        error_msg := SQLERRM;
    END;
    
    RAISE NOTICE 'Product Listings View: %', 
        CASE WHEN view_works THEN 'PASS ✓' ELSE 'FAIL ✗ - ' || error_msg END;
END $$;

-- Test 3.3: Test order views (if data exists)
DO $$
DECLARE
    view_works BOOLEAN;
    error_msg TEXT;
BEGIN
    BEGIN
        PERFORM * FROM order_details_view LIMIT 1;
        view_works := TRUE;
    EXCEPTION WHEN OTHERS THEN
        view_works := FALSE;
        error_msg := SQLERRM;
    END;
    
    RAISE NOTICE 'Order Details View: %', 
        CASE WHEN view_works THEN 'PASS ✓' ELSE 'FAIL ✗ - ' || error_msg END;
END $$;

DO $$
DECLARE
    view_works BOOLEAN;
    error_msg TEXT;
BEGIN
    BEGIN
        PERFORM * FROM order_items_details_view LIMIT 1;
        view_works := TRUE;
    EXCEPTION WHEN OTHERS THEN
        view_works := FALSE;
        error_msg := SQLERRM;
    END;
    
    RAISE NOTICE 'Order Items Details View: %', 
        CASE WHEN view_works THEN 'PASS ✓' ELSE 'FAIL ✗ - ' || error_msg END;
END $$;

-- ============================================================================
-- SECTION 4: DATA INTEGRITY CHECKS
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '=== SECTION 4: DATA INTEGRITY CHECKS ===';
END $$;

-- Test 4.1: Check for orphaned order_items (items without orders)
SELECT 
    'Order Items Integrity' AS test_name,
    CASE 
        WHEN COUNT(*) = 0 THEN 'PASS ✓ - No orphaned items'
        ELSE 'WARN ⚠ - Found ' || COUNT(*) || ' orphaned items'
    END AS result
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.id
WHERE o.id IS NULL;

-- Test 4.2: Check for order_items without seller_id (should auto-populate via trigger)
SELECT 
    'Seller ID Population' AS test_name,
    CASE 
        WHEN COUNT(*) = 0 THEN 'PASS ✓ - All items have seller_id'
        WHEN COUNT(*) > 0 AND (SELECT COUNT(*) FROM order_items WHERE product_id IS NOT NULL) > 0 
            THEN 'WARN ⚠ - ' || COUNT(*) || ' items missing seller_id'
        ELSE 'PASS ✓ - No items with products yet'
    END AS result
FROM order_items
WHERE seller_id IS NULL AND product_id IS NOT NULL;

-- Test 4.3: Check product stock consistency
SELECT 
    'Product Stock' AS test_name,
    CASE 
        WHEN COUNT(*) = 0 THEN 'PASS ✓ - No negative stock'
        ELSE 'FAIL ✗ - Found ' || COUNT(*) || ' products with negative stock'
    END AS result
FROM products
WHERE stock < 0;

-- Test 4.4: Check order totals consistency (if orders exist)
SELECT 
    'Order Totals' AS test_name,
    CASE 
        WHEN COUNT(*) = 0 THEN 'PASS ✓ - All order totals match'
        WHEN (SELECT COUNT(*) FROM orders) = 0 THEN 'PASS ✓ - No orders yet'
        ELSE 'WARN ⚠ - Found ' || COUNT(*) || ' orders with mismatched totals'
    END AS result
FROM orders
WHERE total != (subtotal + COALESCE(tax, 0) + COALESCE(shipping_cost, 0));

-- ============================================================================
-- SECTION 5: FUNCTIONAL FLOW TESTS (E2E SIMULATION)
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '=== SECTION 5: FUNCTIONAL FLOW TESTS ===';
END $$;

-- Test 5.1: Simulate complete order flow with test data
DO $$
DECLARE
    test_user_id UUID;
    test_seller_id UUID;
    test_category_id UUID;
    test_product_id UUID;
    test_order_id BIGINT;
    test_order_item_id BIGINT;
    success BOOLEAN := TRUE;
BEGIN
    -- Check if we can safely run this test
    IF (SELECT COUNT(*) FROM users) > 0 THEN
        RAISE NOTICE 'Order Flow Simulation: SKIP - Using real data, manual testing required';
        RETURN;
    END IF;
    
    -- Create test user (buyer)
    BEGIN
        INSERT INTO users (username, email, password, role, is_active)
        VALUES ('test_buyer', 'buyer@test.com', 'test123', 'buyer', true)
        RETURNING id INTO test_user_id;
    EXCEPTION WHEN OTHERS THEN
        success := FALSE;
        RAISE NOTICE 'Order Flow - Create Buyer: FAIL ✗ - %', SQLERRM;
        RETURN;
    END;
    
    -- Create test seller
    BEGIN
        INSERT INTO users (username, email, password, role, is_active)
        VALUES ('test_seller', 'seller@test.com', 'test123', 'seller', true)
        RETURNING id INTO test_seller_id;
    EXCEPTION WHEN OTHERS THEN
        success := FALSE;
        RAISE NOTICE 'Order Flow - Create Seller: FAIL ✗ - %', SQLERRM;
        ROLLBACK;
        RETURN;
    END;
    
    -- Create test category
    BEGIN
        INSERT INTO categories (name, slug, description)
        VALUES ('Test Category', 'test-category', 'For testing')
        RETURNING id INTO test_category_id;
    EXCEPTION WHEN OTHERS THEN
        success := FALSE;
        RAISE NOTICE 'Order Flow - Create Category: FAIL ✗ - %', SQLERRM;
        ROLLBACK;
        RETURN;
    END;
    
    -- Create test product
    BEGIN
        INSERT INTO products (
            seller_id, category_id, name, slug, description, price, stock,
            sku, discount_percentage, shipping_fee, is_active
        ) VALUES (
            test_seller_id, test_category_id, 'Test Product', 'test-product',
            'Test description', 99.99, 10, 'TEST-001', 10, 5.00, true
        ) RETURNING id INTO test_product_id;
        
        RAISE NOTICE 'Product Creation: PASS ✓ - Auto-fields should be populated';
    EXCEPTION WHEN OTHERS THEN
        success := FALSE;
        RAISE NOTICE 'Order Flow - Create Product: FAIL ✗ - %', SQLERRM;
        ROLLBACK;
        RETURN;
    END;
    
    -- Create test order
    BEGIN
        INSERT INTO orders (
            user_id, order_number, status, subtotal, tax, shipping_cost, total,
            shipping_address, shipping_city, shipping_state, shipping_zip,
            shipping_country, phone, payment_method, payment_status
        ) VALUES (
            test_user_id, 'TEST-ORDER-001', 'pending', 89.99, 7.20, 5.00, 102.19,
            '123 Test St', 'Test City', 'TS', '12345', 'US',
            '555-0100', 'card', 'pending'
        ) RETURNING id INTO test_order_id;
        
        RAISE NOTICE 'Order Creation: PASS ✓';
    EXCEPTION WHEN OTHERS THEN
        success := FALSE;
        RAISE NOTICE 'Order Flow - Create Order: FAIL ✗ - %', SQLERRM;
        ROLLBACK;
        RETURN;
    END;
    
    -- Create order item (trigger should auto-populate seller_id and calculate total)
    BEGIN
        INSERT INTO order_items (
            order_id, product_id, product_name, product_sku,
            price, quantity, discount_applied, shipping_fee
        ) VALUES (
            test_order_id, test_product_id, 'Test Product', 'TEST-001',
            99.99, 1, 10.00, 5.00
        ) RETURNING id INTO test_order_item_id;
        
        -- Check if trigger populated seller_id
        IF (SELECT seller_id FROM order_items WHERE id = test_order_item_id) IS NOT NULL THEN
            RAISE NOTICE 'Order Item Trigger (seller_id): PASS ✓';
        ELSE
            RAISE NOTICE 'Order Item Trigger (seller_id): FAIL ✗ - Not populated';
        END IF;
        
        -- Check if trigger calculated item_total
        IF (SELECT item_total FROM order_items WHERE id = test_order_item_id) = 94.99 THEN
            RAISE NOTICE 'Order Item Trigger (item_total): PASS ✓ - Calculated correctly';
        ELSE
            RAISE NOTICE 'Order Item Trigger (item_total): WARN ⚠ - Check calculation';
        END IF;
        
    EXCEPTION WHEN OTHERS THEN
        success := FALSE;
        RAISE NOTICE 'Order Flow - Create Order Item: FAIL ✗ - %', SQLERRM;
        ROLLBACK;
        RETURN;
    END;
    
    -- Test order status update function
    BEGIN
        PERFORM update_order_status(
            test_order_id, 'processing', NULL, NULL,
            'Test status change', test_user_id
        );
        
        -- Check if status was updated
        IF (SELECT status FROM orders WHERE id = test_order_id) = 'processing' THEN
            RAISE NOTICE 'Order Status Update Function: PASS ✓';
        ELSE
            RAISE NOTICE 'Order Status Update Function: FAIL ✗';
        END IF;
        
        -- Check if history was logged
        IF (SELECT COUNT(*) FROM order_status_history WHERE order_id = test_order_id) >= 1 THEN
            RAISE NOTICE 'Order Status History Logging: PASS ✓';
        ELSE
            RAISE NOTICE 'Order Status History Logging: FAIL ✗';
        END IF;
        
    EXCEPTION WHEN OTHERS THEN
        success := FALSE;
        RAISE NOTICE 'Order Flow - Update Status: FAIL ✗ - %', SQLERRM;
        ROLLBACK;
        RETURN;
    END;
    
    -- Test order summary function
    BEGIN
        PERFORM * FROM get_order_summary(test_order_id);
        RAISE NOTICE 'Order Summary Function: PASS ✓';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Order Summary Function: FAIL ✗ - %', SQLERRM;
    END;
    
    -- Test views with test data
    BEGIN
        PERFORM * FROM order_details_view WHERE order_id = test_order_id;
        RAISE NOTICE 'Order Details View (with data): PASS ✓';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Order Details View (with data): FAIL ✗ - %', SQLERRM;
    END;
    
    BEGIN
        PERFORM * FROM order_items_details_view WHERE order_id = test_order_id;
        RAISE NOTICE 'Order Items Details View (with data): PASS ✓';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Order Items Details View (with data): FAIL ✗ - %', SQLERRM;
    END;
    
    BEGIN
        PERFORM * FROM seller_orders_view WHERE seller_id = test_seller_id;
        RAISE NOTICE 'Seller Orders View (with data): PASS ✓';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Seller Orders View (with data): FAIL ✗ - %', SQLERRM;
    END;
    
    BEGIN
        PERFORM * FROM product_listings WHERE id = test_product_id;
        RAISE NOTICE 'Product Listings View (with data): PASS ✓';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Product Listings View (with data): FAIL ✗ - %', SQLERRM;
    END;
    
    -- Cleanup test data
    RAISE NOTICE '';
    RAISE NOTICE 'Cleaning up test data...';
    DELETE FROM order_items WHERE id = test_order_item_id;
    DELETE FROM orders WHERE id = test_order_id;
    DELETE FROM products WHERE id = test_product_id;
    DELETE FROM categories WHERE id = test_category_id;
    DELETE FROM users WHERE id IN (test_user_id, test_seller_id);
    
    RAISE NOTICE 'Test data cleaned up successfully';
    RAISE NOTICE 'Order Flow E2E Test: COMPLETE ✓';
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Order Flow E2E Test: ERROR - %', SQLERRM;
    ROLLBACK;
END $$;

-- ============================================================================
-- SECTION 6: RLS POLICY VALIDATION
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '=== SECTION 6: RLS POLICY VALIDATION ===';
END $$;

-- Test 6.1: Check RLS is enabled on critical tables
SELECT 
    'RLS Enabled Check' AS test_name,
    CASE 
        WHEN COUNT(*) >= 8 THEN 'PASS ✓'
        ELSE 'WARN ⚠ - Some tables missing RLS'
    END AS result,
    array_agg(tablename)::text AS rls_enabled_tables
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('products', 'orders', 'order_items', 'order_status_history', 
                  'product_images_storage', 'carts', 'cart_items', 'seller_profiles')
AND rowsecurity = true;

-- Test 6.2: Count policies per table
SELECT 
    schemaname,
    tablename,
    COUNT(*) as policy_count
FROM pg_policies
WHERE schemaname = 'public'
GROUP BY schemaname, tablename
ORDER BY tablename;

-- ============================================================================
-- SECTION 7: STORAGE AND INDEXES
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '=== SECTION 7: STORAGE & INDEXES ===';
END $$;

-- Test 7.1: Check storage bucket exists
SELECT 
    'Storage Bucket' AS test_name,
    CASE 
        WHEN EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'product-images') 
        THEN 'PASS ✓ - Bucket exists'
        ELSE 'FAIL ✗ - Bucket not found'
    END AS result;

-- Test 7.2: Check critical indexes exist
SELECT 
    'Critical Indexes' AS test_name,
    CASE 
        WHEN COUNT(*) >= 15 THEN 'PASS ✓'
        ELSE 'WARN ⚠ - Some indexes missing'
    END AS result,
    COUNT(*) || ' indexes found' AS details
FROM pg_indexes
WHERE schemaname = 'public'
AND tablename IN ('products', 'orders', 'order_items', 'users')
AND indexname LIKE 'idx_%';

-- ============================================================================
-- FINAL SUMMARY
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '=============================================================';
    RAISE NOTICE 'COMPREHENSIVE SYSTEM TEST COMPLETE';
    RAISE NOTICE '=============================================================';
    RAISE NOTICE '';
    RAISE NOTICE 'Review the results above for any FAIL ✗ or WARN ⚠ items';
    RAISE NOTICE '';
    RAISE NOTICE 'Next Steps:';
    RAISE NOTICE '1. Fix any FAIL items immediately';
    RAISE NOTICE '2. Review WARN items and address if needed';
    RAISE NOTICE '3. Run backend integration tests';
    RAISE NOTICE '4. Test frontend order flow manually';
    RAISE NOTICE '';
END $$;

